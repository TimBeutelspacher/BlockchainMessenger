pragma solidity ^0.6.6;

contract Message {
    
    //Variablen
    string public text;
    address public author;
    address public previousMessage;
    
    //Konstruktor
    constructor(string memory _text, address _author, address _previousMessage) public{
        text = _text;
        author = _author;
        previousMessage = _previousMessage;
    }
}
