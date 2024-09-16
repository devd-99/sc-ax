// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/GiftOrSlash.sol";

contract GiftOrSlashTest is Test {
    GiftOrSlash public giftOrSlash;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        
        vm.prank(owner);
        giftOrSlash = new GiftOrSlash();
        
        // Fund the contract
        vm.deal(address(giftOrSlash), 1 ether);
    }

    function testDeployment() public {
        assertEq(giftOrSlash.owner(), owner);
    }

    function testGift() public {
        uint256 initialBalance = user1.balance;

        vm.prank(user1);
        giftOrSlash.executeAction(true);

        assertEq(user1.balance, initialBalance + 0.01 ether);
        assertTrue(giftOrSlash.hasParticipated(user1));
    }

    function testSlash() public {
        vm.deal(user1, 1 ether);
        uint256 initialBalance = user1.balance;

        vm.prank(user1);
        giftOrSlash.executeAction{value: 0.001 ether}(false);

        assertEq(user1.balance, initialBalance - 0.001 ether);
        assertTrue(giftOrSlash.hasParticipated(user1));
    }

    function testCannotParticipatetwice() public {
        vm.prank(user1);
        giftOrSlash.executeAction(true);

        vm.expectRevert("User has already participated");
        vm.prank(user1);
        giftOrSlash.executeAction(true);
    }

    function testIncorrectSlashAmount() public {
        vm.expectRevert("Incorrect slash amount sent");
        vm.prank(user1);
        giftOrSlash.executeAction{value: 0.002 ether}(false);
    }

    function testWithdraw() public {
        uint256 initialBalance = owner.balance;
        
        vm.prank(owner);
        giftOrSlash.withdraw();

        assertEq(owner.balance, initialBalance + 1 ether);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        giftOrSlash.withdraw();
    }
}