pragma solidity >=0.4.0 <0.7.0;

import "./Chat.sol";

contract MessengerTest{
    
    //Variablen
    Chat[] public chats;
    mapping(address => user) public users;
    string public keyword = "HDMBlockchain20";
    
    /*
        Objekt-Strukturen
    */
    struct user{
        string nickname;
        bool messageCertified;
        bool createChatCertified;
        bool joinChatCertified;
        bool nicknameCertified;
    }
    
    /*
        Chat-Funktionen
    */
    
    
    //Funktion um einen Chat zu erstellen
    function createChat() public{
        
        Chat chat = new Chat(chats.length);
        chats.push(chat);
        chats[chats.length-1].addMember(msg.sender);
        
        users[msg.sender].createChatCertified = true;
        
        if(chats.length-1 == 0){
            users[msg.sender].joinChatCertified = true;
        }
        
    }
    
    //Funktion um einem bestehenden Chat beizutreten
    function joinChat(uint _chatID) public {
        
        chats[_chatID].addMember(msg.sender);
        
        if(_chatID == 0){
            users[msg.sender].joinChatCertified = true;
        }
        
    }
    
    // Funktion um alle Chats eines Nutzers auszugeben
    function getMyChats() view public returns(string memory){
        
        string memory output = "";
        
        for(uint i = 0; i < chats.length; i++){
            if(chats[i].isInChat(msg.sender)){
                
                 output = string(abi.encodePacked(output, "ChatID: ", uint2str(i), " | "));
                 output = string(abi.encodePacked(output, "\n"));
            }
        }
        
        if(keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("")))){
            output = "You are in no group yet!";
        }
        
        return output;
    }
    
    
    /*
        User-Funktionen
    */
    
    // Funktion um einen Nicknamen zu setzen
    function setNickname(string memory _nickname) public {
        users[msg.sender].nickname = _nickname;
        users[msg.sender].nicknameCertified = true;
    }
    
    /*
        Zertifizierungs-Funktionen
    */
    
    //Funktion, welche den Fortschritt der Zertifizierungsaufgaben einer Adresse ausgibt.
    function checkCertificationProgress(address givenAddress) view public returns (string memory) {
        uint counter = 0;
        
        if(users[givenAddress].createChatCertified == false){counter++;}
        if(users[givenAddress].joinChatCertified == false){counter++;}
        if(users[givenAddress].messageCertified == false){counter++;}
        if(users[givenAddress].nicknameCertified == false){counter++;}
        
        if(counter == 0){
            return "Congratulations! You completed all tasks.";
        }else{
            string memory output = string(abi.encodePacked("You still have ", uint2str(counter), " task/s to do. Check the progress at 'users' by entering your address."));
            return output;
        }
    }
    
    /*
        Hilfsfunktionen
    */
    
    function setMessageCertified(address _address) external {
        users[_address].messageCertified = true;
    }
    
    // Funktion um aus einer Adresse einen String zu produzieren
    function addressToString(address _addr) internal pure returns(string memory) {
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
    
    // Funktion um aus einem uint einen String zu produzieren
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
