// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GatekeeperOne, GatekeeperOneEntrance} from "../src/GatekeeperOne.sol";

contract TestGateKeeperOne is Test {
    GatekeeperOne public gatekeeperOne;
    GatekeeperOneEntrance public gatekeeperOneEntrance;

    function setUp() public {
        gatekeeperOne = new GatekeeperOne();
        gatekeeperOneEntrance = new GatekeeperOneEntrance(
            address(gatekeeperOne)
        );
    }
    function testGateKeeperOne() public {
        uint64 value = uint64(type(uint32).max) + 2;
        bytes8 proof = bytes8(value);
        uint256 gasAmount = 82178;
        address entrant = address(1);

        vm.startPrank(address(gatekeeperOneEntrance), entrant);
        (bool success, ) = address(gatekeeperOne).call{gas: gasAmount}(
            abi.encodeWithSignature("enter(bytes8)", proof)
        );
        vm.stopPrank();
        require(success, "Call failed");
    }
}
