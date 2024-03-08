// Contrato utilizando array para armazenar dados

pragma solidity ^0.8.0;

contract ArrayExample {
    uint256[] public data;

    event DataAdded(uint256 newData);

    function addData(uint256 newData) public {
        data.push(newData);
        emit DataAdded(newData);
    }
}
