// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Card} from "../../src/Card.sol";
import {CardEngine} from "../../src/CardEngine.sol";
import {DeployCardAndCardEngine} from "../../script/DeployCardAndCardEngine.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CardAndCardEngineTest is Test {
    CardEngine public cardEngine;
    Card public card;
    HelperConfig public helperConfig;
    uint256 public mintTimeInterval;
    bool public onAnvil;
    address public vrfCoordinator;

    address public USER = makeAddr("user");

    constructor() {}

    modifier timeWarpForOneYear() {
        if (onAnvil && block.timestamp <= 1000) {
            vm.warp(365 days);
        }
        _;
    }

    function setUp() public {
        DeployCardAndCardEngine deployer = new DeployCardAndCardEngine();
        (card, cardEngine, helperConfig) = deployer.run();
        (, mintTimeInterval,, onAnvil, vrfCoordinator,,,,) = helperConfig.activeNetworkConfig();
    }

    /////////////////////////////////////
    // mint                            //
    /////////////////////////////////////
    function testCanMint() public timeWarpForOneYear {
        vm.startPrank(USER);
        vm.recordLogs();
        cardEngine.draw(USER);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        // pretend to be chainlink vrf to get random number & pick winner
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(cardEngine));

        cardEngine.mint(USER);
        console.log("USER nft balance: ", card.addressBalance(USER).length);
        assert(card.addressBalance(USER).length == 3);
    }
}
