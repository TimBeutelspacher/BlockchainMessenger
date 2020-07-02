pragma solidity ^0.6.6;

import "./Messenger.sol";
import "./AllUsers.sol";

contract Message {
    
    //Variablen
    Messenger private messenger;
    AllUsers private users;
    string public text;
    address private author;
    address private previousMessage;
    
    //Konstruktor
    constructor(Messenger _messenger, AllUsers _users, string memory _text, address _author, address _previousMessage) public{
        messenger = _messenger;
        users = _users;
        text = _text;
        author = _author;
        previousMessage = _previousMessage;
    }
    
    //Funktion um die vorherige Nachricht in diesem Chat sich geben zu lassen.
    function getPreviousMessage() public view returns(address){
        require(previousMessage  != 0x0000000000000000000000000000000000000000, "This is the first message of this chat!");
        return previousMessage;
    }
    
    //Funktion, welche die Adresse des Autors und desen Nicknamen (falls vorhanden) ausgibt.
    function getAuthor() public view returns(string memory){
        string memory output;
        string memory nickname = users.getNickname(author);
        if (keccak256(abi.encodePacked((nickname))) == keccak256(abi.encodePacked(("")))){
            nickname = "NoName";
        }
        output = string(abi.encodePacked(addressToString(author), " (", nickname, ")"));
        return output;
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
