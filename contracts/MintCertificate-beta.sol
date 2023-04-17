// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MintCertificate is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Accomplished Achievement Award", "AAA") {}

    //tokenURI = 'ipfs://QmYC1T7RrUfWwySz2bpwPRtxySVznJCgKCkoB3XMikbKSH/1.png';
    //tokenURI = 'ipfs://QmYC1T7RrUfWwySz2bpwPRtxySVznJCgKCkoB3XMikbKSH/2.png';
    //tokenURI = 'ipfs://QmYC1T7RrUfWwySz2bpwPRtxySVznJCgKCkoB3XMikbKSH/3.png';
    function safeMint(address to, string memory tokenURI) public {
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _tokenIdCounter.increment();
    }

       function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721)
    {
        require(from == address(0), "This is a SBT certificate. You can not transfer it.");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
