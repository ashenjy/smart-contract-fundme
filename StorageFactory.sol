// SPDX-License-Identifier: MIT

//solidity version
pragma solidity >=0.6.0 <0.9.0;

import "./SimpleStorage.sol";

//deploy a contract & interact with a contract from another contract

contract StorageFactory is SimpleStorage{
    
    SimpleStorage[] public simpStorageArr;
    
    function createSimpleStorage() public {
        SimpleStorage simpleStorage = new SimpleStorage();
        simpStorageArr.push(simpleStorage);
    }
    
    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public {
        //address
        //ABI
        SimpleStorage simpleStorage = SimpleStorage(address(simpStorageArr[_simpleStorageIndex]));
        simpleStorage.store(_simpleStorageNumber);
    }
    
    function sfGet(uint256 _simpleStorageIndex) public view returns(uint256){
        return SimpleStorage(address(simpStorageArr[_simpleStorageIndex])).retrieve();
    }
}