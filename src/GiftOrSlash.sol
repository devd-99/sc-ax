// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GiftOrSlash {
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

    function executeAction(bool isGift) external payable {
        // require(!hasParticipated[msg.sender], "User has already participated");

        hasParticipated[msg.sender] = true;

        if (isGift) {
            require(address(this).balance >= GIFT_AMOUNT, "Contract doesn't have enough balance for gift");
            (bool success, ) = payable(msg.sender).call{value: GIFT_AMOUNT}("");
            require(success, "Gift transfer failed");
            emit ActionExecuted(msg.sender, true, GIFT_AMOUNT);
        } else {
            require(msg.value == SLASH_AMOUNT, "Incorrect slash amount sent");
            emit ActionExecuted(msg.sender, false, SLASH_AMOUNT);
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


// 4cb67d93b67f48dc8afa0937a5ba0325
// forge create --rpc-url https://sepolia.infura.io/v3/4cb67d93b67f48dc8afa0937a5ba0325 --private-key 93fd699e667e29e9d6bf570ec85657c015acf75b4ea6ea905f91774b4d9fd25f  src/GiftOrSlash.sol:GiftOrSlash

// cast send --rpc-url https://sepolia.infura.io/v3/4cb67d93b67f48dc8afa0937a5ba0325 --private-key 93fd699e667e29e9d6bf570ec85657c015acf75b4ea6ea905f91774b4d9fd25f 0xA6FEdBCD721836d273Ea3B01D934325BFc6BfFEb --function executeAction --params true