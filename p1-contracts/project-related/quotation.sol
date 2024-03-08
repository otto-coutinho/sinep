// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ManageUsers} from "./access/ManageUsers.sol";

contract Quotation is ManageUsers {
    // Estrutura de dados para representar uma transação
    struct Transaction {
        uint256 timestamp; // Timestamp da transação
        uint idProduct; // ID do produto
        uint unitPrice; // Preço unitário do produto
        string local; // Local da transação
        uint amount; // Quantidade do produto
        bool active; // Estado da transação
        uint transactionId; // ID da transação
    }

    // Estrutura de dados para representar uma transação em andamento
    struct onGoingTransaction {
        Transaction transaction; // Transação
        address sender; // Endereço do remetente
        address receiver; // Endereço do destinatário
        bool active; // Estado da transação em andamento
    }

    // Evento emitido quando uma transação em andamento é adicionada
    event AddedOnGoingTransaction(address indexed wallet, uint indexed transactionId); 
    // Evento emitido quando uma transação em andamento é respondida
    event AnsweredAnGoingTransaction(address indexed wallet, bool decision); 

    // Contador de índice para transações em andamento
    uint private indexCounter = 1; 
    // Mapeamento de endereço de usuário para transações em andamento
    mapping(address => uint[]) private UserToOnGoingTransactions; 
    // Mapeamento de ID de transação para transações em andamento
    mapping(uint => onGoingTransaction) private onGoingTransactions; 
    // Array de transações
    Transaction[] private transactions; 

    //Construtor herdado manageUsers
    constructor(address initialOwner) ManageUsers(initialOwner) {}

    // (RN1) Função para adicionar uma transação em andamento
    function addOnGoingTransaction(
        address _receiver, 
        uint _idProduct, 
        uint _unitPrice, 
        string memory _local, 
        uint _amount
    ) external onlyOwnerAndUsers {    
        require(msg.sender != _receiver, "You need to send the transaction to a different enabled wallet");     
        require(users[_receiver].active, "You need to send the transaction to a different enabled wallet");
        // Criar uma nova transação
        Transaction memory newTransaction = Transaction({
            timestamp: block.timestamp,
            idProduct: _idProduct,
            unitPrice: _unitPrice,
            local: _local,
            amount: _amount,
            active: false,
            transactionId: 0 
        });

        // Criar uma nova transação em andamento com a transação interior
        onGoingTransaction memory newOnGoingTransaction = onGoingTransaction({
            transaction: newTransaction,
            sender: msg.sender,
            receiver: _receiver,
            active: true
        });

        // Armazenar a nova transação em andamento
        onGoingTransactions[indexCounter] = newOnGoingTransaction;
        //Adiciona os índices da nova transação para o vendedor e comprador
        UserToOnGoingTransactions[msg.sender].push(indexCounter);
        UserToOnGoingTransactions[_receiver].push(indexCounter);
        
        //Emite o evento 
        emit AddedOnGoingTransaction(_receiver, indexCounter);
        //Incrementa o contador
        indexCounter++;
    }

    // Função interna para encontrar uma transação em andamento pelo índice
    function findOnGoingTransaction(uint _index) 
    private view returns (onGoingTransaction memory) {
        //Verifica se existe o index da transação em andamento
        require(_index < indexCounter, "Transaction index out of bounds");
        onGoingTransaction memory newOnGoingTransaction = onGoingTransactions[_index];
        //retorna a transação em andamento
        return newOnGoingTransaction;
    }

    // Função para obter os detalhes de uma transação em andamento
    function getOnGoingTransactions(uint _index) external onlyOwnerAndUsers view 
    returns(
        uint256,
        uint, 
        uint, 
        string memory,
        uint
    ) {
        //Instancia uma copia da transação em andamento
        onGoingTransaction memory newOnGoingTransaction = findOnGoingTransaction(_index);
        if (!isOwner()) {
            require((
                (newOnGoingTransaction.sender == msg.sender) || 
                (newOnGoingTransaction.receiver == msg.sender)
            ));
            require(newOnGoingTransaction.active, 
            "This transaction has been settled down");
        }
        //Instancia uma cópia da transação guardada na transação em andamento
        Transaction memory transaction = newOnGoingTransaction.transaction;

        return (transaction.timestamp, transaction.idProduct, transaction.unitPrice, transaction.local, transaction.amount);
    }

    // (RN2) Função para obter todas as transações efetivadas
    function getTransactions() external onlyOwnerAndUsers view returns (Transaction[] memory) {
        return transactions;
    }

    // Função para obter todas as transações em andamento de um usuário
    function getAllMyOnGoingTransactions() external onlyOwnerAndUsers view 
    returns (onGoingTransaction[] memory) {
        
        uint[] memory ids = UserToOnGoingTransactions[msg.sender];
        onGoingTransaction[] memory newOnGoingTransactionsMemory = new onGoingTransaction[](ids.length);        

        //Busca todas as transações e adiciona no array
        for (uint i = 0; i < ids.length; i++) {
            if (onGoingTransactions[ids[i]].active) {
                newOnGoingTransactionsMemory[i] = onGoingTransactions[ids[i]];
            }            
        }

        //retorna todas as transações
        return newOnGoingTransactionsMemory;
    }

    // Função para responder a uma transação em andamento
    function answerOnGoingTransaction(uint _index, bool _decision) external onlyOwnerAndUsers {
        onGoingTransaction memory newOnGoingTransaction = findOnGoingTransaction(_index);
        if (!isOwner()) {
            require(newOnGoingTransaction.receiver == msg.sender, 
            "You must be the transaction's receiver to answer");
            require(newOnGoingTransaction.active,
            "This transaction has been settled down");
        }
        Transaction memory transaction = newOnGoingTransaction.transaction;
        if (_decision) {
            transaction.active = true;
            transactions.push(transaction);
        }
        onGoingTransactions[_index].active = false;
        emit AnsweredAnGoingTransaction(newOnGoingTransaction.sender, _decision);
    }

}