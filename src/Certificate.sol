pragma solidity ^0.6.6;

//Contract welcher erstellt wird, wenn ein Nutzer alle Aufgaben erfüllt hat um sich zu zertifizieren.
contract Certificate {
    string private recipient;
    string private nickname;
    string public message;

    constructor(string memory _nickname, string memory _recipient) public {
        recipient = _recipient;
        nickname = _nickname;
        message = string(abi.encodePacked("The participant ", nickname, " with the address ", recipient, " completed all tasks in the event. Thank you for your participation!"));
        
    }
}
