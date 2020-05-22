pragma solidity > 0.4.24;

contract Messenger {
    
    uint chatCounter = 0;
    mapping(uint => chat) public chats;  
    mapping(address => string) public users;
    
    struct message {
        string text;
        address author;
    }
    
    struct chat {
        uint chatID;
        uint messageCounter;
        uint memberCounter;
        mapping(uint => message) messages;
        mapping(uint => address) members;
    }
    
    function createChat() public {
       
        chat memory newChat = chat(chatCounter,0,1);
        chats[chatCounter] = newChat;
        chats[chatCounter].members[1] = msg.sender;
        
        chatCounter += 1;
    }
    
    function createMessage(uint givenChatID, string memory givenText) public {
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
        
        message memory newMessage = message(givenText, msg.sender);
        chats[givenChatID].messages[chats[givenChatID].messageCounter] = newMessage;
        chats[givenChatID].messageCounter += 1;
    }
    
    /*function getLatestMessage(uint givenChatID) view public returns(string memory) {
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        require(chats[givenChatID].messageCounter != 0, "There isn't a message in this chat!");
        require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
        
        return chats[givenChatID].messages[chats[givenChatID].messageCounter - 1].text;
    }*/
    
    function getAllMessages(uint givenChatID) view public returns(string memory) {
        require(givenChatID < chatCounter, "The given ChatID doens't exist yet!");
        require(chats[givenChatID].messageCounter != 0, "There isn't a message in this chat!");
        require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
        
        
        string memory output;
        string memory currentMessage;
        string memory currentAuthor;
        
        for(uint i = 0; i < chats[givenChatID].messageCounter; i++){
            
            currentMessage = chats[givenChatID].messages[i].text;
            //currentAuthor = addressToString(chats[givenChatID].messages[i].author);
            currentAuthor = users[chats[givenChatID].messages[i].author];
            output = string(abi.encodePacked(output, currentAuthor, ': ', currentMessage, '\n'));
            
        }
        
        return output;
    }
    
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
    
    function leaveChat(uint givenChatID) public {
        require(isInChat(givenChatID, msg.sender), "You aren't a member of this chat!");
         
         uint memberIndex = 1;
        
        while(memberIndex <= chats[givenChatID].memberCounter) {
            
            if(chats[givenChatID].members[memberIndex] == msg.sender){
                chats[givenChatID].members[memberIndex] = address(0);
                break;
            }
            
            memberIndex += 1;
        }
        
        chats[givenChatID].memberCounter -= 1;
    }
    
    function setNickname(string memory givenNickname) public {
        
        users[msg.sender] = givenNickname;
        
    }
    
}
