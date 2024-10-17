// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interface/IIntellSetting.sol";

pragma experimental ABIEncoderV2;

contract IntellSetting is Ownable, IIntellSetting {
    address private _admin = 0x171c8C090511bc95886c9AAc505dB3081FE72F97;
    address private _truthHolder = 0xF8AbE936Ff2bCc9774Db7912554c4f38368e05A2;
    address private _intellTokenAddr;
    address private _factoryContractAddr;
    address private _intellModelNFTContractAddr;
    uint256 private _modelLaunchPrice;
    uint256 private _shareNFTLaunchPrice;

    constructor() {
        _modelLaunchPrice = 10000 * 10 ** 18;
        _shareNFTLaunchPrice = 10000 * 10 ** 18;
    }
    

    function truthHolder() external view override returns(address) {
        return _truthHolder;
    }

    function setTruthHolder(address _newTruthHolder) external onlyOwner {
        _truthHolder = _newTruthHolder;
    }

    function modelLaunchPrice() external view override returns(uint256) {
        return _modelLaunchPrice;
    }

    function setModelLaunchPrice(uint256 val) external onlyOwner {
        _modelLaunchPrice = val;
    }

    function shareNFTLaunchPrice() external view override returns(uint256) {
        return _shareNFTLaunchPrice;
    }

    function setShareNFTLaunchPrice(uint256 _newLaunchPrice) external onlyOwner {
        _shareNFTLaunchPrice = _newLaunchPrice;
    }

    function admin() external view override returns(address) {
        return _admin;
    }

    function setAdmin(address newAdmin) external onlyOwner {
        _admin = newAdmin;
    }

    function intellTokenAddr() external view override returns(address) {
        return _intellTokenAddr;
    }

    function setIntellTokenAddr(address newIntellTokenAddr) external onlyOwner {
        _intellTokenAddr = newIntellTokenAddr;
    }

    function factoryContractAddr() external view override returns(address) {
        return _factoryContractAddr;
    }

    function setFactoryContractAddr(address newFactoryContractAddr) external onlyOwner {
        _factoryContractAddr = newFactoryContractAddr;
    }

    function intellModelNFTContractAddr() external view override returns(address) {
        return _intellModelNFTContractAddr;
    }

    function setIntellModelNFTContractAddr(address newAddr) external onlyOwner {
        _intellModelNFTContractAddr = newAddr;
    }

}

