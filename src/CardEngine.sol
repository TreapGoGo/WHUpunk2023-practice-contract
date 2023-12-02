// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Card} from "./Card.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {console} from "forge-std/console.sol";

contract CardEngine is Ownable, VRFConsumerBaseV2 {
    /* Errors */

    error CardEngine__NotEnoughTimesHasPassedSinceLastMint(address minter, uint256 timeUntilNextMint);
    error CannotDrawBecauseAMinterIsWaitingForSerialNumberCallback();

    /* State variables */

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 3;

    Card private card;

    uint256 immutable i_timeInterval;
    string[] public s_cardUriArray;
    mapping(address => uint256) public addressToLastMintTimestamp;
    mapping(address => uint256[]) public addressToSerialNumberArrayReadyToMint;

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address private s_nowMinter;
    bool private s_canDraw;

    /* Events */

    event RequestedRandomWords(uint256 indexed requestId);

    /* Modifiers */

    modifier enoughTimeHasPassed(address minter) {
        uint256 timeHasPassed = block.timestamp - addressToLastMintTimestamp[minter];
        if (timeHasPassed < i_timeInterval) {
            revert CardEngine__NotEnoughTimesHasPassedSinceLastMint(minter, i_timeInterval - timeHasPassed);
        }
        _;
    }

    modifier canDraw() {
        if (!s_canDraw) {
            revert CannotDrawBecauseAMinterIsWaitingForSerialNumberCallback();
        }
        _;
    }

    constructor(
        string[] memory cardUriArray,
        uint256 timeInterval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) Ownable(msg.sender) VRFConsumerBaseV2(vrfCoordinator) {
        s_cardUriArray = cardUriArray;
        i_timeInterval = timeInterval;

        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_canDraw = true;
    }

    /**
     * Call this funtion to draw 3 serial numbers
     * @param minterAddress the receiver of the serial numbers
     */
    function draw(address minterAddress) public enoughTimeHasPassed(minterAddress) canDraw {
        addressToLastMintTimestamp[minterAddress] = block.timestamp;
        s_nowMinter = minterAddress;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, i_subscriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS
        );
        s_canDraw = false;
        emit RequestedRandomWords(requestId);
    }

    /**
     * The chainlink VRF coordinator will call this function to input random words
     * @param randomWords the random word array given by the VRF coordinator
     */
    function fulfillRandomWords(uint256, /* requestId */ uint256[] memory randomWords) internal override {
        console.log("!!!!!!!!fulfillRandomWords Called!!!");
        for (uint256 i = 0; i < 3; i++) {
            addressToSerialNumberArrayReadyToMint[s_nowMinter].push(randomWords[i] % s_cardUriArray.length);
        }
        s_canDraw = true;
    }

    function mint(address minterAddress) public {
        // console.log(
        //     "Serial number array ready to mint LENGTH: ", addressToSerialNumberArrayReadyToMint[minterAddress].length
        // );
        while (addressToSerialNumberArrayReadyToMint[minterAddress].length > 0) {
            uint256 mintSerialNumber = addressToSerialNumberArrayReadyToMint[minterAddress][addressToSerialNumberArrayReadyToMint[minterAddress]
                .length - 1];

            // console.log("Ready to enter card.mintNft()");
            // console.log("Minter address: ", minterAddress);
            // console.log("Mint serial number: ", mintSerialNumber);
            card.mintNft(minterAddress, mintSerialNumber);

            // console.log("Mint completed");
            addressToSerialNumberArrayReadyToMint[minterAddress].pop();
            // console.log("Serial number ", mintSerialNumber, " has been minted");
        }
    }

    function setCardAddress(address cardAddress) public onlyOwner {
        card = Card(cardAddress);
    }

    function transferCardOwnership(address newEngine) public onlyOwner {
        card.transferOwnership(newEngine);
    }

    function getCardUriBySerialNumber(uint256 _serialNumber) public view returns (string memory) {
        return s_cardUriArray[_serialNumber];
    }

    function getLastMintTimeStampByAddress(address _address) public view returns (uint256) {
        return addressToLastMintTimestamp[_address];
    }

    function getSerialNumberArrayReadyToMintByAddress(address _address) public view returns (uint256[] memory) {
        return addressToSerialNumberArrayReadyToMint[_address];
    }
}
