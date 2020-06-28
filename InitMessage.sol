pragma solidity >=0.4.0 <0.7.0;

contract initMessage{
    uint public chatID;
    string public message;
    address public author;
    
    constructor(uint _chatID, string memory _message, address _author) public {
        chatID = _chatID;
        message = _message;
        author = _author;
    }
}
