pragma solidity >=0.4.0 <0.7.0;

import "./Message.sol";
import "./MessengerTest.sol";

contract Chat{
    
    uint public chatID;
    Message[] public messages;
    address[] public members;
    MessengerTest public messengerTest;
    
    // muss payable sein??
    constructor(uint _chatID) public payable {
        chatID = _chatID;
        messengerTest = MessengerTest(msg.sender);
    }
    
    /*
        Message-Funktionen
    */
    
    function createMessage(string memory _message) public {
        
        Message message = new Message(_message, msg.sender);
        messages.push(message);
        
        if(keccak256(abi.encodePacked((_message))) == keccak256(abi.encodePacked((messengerTest.keyword)))) {
            messengerTest.setMessageCertified(msg.sender);
        }
        
    }
    
    function getLatestMessage() public view returns(string memory) {
        return messages[messages.length-1].message();
    }
    
    
    /*
        Member-Funktionen
    */
    
    function addMember(address _address) public {
        require(!isInChat(_address), "You are already a member of this Chat!");
        members.push(_address);
    }
    
    function deleteMember(address _address) public {
        
        uint memberIndex = 0;
        
        while(memberIndex < members.length) {
            if(members[memberIndex] == _address){
                for(memberIndex; memberIndex < members.length; memberIndex++){
                    members[memberIndex] = members[memberIndex+1];
                }
                members[memberIndex+1] = address(0);
                break;
            }
            memberIndex += 1;
        }
    }
    
    
    /*
        Hilfsfunktionen
    */
    
    function isInChat(address _member) view public returns(bool isMember) {
        uint memberIndex = 0;
        while(memberIndex < members.length) {
            if(members[memberIndex] == _member){
                return true;
            }
            memberIndex += 1;
        }
        return false;
    }
    
    
    /*function getAllMessages() public view returns(string memory) {
        
        string memory output;
        string memory currentMessage;
        string memory currentAuthor;
        
        
        for (uint i=0; i<messages.length; i++)
            
            currentMessage = messages[i].text;
            
            currentAuthor = "s";
            
            if(keccak256(abi.encodePacked((currentAuthor))) == keccak256(abi.encodePacked(("")))){
                currentAuthor = addressToString(chats[givenChatID].messages[i].author);
            }
            
            output = string(abi.encodePacked(output, currentAuthor, ': ', currentMessage, '\n'));
        }
        
        return output;
        
        
    }
    */
}
