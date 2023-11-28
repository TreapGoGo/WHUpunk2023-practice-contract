// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Card} from "../../src/Card.sol";
import {CardEngine} from "../../src/CardEngine.sol";
import {DeployCardAndCardEngine} from "../../script/DeployCardAndCardEngine.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract CardAndCardEngineTest is Test {
    constructor() {}

    function setUp() public {}
}
