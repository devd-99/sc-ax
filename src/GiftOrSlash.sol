// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract GiftOrSlash {
    using ECDSA for bytes32;

    address public owner;
    mapping(address => bool) public hasParticipated;
    
    uint256 public constant GIFT_AMOUNT = 0.01 ether;
    uint256 public constant SLASH_AMOUNT = 0.001 ether;

    event ActionExecuted(address indexed user, bool isGift, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function executeAction(address user, bool isGift, bytes memory signature) external payable {
        require(!hasParticipated[user], "User has already participated");
        
        bytes32 messageHash = keccak256(abi.encodePacked("I agree to participate in the slash or gift process"));
        address recovered = ECDSA.recover(
        MessageHashUtils.toEthSignedMessageHash(messageHash),
        signature
        );
        // address signer = ECDSA.recover(recovered, signature);
        
        require(recovered == user, "Invalid signature");

        hasParticipated[user] = true;

        if (isGift) {
            require(address(this).balance >= GIFT_AMOUNT, "Contract doesn't have enough balance for gift");
            (bool success, ) = payable(user).call{value: GIFT_AMOUNT}("");
            require(success, "Gift transfer failed");
            emit ActionExecuted(user, true, GIFT_AMOUNT);
        } else {
            require(msg.value == SLASH_AMOUNT, "Incorrect slash amount sent");
            emit ActionExecuted(user, false, SLASH_AMOUNT);
        }
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    receive() external payable {}
}
