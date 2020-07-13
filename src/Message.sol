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
    
    //Funktion um die vorherige Nachricht in diesem Chat sich geben zu lassen.
    function getPreviousMessage() public view returns(address){
        require(previousMessage  != 0x0000000000000000000000000000000000000000, "This is the first message of this chat!");
        return previousMessage;
    }
}
