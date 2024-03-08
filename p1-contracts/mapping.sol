// Contrato utilizando mapping para armazenar dados

pragma solidity ^0.8.0;

contract MappingExample {
    mapping(address => uint256) public userBalances;

    event BalanceUpdated(address indexed user, uint256 newBalance);

    function updateBalance(uint256 newBalance) public {
        userBalances[msg.sender] = newBalance;
        emit BalanceUpdated(msg.sender, newBalance);
    }
}
