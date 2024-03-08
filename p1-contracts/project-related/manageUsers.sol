// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

contract ManageUsers is Ownable {
    // Estrutura de dados para representar um usuário
    struct User {
        string name; // Nome do usuário
        uint timestamp; // Timestamp de criação do usuário
        bool active; // Estado do usuário
    }

    mapping(address => User) internal users; // Mapeamento de endereço para usuário

    event AddedUser(address indexed wallet); // Evento emitido quando uma nova wallet é adicionada
    event DeletedUser(address indexed wallet); // Evento emitido quando uma wallet é removida

    // Modificador para garantir que apenas o proprietário e usuários autorizados possam chamar uma função
    modifier onlyOwnerAndUsers() {
        if (!isOwner()) {
            require(users[msg.sender].active, "Not a registered user");
        }
        _;
    }

    constructor(address initialOwner) Ownable(initialOwner) {}

    // (RN3) Função para adicionar uma wallet e permiti-la
    function addUser(address _wallet, string memory _name) external onlyOwner {
        require(_wallet != address(0), "Invalid wallet address.");
        require(!users[_wallet].active, "Wallet already added.");
        users[_wallet] = User({
            name: _name,
            timestamp: block.timestamp,
            active: true
        });
        emit AddedUser(_wallet);
    }

    // Função para remover uma wallet permitida
    function deleteUser(address _wallet) external onlyOwner {
        require(users[_wallet].active, "Wallet not found.");
        users[_wallet].active = false;
        emit DeletedUser(_wallet);
    }
}