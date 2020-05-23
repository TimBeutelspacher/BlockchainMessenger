pragma solidity >=0.4.0 <0.7.0;


contract Messenger {
    
    uint chatCounter = 0;
    mapping(uint => chat) public chats;  
    mapping(address => string) private users;
    
    struct message {
        string text;
        address author;
    }
    
    struct chat {
        uint chatID;
        uint messageCounter;
        uint memberCounter;
        uint adminCounter;
        mapping(uint => message) messages;
        mapping(uint => address) members;
        mapping(uint => address) admins;
    }
    
    function createChat() public {
       
        chat memory newChat = chat(chatCounter,0,1,1);
        chats[chatCounter] = newChat;
        chats[chatCounter].members[1] = msg.sender;
        chats[chatCounter].admins[1] = msg.sender;
        
        chatCounter += 1;
    }
    
    function createMessage(uint givenChatID, string memory givenText) public {
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
        
        message memory newMessage = message(givenText, msg.sender);
        chats[givenChatID].messages[chats[givenChatID].messageCounter] = newMessage;
        chats[givenChatID].messageCounter += 1;
    }
    
    function getAllMessages(uint givenChatID) view public returns(string memory) {
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        require(chats[givenChatID].messageCounter != 0, "There isn't a message in this chat!");
        require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
        
        
        string memory output;
        string memory currentMessage;
        string memory currentAuthor;
        
        for(uint i = 0; i < chats[givenChatID].messageCounter; i++){
            
            currentMessage = chats[givenChatID].messages[i].text;
            
            currentAuthor = users[chats[givenChatID].messages[i].author];
            
            if(keccak256(abi.encodePacked((currentAuthor))) == keccak256(abi.encodePacked(("")))){
                currentAuthor = addressToString(chats[givenChatID].messages[i].author);
            }
            
            output = string(abi.encodePacked(output, currentAuthor, ': ', currentMessage, '\n'));
            
        }
        
        return output;
    }
    
    function addMember(uint givenChatID, address givenAddress) public {
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
        require(isInChat(givenChatID, givenAddress) == false, "The given Address is already in this Chat!");
        
        chats[givenChatID].memberCounter += 1;
        chats[givenChatID].members[chats[givenChatID].memberCounter] = givenAddress;
    }
    
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
    
    //Funktion um einen Chat zu verlassen.
    function leaveChat(uint givenChatID) public {
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        require(isInChat(givenChatID, msg.sender) == true, "You aren't a member of this chat!");
        
        //Mitglied wird aus dem Mapping der Mitglieder entfernt.
        uint memberIndex = 1;
        while(memberIndex <= chats[givenChatID].memberCounter) {
            if(chats[givenChatID].members[memberIndex] == msg.sender){
                for(memberIndex; memberIndex < chats[givenChatID].memberCounter; memberIndex++){
                    chats[givenChatID].members[memberIndex] = chats[givenChatID].members[memberIndex+1];
                }
                chats[givenChatID].members[memberIndex+1] = address(0);
                break;
            }
            memberIndex += 1;
        }
        
        chats[givenChatID].memberCounter -= 1;
        
        //Falls das Mitglied ein Admin ist wird dieser Eintrag im Mapping gelöscht.
        uint adminIndex = 1;
        while(adminIndex <= chats[givenChatID].adminCounter) {
            if(chats[givenChatID].admins[adminIndex] == msg.sender){
                for(adminIndex; adminIndex < chats[givenChatID].adminCounter; adminIndex++){
                    chats[givenChatID].admins[adminIndex] = chats[givenChatID].admins[adminIndex+1];
                }
                chats[givenChatID].admins[adminIndex+1] = address(0);
                break;
            }
            adminIndex += 1;
        }
        chats[givenChatID].adminCounter -= 1;
        
        //Falls es keinen Admin mehr gibt soll das älteste Mitglied Admin werden.
        if(chats[givenChatID].adminCounter < 1 && chats[givenChatID].memberCounter >= 1){
            this.upgradeMemberToAdmin(givenChatID, chats[givenChatID].members[1]);
            chats[givenChatID].adminCounter += 1;
        }
    }
    
    function setNickname(string memory givenNickname) public {
        users[msg.sender] = givenNickname;
    }
    
    //Funktion um ein Mitglied zu einem Admin eines Chats zu machen.
    function upgradeMemberToAdmin(uint givenChatID, address givenAddress) public {
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
        require(isAdminOfChat(givenChatID, msg.sender), "You aren't a admin of this chat!");
        require(isInChat(givenChatID, givenAddress), "The given Address isn't a member of this chat!"); 
        
        chats[givenChatID].adminCounter += 1;
        chats[givenChatID].admins[chats[givenChatID].adminCounter];
    }
    
    //Funktion zum entfernen eines Miglieds aus einem Chat.
    function removeMemberFromChat(uint givenChatID, address givenAddress) public{
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
        require(isAdminOfChat(givenChatID, msg.sender), "You aren't a admin of this chat!");
        require(isInChat(givenChatID, givenAddress), "The given Address isn't a member of this chat!");
        
        //Mitglied einer Gruppe aus dem Mapping der Gruppenmitglieder entfernen.
        uint memberIndex = 1;
        while(memberIndex <= chats[givenChatID].memberCounter) {
            if(chats[givenChatID].members[memberIndex] == givenAddress){
                for(memberIndex; memberIndex < chats[givenChatID].memberCounter; memberIndex++){
                    chats[givenChatID].members[memberIndex] = chats[givenChatID].members[memberIndex+1];
                }
                chats[givenChatID].members[memberIndex+1] = address(0);
                break;
            }
            memberIndex += 1;
        }
        chats[givenChatID].memberCounter -= 1;
        
        //Falls das Mitglied ein Admin ist wird dieser Eintrag im Mapping gelöscht.
        uint adminIndex = 1;
        while(adminIndex <= chats[givenChatID].adminCounter) {
            if(chats[givenChatID].admins[adminIndex] == givenAddress){
                chats[givenChatID].adminCounter -= 1;
                for(adminIndex; adminIndex < chats[givenChatID].adminCounter; adminIndex++){
                    chats[givenChatID].admins[adminIndex] = chats[givenChatID].admins[adminIndex+1];
                }
                chats[givenChatID].admins[adminIndex+1] = address(0);
                break;
            }
            adminIndex += 1;
        }
        chats[givenChatID].adminCounter -= 1;
    }
    
    //Überprüfung ob ein Mitglied ein Admin ist.
    function isAdminOfChat(uint givenChatID, address givenMember) view internal returns (bool isAdmin){
        require(isInChat(givenChatID, givenMember));
        
        uint adminIndex = 1;
        
        while(adminIndex <= chats[givenChatID].adminCounter) {
            if(chats[givenChatID].admins[adminIndex] == givenMember){
                return true;
            }
            adminIndex += 1;
        }
        return false;
    }
    
    //Überprüfung ob eine Adresse Mitglied eines Chats ist.
    function isInChat(uint givenChatID, address givenAuthor) view internal returns(bool isMember) {
        
        uint memberIndex = 1;
        
        while(memberIndex <= chats[givenChatID].memberCounter) {
            if(chats[givenChatID].members[memberIndex] == givenAuthor){
                return true;
            }
            memberIndex += 1;
        }
        return false;
    }
}
