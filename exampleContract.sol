// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract exampleContract is ERC721PresetMinterPauserAutoId, IERC2981, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public constant mintRate =
    uint public constant MAX_SUPPLY =
    uint8 public constant MINT_PER_TX =
    uint256 public constant ROYALTY = // base 10000,

    // Sad attempt at revealing metadata post mint...
    string public baseURI = _baseTokenURI;
    bool public revealed = false;


    Counters.Counter private _tokenIds;
    address public paymentManager;
    bool private mintable = false;

    constructor(string memory _baseTokenURI, address _paymentManager)
        ERC721PresetMinterPauserAutoId('PLACEHOLDER_NAME', 'PHN', _baseTokenURI) 


    // Sad attempt at revealing metadata post mint...
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function changeBaseURI (string memory baseURI_) public onlyOwner {
        baseURI = baseURI_;
    }

    function changeRevealed(bool _revealed) public onlyOwner {
        revealed = _revealed;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI_ = _baseURI();

        if (revealed) {
            return bytes(baseURI_).length > 0 ? string(abi.encodePacked(baseURI_, Strings.toString(tokenId), ".json")) : "";
        } else {
            return string(abi.encodePacked(baseURI_, "hidden.json"));
        }
    }

    // @notice
    function mintToken(uint8 _quantity) public payable {
        require(mintable, 'Contracts are not Mintable yet.');
        require(_quantity <= MINT_PER_TX, 'Mint limit reached.');
        require(msg.value == mintRate * _quantity, 'More funds required');

        // @notice minting
        for (uint256 _i = 0; _i < _quantity; _i++) {
            _tokenIds.increment();
            _mint(msg.sender, _tokenIds.current());
        }
    }

    function veryImportant(address _to) external onlyOwner {
        require(!mintable, 'Very important are not mintable anymore.');
        _tokenIds.increment();
        _mint(_to, _tokenIds.current());
    
    }

    /// @dev override to check the max supply when minting
    function _mint(address to, uint256 _id) internal override {
        require(_id < MAX_SUPPLY, 'All PLACEHOLDER are minted.');
        super._mint(to, _id);
    }    
    
    /// @notice Set the mintable state
    function enableMinting() external onlyOwner {
        mintable = true;    
    }

    /// @dev Support for IERC-2981, royalties
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC165, ERC721PresetMinterPauserAutoId)
        returns (bool)
    {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice Calculate the royalty payment
    function royaltyInfo(uint256, uint256 _salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        return (paymentManager, (_salePrice * ROYALTY) / 10000);
    }

    /// @notice Withdraw funds from this contract and send to the payment manager
    function withdraw() external {
        payable(paymentManager).transfer(address(this).balance);
    }
}
