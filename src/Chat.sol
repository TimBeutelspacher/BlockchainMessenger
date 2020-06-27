pragma solidity ^0.6.6;

import "./Message.sol";
import "./Messenger.sol";

contract Chat {
    
    //Variablen
    Messenger private messenger; 
    uint private messageCounter = 0;
    mapping (uint => Message) private messages;
    uint private memberCounter = 0;
    mapping (uint => address) private members;
    
    constructor(Messenger _messenger)public{
        messenger = _messenger;
    }
    
    //Funktion um diesem Chat beizutreten
    function joinChat() public{
        require(memberCounter == 0 || isInChat(msg.sender) == false, "You are already in this Chat!");
        members[memberCounter] = msg.sender;
        memberCounter++;
    }
    
    //Funktion um eine Nachricht in den Chat zu schreiben
    function createMessage(string memory _message) public{
        require (isInChat(msg.sender), "You aren't a member of this chat!");
        address previousMessage = address(messages[messageCounter - 1]);
        Message message = new Message(messenger, _message, msg.sender, previousMessage);
        messages[messageCounter] = message;
        messageCounter++;
    }
    
    //Funktion um sich die letzte Nachricht eines Chats ausgeben zu lassen.
    function getLatestMessage() public view returns(Message){
        require (isInChat(msg.sender), "You aren't a member of this chat!");
        require (messageCounter > 0, "There isn't a message in this chat!");
        return messages[messageCounter - 1];
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
