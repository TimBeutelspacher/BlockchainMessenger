pragma solidity >=0.4.0 <0.7.0;

import "./Message.sol";
import "./Certificate.sol";
import "./InitMessage.sol";

contract Messenger {
    
    /*
        Variablen
    */
    uint chatCounter = 0;
    mapping(uint => chat) internal chats;  
    mapping(address => user) public users;
    mapping(address => Certificate) internal certificates;
    string private keyword = "HDMBlockchain20";
    Message[] public allMessages;
    

    /*
        Objekt-Strukturen
    */
    struct user{
        string nickname;
        bool messageCertified;
        bool createChatCertified;
        bool joinChatCertified;
        bool nicknameCertified;
        bool certified;
    }
    
    struct chat {
        uint chatID;
        uint memberCounter;
        uint adminCounter;
        address latestMessage;
        address initalMessage;
        mapping(uint => address) members;
        mapping(uint => address) admins;
    }
    
    /*
        Funktionen
    */
    
    // Funktion um einen öffentlichen Chat zu erstellen
    function createChat() public{
        
        string memory firstText = string(abi.encodePacked("Welcome to chat ", uint2str(chatCounter), "."));
        
        // Initialen Message-Contract deployen
        initMessage firstMessage = new initMessage(chatCounter, firstText, msg.sender);
        
        chat memory newChat = chat(chatCounter,1,1, address(firstMessage), address(firstMessage));
        chats[chatCounter] = newChat;
        chats[chatCounter].members[1] = msg.sender;
        chats[chatCounter].admins[1] = msg.sender;
        
        
        users[msg.sender].createChatCertified = true;
        createCertificate();
        
        if(chatCounter == 0){
            users[msg.sender].joinChatCertified = true;
        }
        
        chatCounter += 1;
    }
    
    // Funktion um eine Nachricht in einem Chat zu erstellen
    function createMessage(uint _chatID, string memory _message) public modChatID(_chatID) modMemberOfChat(_chatID, msg.sender) {
        if((keccak256(abi.encodePacked((_message))) == keccak256(abi.encodePacked((keyword)))) && (_chatID == 0)) {
            users[msg.sender].messageCertified = true;
            createCertificate();
        }
        
        Message message = new Message(_chatID, _message, msg.sender, chats[_chatID].latestMessage);
        
        chats[_chatID].latestMessage = address(message);
        
        allMessages.push(message);
    }
    
    // Funktion um alle Nachrichten geordnet aus einem Chat auszulesen
    function getAllMessages(uint _chatID) public view modChatID(_chatID) modMemberOfChat(_chatID, msg.sender) returns(string memory){
        
        string memory output;
        string memory currentMessageText;
        string memory currentAuthor;
        address currentMessageAddress = chats[_chatID].latestMessage;
        
        Message currentMessage = Message(currentMessageAddress);
            
        while(currentMessageAddress != chats[_chatID].initalMessage){
            
            currentMessageText = currentMessage.message();
            currentAuthor = users[currentMessage.author()].nickname;
            
            if(keccak256(abi.encodePacked((currentAuthor))) == keccak256(abi.encodePacked(("")))){
                currentAuthor = addressToString(currentMessage.author());
            }
            
            output = string(abi.encodePacked(output, currentAuthor, ': ', currentMessageText, '\n'));
            currentMessageAddress = currentMessage.prevMessage();
            currentMessage = Message(currentMessage.prevMessage());
        }
        
        if(currentMessageAddress == chats[_chatID].initalMessage){
            output = string(abi.encodePacked(output, initMessage(chats[_chatID].initalMessage).message()));
        }
        
        return output;
    }
    
    // Funktion um einem Chat ein Mitglied hinzuzufügen
    function addMember(uint givenChatID, address givenAddress) internal modChatID(givenChatID) modMemberOfChat(givenChatID, msg.sender)
        modMemberOfChat(givenChatID, givenAddress){
        chats[givenChatID].memberCounter += 1;
        chats[givenChatID].members[chats[givenChatID].memberCounter] = givenAddress;
    }
    
    //Funktion um einen Chat zu verlassen.
    function leaveChat(uint givenChatID) public modChatID(givenChatID) modMemberOfChat(givenChatID, msg.sender){
        
        //Mitglied wird aus dem Mapping der Mitglieder entfernt.
        uint memberIndex = 1;
        while(memberIndex <= chats[givenChatID].memberCounter) {
            if(chats[givenChatID].members[memberIndex] == msg.sender){
                for(memberIndex; memberIndex < chats[givenChatID].memberCounter; memberIndex++){
                    chats[givenChatID].members[memberIndex] = chats[givenChatID].members[memberIndex+1];
                }
                chats[givenChatID].memberCounter -= 1;
                chats[givenChatID].members[memberIndex+1] = address(0);
                break;
            }
            memberIndex += 1;
        }
        
        //Falls das Mitglied ein Admin ist wird dieser Eintrag im Admin-Mapping gelöscht.
        uint adminIndex = 1;
        while(adminIndex <= chats[givenChatID].adminCounter) {
            if(chats[givenChatID].admins[adminIndex] == msg.sender){
                for(adminIndex; adminIndex < chats[givenChatID].adminCounter; adminIndex++){
                    chats[givenChatID].admins[adminIndex] = chats[givenChatID].admins[adminIndex+1];
                }
                chats[givenChatID].adminCounter -= 1;
                chats[givenChatID].admins[adminIndex] = address(0);
                break;
            }
        adminIndex += 1;
        }
        
        //Falls es keinen Admin mehr gibt soll das älteste Mitglied Admin werden.
        if(chats[givenChatID].adminCounter < 1 && chats[givenChatID].memberCounter >= 1){
            chats[givenChatID].admins[1] = chats[givenChatID].members[1];
            chats[givenChatID].adminCounter = 1;
        }
    }
    
    // Funktion um einem öffentlichen Chat beizutreten
    function joinChat(uint givenChatID) public modChatID(givenChatID){
        require(isInChat(givenChatID, msg.sender) == false, "You are already in this chat!");
        
        if(givenChatID == 0){
            users[msg.sender].joinChatCertified = true;
            createCertificate();
        }
        
        chats[givenChatID].memberCounter += 1;
        chats[givenChatID].members[chats[givenChatID].memberCounter] = msg.sender;
    }
    
    // Funktion um einen Nicknamen zu setzen
    function setNickname(string memory givenNickname) public {
        users[msg.sender].nickname = givenNickname;
        users[msg.sender].nicknameCertified = true;
        createCertificate();
    }
    
    //Funktion um ein Mitglied zu einem Admin eines Chats zu machen.
    function upgradeMemberToAdmin(uint givenChatID, address givenAddress) internal modChatID(givenChatID) modMemberOfChat(givenChatID, msg.sender)
        modAdminOfChat(givenChatID, msg.sender) modAdminOfChat(givenChatID, givenAddress) modMemberOfChat(givenChatID, givenAddress){
            
        chats[givenChatID].adminCounter += 1;
        chats[givenChatID].admins[chats[givenChatID].adminCounter] = givenAddress;
    }
    
    //Funktion zum entfernen eines Miglieds aus einem Chat.
    function removeMemberFromChat(uint givenChatID, address givenAddress) internal modChatID(givenChatID) 
        modMemberOfChat(givenChatID, msg.sender) modAdminOfChat(givenChatID, msg.sender) modMemberOfChat(givenChatID, givenAddress){
        
        //Mitglied wird aus dem Mapping der Mitglieder entfernt.
        uint memberIndex = 1;
        while(memberIndex <= chats[givenChatID].memberCounter) {
            if(chats[givenChatID].members[memberIndex] == givenAddress){
                for(memberIndex; memberIndex < chats[givenChatID].memberCounter; memberIndex++){
                    chats[givenChatID].members[memberIndex] = chats[givenChatID].members[memberIndex+1];
                }
                chats[givenChatID].memberCounter -= 1;
                chats[givenChatID].members[memberIndex+1] = address(0);
                break;
            }
            memberIndex += 1;
        }
        
        //Falls das Mitglied ein Admin ist wird dieser Eintrag im Admin-Mapping gelöscht.
        uint adminIndex = 1;
        while(adminIndex <= chats[givenChatID].adminCounter) {
            if(chats[givenChatID].admins[adminIndex] == givenAddress){
                for(adminIndex; adminIndex < chats[givenChatID].adminCounter; adminIndex++){
                    chats[givenChatID].admins[adminIndex] = chats[givenChatID].admins[adminIndex+1];
                }
                chats[givenChatID].adminCounter -= 1;
                chats[givenChatID].admins[adminIndex] = address(0);
                break;
            }
        adminIndex += 1;
        }
    }
    
    // Funktion um alle Chats eines Nutzers auszugeben
    function getMyChats() view public returns(string memory){
        
        string memory output = "";
        
        for(uint i = 0; i < chatCounter; i++){
            if(isInChat(i,msg.sender)){
                
                 output = string(abi.encodePacked(output, "ChatID: ", uint2str(i), " | "));
                 output = string(abi.encodePacked(output, "\n"));
            }
        }
        
        if(keccak256(abi.encodePacked((output))) == keccak256(abi.encodePacked(("")))){
            output = "You are in no group yet!";
        }
        
        return output;
    }

    //Funktion um alle Adressen und Nicknamen der Chatmitglieder auszugeben.
    function getMembersOfChat(uint givenChatID) internal view modChatID(givenChatID) modMemberOfChat(givenChatID, msg.sender) returns(string memory){
        uint memberIndex = 1;
        string memory output = "";
        string memory currentNickname;
        string memory currentAddress;
        
        while(memberIndex <= chats[givenChatID].memberCounter) {
            
            currentAddress = addressToString(chats[givenChatID].members[memberIndex]);
            
            currentNickname = users[chats[givenChatID].members[memberIndex]].nickname;
            
            if(keccak256(abi.encodePacked((currentNickname))) == keccak256(abi.encodePacked(("")))){
                currentNickname = "NoName";
            }
            
            output = string(abi.encodePacked(output, currentAddress, " (", currentNickname ,") | "));
            memberIndex += 1;
        }
        return output;
    }
    
    //Funktion, welche den Fortschritt der Zertifizierungsaufgaben einer Adresse ausgibt.
    function checkCertificationProgress(address givenAddress) view public returns (string memory) {
        uint counter = 0;
        
        if(users[givenAddress].createChatCertified == false){counter++;}
        if(users[givenAddress].joinChatCertified == false){counter++;}
        if(users[givenAddress].messageCertified == false){counter++;}
        if(users[givenAddress].nicknameCertified == false){counter++;}
        
        if(counter == 0){
            return string(abi.encodePacked("Congratulations! Your certificate has been created at this address: ", addressToString(address(certificates[msg.sender]))));
        }else{
            string memory output = string(abi.encodePacked("You still have ", uint2str(counter), " task/s to do. Check the progress at 'users' by entering your address."));
            return output;
        }
    }
    
    function createCertificate() internal{
        uint counter = 0;
        
        if(users[msg.sender].createChatCertified == false){counter++;}
        if(users[msg.sender].joinChatCertified == false){counter++;}
        if(users[msg.sender].messageCertified == false){counter++;}
        if(users[msg.sender].nicknameCertified == false){counter++;}
        
        if(counter == 0){
            if(!users[msg.sender].certified){
                
                Certificate certificate = new Certificate(users[msg.sender].nickname, addressToString(msg.sender));
                certificates[msg.sender] = certificate;
                
                users[msg.sender].certified = true;
            }
        }
    }
    
    /*
        Hilfsfunktionen
    */
    
    //Überprüfung ob ein Mitglied ein Admin ist.
    function isAdminOfChat(uint givenChatID, address givenAddress) view internal modMemberOfChat(givenChatID, givenAddress) returns (bool isAdmin){
        uint adminIndex = 1;
        while(adminIndex <= chats[givenChatID].adminCounter) {
            if(chats[givenChatID].admins[adminIndex] == givenAddress){
                return true;
            }
            adminIndex += 1;
        }
        return false;
    }
    
    //Überprüfung ob eine Adresse Mitglied eines Chats ist.
    function isInChat(uint givenChatID, address givenMember) view internal returns(bool isMember) {
        uint memberIndex = 1;
        while(memberIndex <= chats[givenChatID].memberCounter) {
            if(chats[givenChatID].members[memberIndex] == givenMember){
                return true;
            }
            memberIndex += 1;
        }
        return false;
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
    
   
    /*
         Modifier
    */
    
    //Überprüfung ob es bereits einen Chat mit der gegebenen ChatID gibt.
    modifier modChatID (uint givenChatID){
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        _;
    }
    
    //Überprüfung ob der Sender oder die übergebene Adresse der Transaktion in dem gegebenen Chat ist.
    modifier modMemberOfChat(uint givenChatID, address givenAddress){
        if(givenAddress == msg.sender){
            require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
            _;
        }else{
            require(isInChat(givenChatID, givenAddress), "The given Address isn't a member of this chat!"); 
            _;
        }
    }
    
    //Überprüfung ob der Sender oder die in der Transaktion übergebene Adresse ein Admin des gegebenen Chats ist.
    modifier modAdminOfChat(uint givenChatID, address givenAddress){
        if(givenAddress == msg.sender){
           require(isAdminOfChat(givenChatID, msg.sender), "You aren't a admin of this chat!");
            _; 
        }else{
            require(isAdminOfChat(givenChatID, givenAddress) == false, "The given Address is already a Admin!");
            _;
        }
    }
}
