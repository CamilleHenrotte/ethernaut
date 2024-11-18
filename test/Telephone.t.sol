//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Telephone, TelephoneIntermediate} from "../src/Telephone.sol";

contract TestTelephone is Test {
    Telephone public telephone;
    TelephoneIntermediate public telephoneIntermediate;
    address public initialOwner = makeAddr("initialOwner");
    address public newOwner = makeAddr("newOwner");

    function setUp() public {
        vm.prank(initialOwner);
        telephone = new Telephone();
        telephoneIntermediate = new TelephoneIntermediate(address(telephone));
    }
    function testChangeOwner() public {
        assertEq(telephone.owner(), initialOwner);
        telephoneIntermediate.changeOwner(newOwner);
        assertEq(telephone.owner(), newOwner);
    }
}
