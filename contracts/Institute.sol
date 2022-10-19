// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./InstituteCT.sol";

contract Institute is ERC721, ERC721URIStorage, Ownable, ERC721Burnable, InstituteCT {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(address => bool) private students;

    constructor(address[] memory studentAddr, address genericHandler_) ERC721("StudentToken", "STK") InstituteCT(genericHandler_) {
        for(uint i=0;i<studentAddr.length;i++) {
            approveStudent(studentAddr[i]);
        }
    }

    modifier onlyApproved() {
        require(msg.sender == owner() || students[msg.sender], "You are not approved");
        _;
    }

    function approveStudent(address studentAddr) public view onlyOwner {
        students[studentAddr] == true;
    }

    function safeMint(address to, string memory uri) public onlyApproved {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) 
        public view virtual override(ERC721, ERC165, IERC165) 
        returns (bool) {}
}
