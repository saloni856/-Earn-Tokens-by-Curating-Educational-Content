// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContentCurationPlatform {
    IERC20 public eduToken;  // The ERC20 token contract for rewards

    // Struct to store content information
    struct Content {
        uint id;
        string videoURL;
        address creator;
        uint votesUp;
        uint votesDown;
        uint totalVotes;
        bool isActive;
    }

    // Mapping to store content by its ID
    mapping(uint => Content) public contents;
    uint public contentCount;

    // Events to log actions
    event ContentSubmitted(uint contentId, address creator, string videoURL);
    event Voted(uint contentId, address voter, bool upvote);

    // Constructor to initialize EduToken contract address
    constructor(address _eduTokenAddress) {
        eduToken = IERC20(_eduTokenAddress);
        contentCount = 0;
    }

    // Function to submit a new video/content to the platform
    function submitContent(string memory _videoURL) external {
        contentCount++;
        contents[contentCount] = Content({
            id: contentCount,
            videoURL: _videoURL,
            creator: msg.sender,
            votesUp: 0,
            votesDown: 0,
            totalVotes: 0,
            isActive: true
        });

        emit ContentSubmitted(contentCount, msg.sender, _videoURL);
    }

    // Function to vote on a piece of content (upvote or downvote)
    function vote(uint _contentId, bool _upvote) external {
        require(contents[_contentId].isActive, "Content is not active");

        Content storage content = contents[_contentId];

        if (_upvote) {
            content.votesUp++;
        } else {
            content.votesDown++;
        }

        content.totalVotes++;

        // Reward the voter with EduTokens for voting
        uint rewardAmount = 10 * 10**18;  // Example reward of 10 EDU tokens per vote
        eduToken.transfer(msg.sender, rewardAmount);

        emit Voted(_contentId, msg.sender, _upvote);
    }

    // Finalize the content after sufficient votes
    function finalizeContent(uint _contentId) external {
        Content storage content = contents[_contentId];

        // Only content creator can finalize the content
        require(msg.sender == content.creator, "Only the creator can finalize content");

        // Only finalize if the content has enough votes
        require(content.totalVotes > 0, "Content has no votes");

        uint rewardAmount;
        
        // Reward the creator based on positive votes (e.g., reward for upvotes)
        if (content.votesUp > content.votesDown) {
            rewardAmount = content.votesUp * 100 * 10**18;  // Example reward calculation based on upvotes
            eduToken.transfer(content.creator, rewardAmount);
        }

        // Mark the content as finalized
        content.isActive = false;
    }

    // Get content details by ID
    function getContent(uint _contentId) external view returns (Content memory) {
        return contents[_contentId];
    }
}
