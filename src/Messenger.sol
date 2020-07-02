pragma solidity ^0.6.6;

import "./Chat.sol";
import "./AllUsers.sol";

contract Messenger {
    
    //Variablen
    uint private chatCounter = 0;
    mapping (uint => Chat) private chats;
    AllUsers private users;
    
    constructor()public{
        users = new AllUsers();
    }
    
    //Funktion zum erstellen eines Chats
    function createChat() public{
        Chat chat = new Chat(this, users, chatCounter);
        chats[chatCounter++] = chat;
        users.setCreateChatCertified(msg.sender);
    }
    
    //Funktion um sich die Addresse eines Chats ausgeben zu lassen.
    function getChat(uint _chatId) public view returns(address){
        require (_chatId < chatCounter, "The Chat with the given ChatID doesn't exist yet!");
        return address(chats[_chatId]);
    }
    
    //Funktion um die Chat ID des am letzten erstellten Chats auszugeben.
    function getLastChatID() public view returns(uint){
        require(chatCounter > 0, "Nobody created a chat yet!");
        return chatCounter - 1;
    }
    
    //Funktion, welcher die Adresse des Zertifikats ausgibt, falls die übergebene Adresse
    //alle Aufgaben erfüllt hat.
    function getCertificate(address _author)public view returns(address){
        return users.getCertificate(_author);
    }
    
    //Funktion um sich einen Nicknamen zu erstellen.
    function setNickname(string memory _nickname) public{
        users.setNickname(msg.sender, _nickname);
        users.setNicknameCertified(msg.sender);
    }
}
