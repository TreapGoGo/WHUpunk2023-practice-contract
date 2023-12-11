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

contract NftSimulator is ERC721, Ownable {
    uint256 private s_tokenCounter;
    string[] public s_imageUriArray;
    mapping(uint256 => string) private s_tokenIdToImageUri;

    event NftMinted(uint256 indexed tokenId, address indexed ownerAddress, string indexed tokenUri);

    constructor(string[] memory imageUriArray) ERC721("WHUPunk NFT simulator", "CARD") Ownable(msg.sender) {
        s_tokenCounter = 0;
        s_imageUriArray = imageUriArray;
    }

    function mintNft() public returns (uint256 tokenIdMinted) {
        tokenIdMinted = s_tokenCounter;
        s_tokenIdToImageUri[s_tokenCounter] = s_imageUriArray[s_tokenCounter];
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
        emit NftMinted(s_tokenCounter, msg.sender, s_imageUriArray[s_tokenCounter]);
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
                            '", "description":"WHUpunk NFT Simulator. Just for fun!", ',
                            '"image":"',
                            imageUri,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}
