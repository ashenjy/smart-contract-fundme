// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

/// @notice contract to accept a payment

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol"; //to avoid problems in math with solidity

// Connect the deployed Smart Contracts to the Outside World
// using chainlink data feeds
//https://docs.chain.link/docs/using-chainlink-reference-contracts/
contract FundMe {
    
    address public owner;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    using SafeMathChainlink for uint256;

    constructor() public {
        owner = msg.sender;
    }
    
    //wei- smallest denomination of ethereum / smallest unit of measure in ethereum
    //track all the people who has funded
    //button will be read
    function fund() public payable {
        
        // minimum fund value is $50
        uint256 minimumUSD = 50 * 10 ** 18; // in wei
        
        //1 gwei < $50  execution will be reverted if value is less than minimumUSD defined
        require(getConversionRate(msg.value) >= minimumUSD, "spend more ETH please!");
        
        //keep track of how much funding and who is funding
        //adds value
        //msg sender = caller address
        addressToAmountFunded[msg.sender] += msg.value;
        //this contract will now be the owner of the funded ether

        //GET the ETH to USD Conversion Rate
        
        //after withdraw, reset the current funders value to 0
        funders.push(msg.sender);
        
    }
    
    //interact with an interface contract
    //make a contract call to another contract from this contract 
    //deploy this contract to rinkeby
    function getVersion() public view returns(uint256) {
        //initialize the contract
        //https://docs.chain.link/docs/ethereum-addresses/   ETH -> USD Chainlink Rinkeby Test Address
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    //get current ETH price in USD eg - 2500 USD
    function getPrice() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
         (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }
    
    //ethAmount in gwei = 1000000000  -> https://eth-converter.com/
    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmoundInUsd = (ethPrice * ethAmount) /  1000000000000000000;
        return ethAmoundInUsd;
    }
    
    //modifier to wrap the withdraw function to grant access only to the owner
    modifier onlyOwner {
        require(msg.sender == owner, "Request Denied, Invalid Sender!");
        _;
    }
    
    function withdraw() payable onlyOwner public {
        msg.sender.transfer(address(this).balance);
        for(uint256 fi=0; fi < funders.length; fi++){
            address funder = funders[fi];
            addressToAmountFunded[funder] = 0;
        }
        
        //reset participated funders since owner withdraw all funders
        funders = new address[](0);
        
    }
    
}