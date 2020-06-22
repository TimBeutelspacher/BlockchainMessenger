pragma solidity >=0.4.0 <0.7.0;

contract Certificate{
    string public recipient;
    string public nickname;
    string public message;

    constructor(string memory _nickname, string memory _recipient) public {
        recipient = _recipient;
        nickname = _nickname;
        message = string(abi.encodePacked("The participant ", nickname, " with the address ", recipient, " completed all tasks in the event. Thank you for your participation!"));
        
    }
}
