pragma solidity >=0.4.0 <0.7.0;

contract Message{
    address public author;
    string public message;
    uint public chatID;
    address public prevMessage;

    constructor(uint _chatID, string memory _message, address _author, address _prevMessage) public {
        chatID = _chatID;
        message = _message;
        author = _author;
        prevMessage = _prevMessage;
    }
}
