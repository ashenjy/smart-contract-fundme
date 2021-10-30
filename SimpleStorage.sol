// SPDX-License-Identifier: MIT

//app to store information in the blockchain for us

//solidity version
pragma solidity >=0.6.0 <0.9.0;

contract SimpleStorage {
    //init to 0
    uint256 favoriteNumber;

    struct People {
        uint256 favoriteNumber;
        string name;
    }

    People[] public people;
    mapping(string => uint256) public nameToFavoriteNumber;

    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

    //view, pure functions
    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }

    //memory - store data temporary
    //storage - holds data between function calls
    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        people.push(People(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}
