// var IntelligenceInvestmentToken = artifacts.require("IntelligenceInvestmentToken");

// module.exports = async function(deployer) {
//   // deployment steps
//   await deployer.deploy(IntelligenceInvestmentToken);
// };



// var IntellSetting = artifacts.require("IntellSetting");

// module.exports = async function(deployer) {
//   // deployment steps
//   await deployer.deploy(IntellSetting);
// };



// var IntellModelNFTContract = artifacts.require("IntellModelNFTContract");

// module.exports = async function(deployer) {
//   // deployment steps
//   await deployer.deploy(IntellModelNFTContract, "The-Intelligence-Exchange","0xc9c806A2986Ce19D0eB3Dfbc2ceb7B8492E3F4eE");
// };


// var IntellFactoryContract = artifacts.require("IntellFactoryContract");

// module.exports = async function(deployer) {
//   // deployment steps
//   await deployer.deploy(IntellFactoryContract,"0xc9c806A2986Ce19D0eB3Dfbc2ceb7B8492E3F4eE", "0x2ef579Cb8E6BB0Bf198CfAF3E5B133999B586f00");
// };


var IntellScan = artifacts.require("IntellScan");

module.exports = async function(deployer) {
  // deployment steps
  await deployer.deploy(IntellScan,"0xc9c806A2986Ce19D0eB3Dfbc2ceb7B8492E3F4eE");
};


// var IntelligenceInvestmentToken = artifacts.require("IntelligenceInvestmentToken");

// module.exports = async function(deployer) {
//   // deployment steps
//   await deployer.deploy(IntelligenceInvestmentToken);
// };


// const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

// const BNBHCharacter = artifacts.require("BNBHCharacter");
// const BNBHCharacterV2 = artifacts.require("BNBHCharacterV2");
// const BNBHCharacterV3 = artifacts.require("BNBHCharacterV3");


// module.exports = async function (deployer) {
//   // console.log(deployer)
//   // const BNBHCharacterContract = await deployProxy(BNBHCharacter, [], { deployer });
//   // console.log(BNBHCharacterContract.address);
//   const alreadyDeployed = await BNBHCharacter.deployed();
//   console.log(alreadyDeployed.address)
//   await upgradeProxy(alreadyDeployed.address, BNBHCharacterV3, {deployer});
// };
