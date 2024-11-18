// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {Test, console} from "forge-std/Test.sol";
import {NaughtCoin} from "../src/NaughtCoin.sol";

contract TestNaughtCoin is Test {
    NaughtCoin public nc;
    address public player = makeAddr("player");

    modifier checkSolvedByPlayer() {
        vm.startPrank(player);
        _;
        vm.stopPrank();
        _isSolved();
    }

    function setUp() public {
        nc = new NaughtCoin(player);
    }
    function testNaughtCoin() public checkSolvedByPlayer {
        nc.approve(player, nc.INITIAL_SUPPLY());
        nc.transferFrom(player, address(this), nc.INITIAL_SUPPLY());
    }
    function _isSolved() private {
        assertEq(nc.balanceOf(player), 0);
    }
}
