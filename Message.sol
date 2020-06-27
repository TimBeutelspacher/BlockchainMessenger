pragma solidity ^0.6.6;

import "./Messenger.sol";

contract Message {
    
    //Variablen
    Messenger private messenger;
    string private value;
    address public author;
    address private previousMessage;
    
    constructor(Messenger _messenger, string memory _value, address _author, address _previousMessage) public{
        messenger = _messenger;
        value = _value;
        author = _author;
        previousMessage = _previousMessage;
    }
    
    //Funktion um die vorherige Nachricht in diesem Chat sich geben zu lassen.
    function getPreviousMessage() public view returns(address){
        require(previousMessage  != 0x0000000000000000000000000000000000000000, "This is the first message of this chat!");
        return previousMessage;
    }
    
    //Funktion um sich den Nicknamen des Authors und die Nachricht ausgeben zu lassen.
    function getMessage() public view returns(string memory){
        string memory output;
        string memory a;
        if (keccak256(abi.encodePacked((messenger.getNickname(author)))) == keccak256(abi.encodePacked((a)))){
            a = "NoName";
        }else{
            a = messenger.getNickname(author);
        }
        output = string(abi.encodePacked(a, ': ', value));
        return output;
    }
}
