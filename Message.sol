pragma solidity >=0.4.0 <0.7.0;

contract Message{
    address public author;
    string public message;
    uint public chatID;

    constructor(uint _chatID, string memory _message, address _author) public payable {
        author = _author;
        message = _message;
        chatID = _chatID;
    }
}
