pragma solidity ^0.6.6;

contract User {
    string private nickname;
    
    function setNickname(string memory _nickname) public {
        nickname = _nickname;
    }
    
    function getNickname()public view returns(string memory){
        return nickname;
    }
}
