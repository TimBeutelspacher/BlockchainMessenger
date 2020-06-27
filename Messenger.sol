pragma solidity ^0.6.6;

import "./Chat.sol";
import "./User.sol";

contract Messenger {
    
    //Variablen
    uint private chatCounter = 0;
    mapping (uint => Chat) private chats;
    mapping (address => User) private userMap;
    
    //Funktion zum erstellen eines Chats
    function createChat() public returns(address){
        Chat chat = new Chat(this);
        chats[chatCounter++] = chat;
        return address(chats[chatCounter - 1]);
    }
    
    //Funktion um sich die Addresse eines Chats ausgeben zu lassen.
    function getChat(uint _chatId) public view returns(address){
        require (_chatId < chatCounter, "The Chat with the given ChatID doesn't exist yet!");
        return address(chats[_chatId]);
    }
    
    //Funktion um sich einen Nicknamen zu erstellen.
    function setNickname(string memory _nickname) public{
        User user = new User();
        user.setNickname(_nickname);
        userMap[msg.sender] = user;
    }
    
    //Funktion um den Nicknamen eines Users ausgeben zu lassen.
    function getNickname(address _address)public view returns(string memory){
        return userMap[_address].getNickname();
    }
}
