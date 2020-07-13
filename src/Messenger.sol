pragma solidity ^0.6.6;

import "./Chat.sol";
import "./User.sol";
import "./Message.sol";

contract Messenger {
    
    //Variablen
    Chat[] private chats;
    mapping (address => User) private user;
    address[] private msgAddresses;
    
    //Funktion zum erstellen eines Chats
    function createChat() public userExists(msg.sender){
        Chat chat = new Chat(this, chats.length, msg.sender);
        chats.push(chat);
        user[msg.sender].setChatCertified();
    }
    
    //Funktion um sich die Addresse eines Chats ausgeben zu lassen.
    function getChat(uint _chatId) public view returns(address){
        require (_chatId < chats.length, "The Chat with the given ChatID doesn't exist yet!");
        return address(chats[_chatId]);
    }
    
    //Funktion um sich ein Zertifakt zu erstellen.
    function createCertificate() public userExists(msg.sender) {
        require (keccak256(abi.encodePacked((user[msg.sender].getNickname()))) != keccak256(abi.encodePacked(("NoName"))), "You haven't completed all tasks yet!");
        require (user[msg.sender].getChatCertified() == true, "You haven't completed all tasks yet!");
        require (checkMessageCertified() == true, "You haven't completed all tasks yet!");

        user[msg.sender].createCertificate();
    }
    
    function getMyChats() public view returns(string memory){
        
        string memory output = "";
        
        Chat tempChat;
        for(uint i = 0; i < chats.length; i++){
            
            tempChat = chats[i];
            
            if(tempChat.isInChat(msg.sender)){
                
                 output = string(abi.encodePacked(output, "ChatID: ", uint2str(i), " | "));
                 output = string(abi.encodePacked(output, "\n"));
            }
        }
        
        if(keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("")))){
            output = "You are in no group yet!";
        }
        
        return output;
    }
    
    //Funktion, um das Zertifakt eines Users zu erstellen.
    function getCertificate(address _address) public view returns(address){
        return user[_address].getCertificate();
    }
    
    //Funktion um sich einen Nicknamen zu erstellen.
    function setNickname(string memory _nickname) public userExists(msg.sender){
        user[msg.sender].setNickname(_nickname);
    }
    
    //Funktion um sich den Nicknamen einer Adresse ausgeben zu lassen.
    function getNickname(address _address) public view returns (string memory){
        if (address(user[_address]) == 0x0000000000000000000000000000000000000000){
            return "NoName";
        }
        return user[_address].getNickname();
    }
    
    //Funktion zum Überprüfen, ob ein Nutzer das Schlüsselwort in den Chat mit der ChatID 0 geschrieben hat!
    function checkMessageCertified() private view returns (bool){
        Message currentMessage = Message(chats[0].getLatestMessage());
        while(address(currentMessage) != 0x0000000000000000000000000000000000000000){
            if (msg.sender == currentMessage.author() && (keccak256(abi.encodePacked((currentMessage.text()))) == keccak256(abi.encodePacked(("HdMBlockchain20"))))){
                return true;
            }
            currentMessage = Message(currentMessage.previousMessage());
        }
        return false;
    }
    
    //Prüft, ob schon ein User Contract für den Nutzer besteht.
    modifier userExists(address _address){
        if(address(user[msg.sender]) == 0x0000000000000000000000000000000000000000){
            User newUser = new User(_address);
            user[msg.sender] = newUser;
            _;
        } else{
            _;
        }
    }
    
    // Funktion um aus einem uint einen String zu produzieren
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
