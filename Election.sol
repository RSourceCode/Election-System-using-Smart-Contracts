// SPDX-License-Identifier: IIT-K
pragma solidity ^0.8.24;

contract Election{
    address owner = msg.sender;

    uint Candidate_ID = 0;
    uint voterIDCount = 0;

    Candidate[] public participating_candidates;
    mapping(address => Voter) public voters;

    struct Candidate{
        string name;
        uint id;
        uint256 votes;
    }

    struct Voter{
        string name;
        address user;
        uint256 id;
        bool eligible;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "Not Authorized");
        _;
    }

// ensures that atleast 2 candidates are added
    constructor(string memory party1, string memory party2){
        addCandidates(party1);
        addCandidates(party2);
    }
//just a helper function to convert string into lowercase
    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
//Function to add candidates ensuring that their name is not registered
    function addCandidates(string memory name) public onlyOwner{
        require(!isCandidateAdded(name));
        participating_candidates.push(Candidate(name, Candidate_ID, 0));
        emit Candidate_Added(name, Candidate_ID);
        Candidate_ID ++;
    }
// Checking if a voter has already registered or not
    function isRegistered(address voter)private view returns(bool ){
        if(voters[voter].user != address(0)){
                return true;
        }
        return false;
    }
// Checking if a candidate is already added or not    
    function isCandidateAdded(string memory name)private view returns(bool ){
        for(uint i = 0; i < participating_candidates.length; i++){
            if(keccak256(abi.encodePacked(_toLower(participating_candidates[i].name))) == keccak256(abi.encodePacked(_toLower(name))))
                return true;
        }
        return false;
    }
// Function to register a new voter
    function registerVoter(string memory name)public{
        require(!isRegistered(msg.sender));
        voters[msg.sender] = Voter(name, msg.sender, voterIDCount, true);
        
    }
// Function to cast votes ensuring that they haven't yet done so
    function castVote(string memory candidateName)public{
        require(voters[msg.sender].eligible);
        voters[msg.sender].eligible = false;
        for(uint i=0 ; i < participating_candidates.length ; i++){
            if(keccak256(abi.encodePacked(_toLower(participating_candidates[i].name))) == keccak256(abi.encodePacked(_toLower(candidateName)))){
                participating_candidates[i].votes += 1;
                emit voteCasted(voters[msg.sender].name, voters[msg.sender].id);
                break;
            }
        }
    }

// Find a winner (In case of equal vote, the person with lesser id wins [NTA jindabaad :)])
    function winningCandidate() public view returns (string memory name){
        uint highest_votes = 0;
        string memory winner_name = "";
        for(uint i=0 ; i < participating_candidates.length ; i++){
            if(participating_candidates[i].votes > highest_votes){
                highest_votes = participating_candidates[i].votes;
                winner_name = participating_candidates[i].name;
            }
        }
        return winner_name;
    }

    event voteCasted(string voter_name, uint voter_ID);
    event Candidate_Added(string candidateName, uint candidateID);
    

}