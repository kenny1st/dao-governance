
---

### **Example Solidity Contract (`contracts/DAO.sol`)**  
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DAO {
    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) voted;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    IERC20 public governanceToken;

    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, bool support, address voter);
    event ProposalExecuted(uint256 proposalId);

    constructor(address _governanceToken) {
        governanceToken = IERC20(_governanceToken);
    }

    function createProposal(string memory _description) public {
        proposals[proposalCount] = Proposal(_description, 0, 0, false);
        emit ProposalCreated(proposalCount, _description);
        proposalCount++;
    }

    function vote(uint256 _proposalId, bool _support) public {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.voted[msg.sender], "Already voted");

        uint256 votingPower = governanceToken.balanceOf(msg.sender);
        require(votingPower > 0, "No governance tokens");

        if (_support) {
            proposal.votesFor += votingPower;
        } else {
            proposal.votesAgainst += votingPower;
        }

        proposal.voted[msg.sender] = true;
        emit Voted(_proposalId, _support, msg.sender);
    }

    function executeProposal(uint256 _proposalId) public onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Not enough support");

        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }
}
