pragma solidity ^0.6.6;

import "./Messenger.sol";
import "./Message.sol";

contract Chat {
    
    //Variablen
    Messenger private messenger; 
    uint private chatID;
    address private latestMessage;
    address[] private members;
    
    constructor(Messenger _messenger, uint _chatID, address _address)public{
        messenger = _messenger;
        chatID = _chatID;
        members.push(_address);
    }
    
    //Funktion um diesem Chat beizutreten
    function joinChat() public{
        require(isInChat(msg.sender) == false, "You are already in this Chat!");
        members.push(msg.sender);
    }
    
    //Funktion um eine Nachricht in den Chat zu schreiben
    function createMessage(string memory _message) public{
        require (isInChat(msg.sender), "You aren't a member of this chat!");
        Message message = new Message(_message, msg.sender, latestMessage);
        latestMessage = address(message);
    }
    
    //Funktion um sich die letzte Nachricht eines Chats ausgeben zu lassen.
    function getLatestMessage() public view returns(address){
        return latestMessage;
    }
    
    // Funktion um alle Nachrichten geordnet aus einem Chat auszulesen
    function getAllMessages() public view returns(string memory){
        require(latestMessage != 0x0000000000000000000000000000000000000000, "There isn't a message in this chat!");
        
        string memory output;
        string memory currentMessageText;
        string memory currentAuthorString;
        address currentMessageAddress = latestMessage;
        address currentAuthor;
        
        Message currentMessage = Message(currentMessageAddress);
            
        while(currentMessageAddress != 0x0000000000000000000000000000000000000000){
            
            currentMessageText = currentMessage.text();
            currentAuthorString = addressToString(currentMessage.author());
            currentAuthor = currentMessage.author();
            
            output = string(abi.encodePacked(output, currentAuthorString," (", messenger.getNickname(currentAuthor),  '): ', currentMessageText, '\n'));
            
            currentMessageAddress = currentMessage.previousMessage();
            currentMessage = Message(currentMessage.previousMessage());
        }
        
        return output;
    }
    
    //Überprüfung ob eine Adresse Mitglied eines Chats ist.
    function isInChat(address _address) public view returns(bool isMember) {
        uint memberIndex = 0;
        while(memberIndex < members.length) {
            if(members[memberIndex] == _address){
                return true;
            }
            memberIndex++;
        }
        return false;
    }
    
    // Funktion um aus einer Adresse einen String zu produzieren
    function addressToString(address _addr) private pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";
    
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    } 
}
