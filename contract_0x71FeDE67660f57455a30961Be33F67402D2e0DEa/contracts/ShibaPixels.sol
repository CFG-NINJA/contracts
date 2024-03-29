// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./ERC404/ERC404.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ShibaPixels is ERC404 {
    string public dataURI;
    string public baseTokenURI;
    string public ipfsDefault;
    uint256 internal seed;

    constructor(
        address _owner,
        string memory _dataURI,
        string memory _tokenURI,
        string memory _ipfsDefault,
        uint256 _seed
    ) ERC404("ShibaPixels 404 AI", "SHIBPIXEL", 18, 10000, _owner) {
        balanceOf[_owner] = 10000 * 10 ** 18;
        dataURI = _dataURI;
        baseTokenURI = _tokenURI;
        ipfsDefault = _ipfsDefault;
        seed = _seed;
    }

    function setDataURI(string memory _dataURI) public onlyOwner {
        dataURI = _dataURI;
    }

    function setIpfsDefault(string memory _ipfsDefault) public onlyOwner {
        ipfsDefault = _ipfsDefault;
    }

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }    

    function setNameSymbol(
        string memory _name,
        string memory _symbol
    ) public onlyOwner {
        _setNameSymbol(_name, _symbol);
    }
    

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (tokenId > minted) {
         return ipfsDefault;
        }

        uint256 blockNumber = mintedBlockNumber[tokenId];
        
        // Utilizar o ID do NFT e o número do bloco mintado para a geração do hash
        bytes32 hash = keccak256(abi.encodePacked(tokenId, blockNumber));
        uint hashToUint = uint(hash);
        uint randomNumber = (hashToUint % seed) + 1;

        string memory partialURI = string.concat(dataURI, Strings.toString(randomNumber));
        return string.concat(partialURI, baseTokenURI);
    }
}