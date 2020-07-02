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
        
        if(keccak256(abi.encodePacked(_message)) == keccak256(abi.encodePacked("HdM")) && chatID == 0) {
            users.setMessageCertified(msg.sender);
        }
    }
    
    //Funktion um sich die letzte Nachricht eines Chats ausgeben zu lassen.
    function getLatestMessage() public view returns(address){
        require (isInChat(msg.sender), "You aren't a member of this chat!");
        return latestMessage;
    }
    
    //Überprüfung ob eine Adresse Mitglied eines Chats ist.
    function isInChat(address _address) private view returns(bool isMember) {
        require (memberCounter > 0, "This chat has 0 members!");
        uint memberIndex = 0;
        while(memberIndex < memberCounter) {
            if(members[memberIndex] == _address){
                return true;
            }
            memberIndex++;
        }
        return false;
    }
}
