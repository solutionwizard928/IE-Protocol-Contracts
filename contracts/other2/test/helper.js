const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");

const DECIMALS = 18;
const parseUnits = (__num) => ethers.utils.parseUnits(__num.toString(), DECIMALS)

module.exports = {
    parseUnits,
    DECIMALS
}
