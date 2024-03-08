// Contrato utilizando hash table para armazenar dados

pragma solidity ^0.8.0;

contract HashtableExample {
    mapping(bytes32 => string) public data;

    event DataUpdated(bytes32 key, string newValue);

    function updateData(bytes32 key, string memory newValue) public {
        data[key] = newValue;
        emit DataUpdated(key, newValue);
    }
}
