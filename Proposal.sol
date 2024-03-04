// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract ProposalContract {
    uint256 private counter;
    address private owner;
    mapping(uint256 => Proposal) public proposal_history;

    mapping(address => uint256) private lastVotedProposal;

    struct Proposal {
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool is_active;
        bool is_accepted;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProposal(string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        require(!proposal_history[counter].is_active || counter == 0,"Existing proposal still active.");
        counter++;
        proposal_history[counter] = Proposal(_description,0,0,0,_total_vote_to_end,true,false);
    }

    function vote(uint8 choice) external activeProposal hasNotVoted {
        require(choice >= 0 && choice <= 2, "Invalid vote option.");
        Proposal storage proposal = proposal_history[counter];
        lastVotedProposal[msg.sender] = counter;

        if (choice == 1) proposal.approve++;
        else if (choice == 2) proposal.reject++;
        else if (choice == 0) proposal.pass++;

        if (proposal.approve + proposal.reject + proposal.pass >= proposal.total_vote_to_end) {
            proposal.is_active = false;
            if (proposal.approve > proposal.reject + proposal.pass) {
                proposal.is_accepted = true;
            }
        }
    }

    function terminateProposal() external onlyOwner activeProposal {
        proposal_history[counter].is_active = false;
    }

    function getProposal(uint256 number) external view returns (Proposal memory) {
        require(number <= counter && number > 0, "Proposal does not exist.");
        return proposal_history[number];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You're not the owner.");
        _;
    }
    modifier activeProposal() {
        require(proposal_history[counter].is_active, "No active proposal.");
        _;
    }
    modifier hasNotVoted() {
        require(lastVotedProposal[msg.sender] < counter, "Address has already voted.");
        _;
    }
