// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {Test, console} from "forge-std/Test.sol";
import {Denial, DenialAttacker} from "../src/Denial.sol";

contract TestDenial is Test {
    address public immutable owner = address(0xA9E);

    Denial public denial;
    DenialAttacker public denialAttacker;

    modifier checkSolvedByAttacker() {
        vm.startPrank(address(denialAttacker));
        _;
        vm.stopPrank();
        _isSolved();
    }

    function setUp() public {
        denial = new Denial();
        denialAttacker = new DenialAttacker(address(denial));
        address(denial).call{value: 100 ether}("");
        denial.setWithdrawPartner(address(denialAttacker));
    }

    function testInitializationState() public {
        assertEq(owner.balance, 0);
        assertEq(denial.contractBalance(), 100 ether);
        denial.withdraw();
        assertEq(owner.balance, 1 ether);
    }

    function testDenail() public checkSolvedByAttacker {
        denial.setWithdrawPartner(address(denialAttacker));
        assertEq(denial.partner(), address(denialAttacker));
    }

    function _isSolved() private {
        vm.prank(owner);
        vm.expectRevert();
        denial.withdraw{gas: 100_000}();
        assertEq(owner.balance, 0);
    }
}
