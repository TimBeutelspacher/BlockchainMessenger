pragma solidity ^0.6.6;

import "./Certificate.sol";

contract AllUsers {
    
    //Variablen
    mapping (address => User) private users;
    mapping (address => Certificate) private certificates;
    
    //User
    struct User {
        string nickname;
        bool messageCertified;
        bool nicknameCertified;
        bool createChatCertified;
        bool joinChatCertified;
        bool isCertified;
    }
    
    //Funktion um sich einen Nicknamen zu geben.
    function setNickname(address _author, string memory _nickname) public {
        users[_author].nickname = _nickname;
        createCertificate(_author);
    }
    
    //Funktion um sich seinen Nicknamen ausgeben zu lassen.
    function getNickname(address _author)public view returns(string memory){
        return users[_author].nickname;
    }
    
    //Getter und Setter für MessageCertified
    function setMessageCertified(address _author)public{
        users[_author].messageCertified = true;
        createCertificate(_author);
    }
    
    function getMessageCertified(address _author)public view returns(bool){
        return users[_author].messageCertified;
    }
    
    //Getter und Setter für NicknameCertified
    function setNicknameCertified(address _author)public{
        users[_author].nicknameCertified = true;
        createCertificate(_author);
    }
    
    function getNicknameCertified(address _author)public view returns(bool){
        return users[_author].nicknameCertified;
    }
    
    //Getter und Setter für CreateChatCertified
    function setCreateChatCertified(address _author)public{
        users[_author].createChatCertified = true;
        createCertificate(_author);
    }
    
    function getCreateChatCertified(address _author)public view returns(bool){
        return users[_author].createChatCertified;
    }
    
    //Getter und Setter für JoinChatCertified
    function setJoinChatCertified(address _author)public{
        users[_author].joinChatCertified = true;
        createCertificate(_author);
    }
    
    function getJoinChatCertified(address _author)public view returns(bool){
        return users[_author].joinChatCertified;
    }
    
    //Erstellt ein Zertifikat sobald der Nutzer alle Aufgaben erfüllt hat.
    function createCertificate(address _author)private{
        uint counter = 0;
        
        if(users[_author].createChatCertified == false){counter++;}
        if(users[_author].joinChatCertified == false){counter++;}
        if(users[_author].messageCertified == false){counter++;}
        if(users[_author].nicknameCertified == false){counter++;}
        
        if(counter == 0){
            if(!users[_author].isCertified){
                
                Certificate certificate = new Certificate(users[_author].nickname, addressToString(_author));
                certificates[_author] = certificate;
                
                users[_author].isCertified = true;
            }
        }
    }
    
    //Funktion um sich das Zertifikat einer Adresse ausgeben zu lassen (falls vorhanden).
    function getCertificate(address _author)public view returns(address){
        require (users[_author].isCertified == true, "You haven't completed all tasks yet!");
        return address(certificates[_author]);
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
