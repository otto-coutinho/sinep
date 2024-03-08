// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HashTable {
    struct Entry {
        string name; 
        Entry next; // Encadeamento para tratamento de colisão
    }

    mapping(uint256 => Entry) private table;

    // Função para calcular o hash
    function hash(string memory _name) private pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_name)));
    }

    // Função para adicionar um nome à tabela hash
    function addName(string memory _name) public {
        uint256 key = hash(_name);

        if (table[key].name.length == 0) {
            // Não há colisão, inserir diretamente
            table[key] = Entry(_name, Entry(""));
        } else {
            // Tratamento de colisão por encadeamento aberto
            Entry storage current = table[key];
            while (bytes(current.name).length != 0 && keccak256(abi.encodePacked(current.name)) != keccak256(abi.encodePacked(_name))) {
                if (bytes(current.next.name).length == 0) {
                    current.next = Entry(_name, Entry(""));
                    return;
                }
                current = current.next;
            }
        }
    }

    // Função para obter o nome com base no hash
    function getName(uint256 _key) public view returns (string memory) {
        Entry storage current = table[_key];
        while (bytes(current.name).length != 0) {
            // Encontrou a entrada correspondente
            return current.name;
        }
        // Nenhum nome correspondente encontrado
        revert("Nome nao encontrado");
    }
}
