pragma solidity ^0.6.6;

import "./Certificate.sol";

contract User {
    
    //Variablen
    address private author;
    string private nickname;
    Certificate private certificate;
    bool private chatCertified;
    
    constructor (address _address) public{
        author = _address;
        nickname = "NoName";
    }
    
    //Nicknamen setzen
    function setNickname (string memory _nickname) public{
        nickname = _nickname;
    }
    
    //Nicknamen ausgeben
    function getNickname() public view returns (string memory){
        return nickname;
    }
    
    function createCertificate() public{
        require (address(certificate) == 0x0000000000000000000000000000000000000000, "You already created a certificate!");
        Certificate newCertificate = new Certificate(nickname, addressToString(author));
        certificate = newCertificate;
    }
    
    //Adresse des Zertifikats ausgeben
    function getCertificate() public view returns (address){
        require (address(certificate) != 0x0000000000000000000000000000000000000000, "The user hasn't created a certificate yet!");
        return address(certificate);
    }
    
    //Um zu bestätigen, dass der Nutzer einen Chat erstellt hat.
    function setChatCertified () public{
        chatCertified = true;
    }
    
    //Um zu Überprüfen, ob der Nutzer einen Chat erstellt hat.
    function getChatCertified() public view returns (bool){
        return chatCertified;
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
