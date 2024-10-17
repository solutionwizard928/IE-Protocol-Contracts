// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./interface/IIntellSetting.sol";
import "./interface/IShareERC721.sol";

pragma experimental ABIEncoderV2;

contract IntellShareNFTContract is
    ERC721Enumerable,
    ReentrancyGuard,
    IShareERC721
{
    using Strings for uint256;
    using SafeMath for uint256;

    string _baseTokenURI;
    bool public _paused = false;

    uint256 public override MAX_TOTAL_SUPPLY;
    uint256 public override MAX_MINT_PER_ADDR;
    uint256 public override MAX_MINT_PER_TX;

    uint256 public override INTELL_MODEL_NFT_TOKEN_ID;
    address public override INTELL_MODEL_NFT_CONTRACT_ADDR;

    uint256 public override MINT_PRICE;
    address public override PAYMENT_TOKEN_ADDR;

    uint256 public override LAUNCH_END_TIME;
    bool public override FOR_ONLY_US_INVESTOR;
    bool public override WITHDRAWN = false;
    bool public override BLOCKED = false;

    IIntellSetting public intellSetting;

    event Minted(uint256 indexed tokenId, address to);
    event Stopped();

    constructor(string memory _name, string memory _symbol, IIntellSetting _intellSetting) ERC721(_name, _symbol) {

        intellSetting = _intellSetting;
        
        require(_intellSetting.factoryContractAddr() == _msgSender() && _msgSender() != tx.origin, "Ownable: caller is not the factory");

    }

    mapping(address => uint256) public mintedPerAddress;

    modifier onlyCreator() {
        require(creator() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyFactory() {
        require(intellSetting.factoryContractAddr() == _msgSender() && _msgSender() != tx.origin, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(
            intellSetting.admin() == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function creator() public view returns (address) {
        return
            IERC721Enumerable(intellSetting.intellModelNFTContractAddr())
                .ownerOf(INTELL_MODEL_NFT_TOKEN_ID);
    }

    function launch(
        bytes calldata _data,
        uint256 _INTELL_MODEL_NFT_TOKEN_ID
    ) external override onlyFactory {

        (
            address _PAYMENT_TOKEN_ADDR,
            ,
            ,
            uint256 _MAX_TOTAL_SUPPLY,
            uint256 _MINT_PRICE,
            uint256 _MAX_MINT_PER_TX,
            uint256 _MAX_MINT_PER_ADDR,
            uint256 _DURATION,
            bool _FOR_ONLY_US_INVESTOR
        ) = abi.decode(
                _data,
                (
                    address,
                    string,
                    string,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    bool
                )
            );

        require(
                _MAX_TOTAL_SUPPLY > 0 &&
                _MINT_PRICE > 0 &&
                _MAX_MINT_PER_TX > 0 &&
                _MAX_MINT_PER_ADDR > 0 &&
                _DURATION > 30 days,
            "INVALID INPUT DATA"
        );

        MAX_TOTAL_SUPPLY = _MAX_TOTAL_SUPPLY;
        MINT_PRICE = _MINT_PRICE;
        MAX_MINT_PER_ADDR = _MAX_MINT_PER_ADDR;
        MAX_MINT_PER_TX = _MAX_MINT_PER_TX;
        LAUNCH_END_TIME = _DURATION.add(block.timestamp);

        INTELL_MODEL_NFT_TOKEN_ID = _INTELL_MODEL_NFT_TOKEN_ID;
        PAYMENT_TOKEN_ADDR = _PAYMENT_TOKEN_ADDR;

        FOR_ONLY_US_INVESTOR = _FOR_ONLY_US_INVESTOR;

        _paused = false;
    }

    function adopt(
        bytes calldata message,
        bytes calldata signature
    ) external nonReentrant {
        require(verifyMessage(message, signature), "NO SIGNER");

        (
            address _USER_ADDR,
            address _SHARE_NFT_ADDR,
            bool _KYC_VERIFICATION_AS_INVESTOR,
            bool _USER_SUSPENDED,
            bool _FROM_US,
            bool _STOP_SELLING_SHARE,
            bool _MODEL_SUSPEND,
            uint256 _NUM,
            uint256 _INTELL_MODEL_NFT_TOKEN_ID
        ) = abi.decode(
                message,
                (
                    address,
                    address,
                    bool,
                    bool,
                    bool,
                    bool,
                    bool,
                    uint256,
                    uint256
                )
            );

        require(!BLOCKED, "THIS INTELL SHARE NFT COLLECTION WAS BLOCKED");

        require(
            (FOR_ONLY_US_INVESTOR &&
                _FROM_US &&
                _KYC_VERIFICATION_AS_INVESTOR) ||
                (!FOR_ONLY_US_INVESTOR && !_FROM_US),
            "KYC is required"
        );

        require(
            !_USER_SUSPENDED &&
                !_MODEL_SUSPEND &&
                !_STOP_SELLING_SHARE &&
                _INTELL_MODEL_NFT_TOKEN_ID == INTELL_MODEL_NFT_TOKEN_ID &&
                _SHARE_NFT_ADDR == address(this),
            "THE USER PROFILE IS INVALID"
        );

        require(LAUNCH_END_TIME >= block.timestamp, "SALE WAS EXPIRED");
        uint256 supply = totalSupply();
        require(!_paused, "SALE STOPPED");
        require(_NUM <= MAX_MINT_PER_TX, "MINTING WOULD EXCEED MAX SUPPLY");
        require(
            supply + _NUM <= MAX_TOTAL_SUPPLY,
            "MINTING WOULD EXCEED MAX SUPPLY"
        );
        require(
            _NUM + mintedPerAddress[msg.sender] <= MAX_MINT_PER_ADDR,
            "SENDER ADDRESS CANNOT MINT MORE THAN MAX_MINT_PER_ADDR"
        );

        require(tx.origin == msg.sender && msg.sender == _USER_ADDR, "NO BOT");
        require(
            IERC20(PAYMENT_TOKEN_ADDR).balanceOf(msg.sender) >=
                MINT_PRICE * _NUM,
            "INSUFFICIENT BALANCE"
        );
        mintedPerAddress[msg.sender] += _NUM;
        IERC20(PAYMENT_TOKEN_ADDR).transferFrom(
            msg.sender,
            address(this),
            MINT_PRICE * _NUM
        );

        for (uint256 i = 1; i <= _NUM; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function walletOfOwner(
        address _owner
    ) public view override returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyCreator {
        _baseTokenURI = baseURI;
    }

    function stop() public onlyCreator {
        _paused = true;
        emit Stopped();
    }

    function blocked(bool val) public onlyAdmin {
        BLOCKED = val;
    }

    function recoverSigner(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address) {
        bytes32 messageDigest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        return ECDSA.recover(messageDigest, signature);
    }

    function verifyMessage(
        bytes memory message,
        bytes memory signature
    ) internal view returns (bool) {
        bytes32 hash = keccak256(message);
        return recoverSigner(hash, signature) == intellSetting.truthHolder();
    }

    function withdraw(
        bytes calldata message,
        bytes calldata signature
    ) public onlyCreator {
        require(LAUNCH_END_TIME < block.timestamp, "NOT FINISHED YET");
        require(verifyMessage(message, signature), "NO SIGNER");

        (bool _canWithdraw, address _owner) = abi.decode(
            message,
            (bool, address)
        );
        require(_canWithdraw && _owner == creator(), "THE CONDITION IS INVALID");

        uint256 amount = IERC20(PAYMENT_TOKEN_ADDR).balanceOf(address(this));
        IERC20(PAYMENT_TOKEN_ADDR).transfer(creator(), amount);
        WITHDRAWN = true;
    }

}
