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

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console} from "forge-std/console.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract Card is ERC721, Ownable {
    /* state variables */
    uint256 private s_tokenCounter;
    string[] public s_cardUriArray;
    mapping(uint256 => string) public s_tokenIdToImageUri;
    mapping(uint256 => uint256) public s_tokenIdToSerialNumber;

    /* events */

    event NftMinted(uint256 indexed tokenId, address indexed ownerAddress, string indexed tokenUri);

    /* functions */

    constructor(address engineAddress, string[] memory cardUriArray)
        ERC721("WHUPunk Testnet Cards", "CARD")
        Ownable(engineAddress)
    {
        s_tokenCounter = 0;
        s_cardUriArray = cardUriArray;
    }

    function mintNft(address recipient, uint256 serialNumber) public /* onlyOwner*/ {
        // console.log("Can enter mintNft");
        s_tokenIdToImageUri[s_tokenCounter] = s_cardUriArray[serialNumber];
        s_tokenIdToSerialNumber[s_tokenCounter] = serialNumber;
        // console.log("Can run to mintNFT before _safeMint()");
        _safeMint(recipient, s_tokenCounter);
        s_tokenCounter++;
        emit NftMinted(s_tokenCounter, recipient, s_cardUriArray[serialNumber]);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageUri = s_tokenIdToImageUri[tokenId];
        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description":"WHUpunk NFT Testnet Card", ',
                            '"attributes": [{"serial_number": "',
                            Strings.toString(s_tokenIdToSerialNumber[tokenId]),
                            '"}], "image":"',
                            imageUri,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function tokenSerialNumber(uint256 tokenId) public view returns (uint256) {
        return s_tokenIdToSerialNumber[tokenId];
    }

    function addressBalance(address user) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](s_tokenCounter);
        uint256 counter = 0;
        for (uint256 tokenId = 0; tokenId < s_tokenCounter; tokenId++) {
            if (_ownerOf(tokenId) == user) {
                result[counter] = tokenSerialNumber(tokenId);
                counter++;
            }
        }
        return result;
    }
}
