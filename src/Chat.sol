pragma solidity ^0.6.6;

import "./Messenger.sol";
import "./Message.sol";
import "./AllUsers.sol";

contract Chat {
    
    //Variablen
    Messenger private messenger; 
    AllUsers private users;
    uint private chatID;
    address private latestMessage;
    uint private memberCounter = 0;
    mapping (uint => address) private members;
    
    constructor(Messenger _messenger, AllUsers _users, uint _chatID)public{
        messenger = _messenger;
        users = _users;
        chatID = _chatID;
    }
    
    //Funktion um diesem Chat beizutreten
    function joinChat() public{
        require(memberCounter == 0 || isInChat(msg.sender) == false, "You are already in this Chat!");
        members[memberCounter++] = msg.sender;
        if (chatID == 0){
           users.setJoinChatCertified(msg.sender);
        }        
    }
    
    //Funktion um eine Nachricht in den Chat zu schreiben
    function createMessage(string memory _message) public{
        require (isInChat(msg.sender), "You aren't a member of this chat!");
        Message message = new Message(messenger, users, _message, msg.sender, latestMessage);
        latestMessage = address(message);
        
        if(keccak256(abi.encodePacked(_message)) == keccak256(abi.encodePacked("HdMBlockchain20")) && chatID == 0) {
            users.setMessageCertified(msg.sender);
        }
    }
    
    //Funktion um sich die letzte Nachricht eines Chats ausgeben zu lassen.
    function getLatestMessage() public view returns(address){
        require (isInChat(msg.sender), "You aren't a member of this chat!");
        return latestMessage;
    }
    
    //Überprüfung ob eine Adresse Mitglied eines Chats ist.
    function isInChat(address _address) public view returns(bool isMember) {
        uint memberIndex = 0;
        while(memberIndex < memberCounter) {
            if(members[memberIndex] == _address){
                return true;
            }
            memberIndex++;
        }
        return false;
    }
    
     // Funktion um alle Nachrichten geordnet aus einem Chat auszulesen
    function getAllMessages() public view returns(string memory){
        require (isInChat(msg.sender), "You aren't a member of this chat!");
        require(latestMessage != 0x0000000000000000000000000000000000000000, "There isn't a message in this chat!");
        
        
        string memory output;
        string memory currentMessageText;
        string memory currentAuthor;
        address currentMessageAddress = latestMessage;
        
        Message currentMessage = Message(currentMessageAddress);
            
        while(currentMessageAddress != 0x0000000000000000000000000000000000000000){
            
            currentMessageText = currentMessage.text();
            currentAuthor = currentMessage.getAuthor();
            
            output = string(abi.encodePacked(output, currentAuthor, ': ', currentMessageText, '\n'));
            
            currentMessageAddress = currentMessage.getPreviousMessage();
            currentMessage = Message(currentMessage.getPreviousMessage());
        }
        
        return output;
    }
    
    
    
    
}
