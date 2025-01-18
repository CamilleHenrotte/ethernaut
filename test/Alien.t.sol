//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {AlienCodex} from "../src/AlienCodex.sol";

contract TestAlien is Test {
    AlienCodex public alien;
    address public initialOwner = makeAddr("initialOwner");
    address public newOwner = makeAddr("newOwner");

    function setUp() public {
        vm.prank(initialOwner);
        alien = new AlienCodex();
    }
    function testChangeOwner() public {
        assertEq(alien.owner(), initialOwner);
        alien.retract();
        alien.revise(type(uint256).max - keccak256(2) + 1, bytes32(newOwner));
        assertEq(alien.owner(), newOwner);
    }
}
