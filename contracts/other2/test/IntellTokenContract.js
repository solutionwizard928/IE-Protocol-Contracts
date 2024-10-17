const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { parseUnits, DECIMALS } = require("./helper");

describe("IntelligenceInvestmentToken", function () {
  async function deployIntelligenceExchangeProtocolFixture() {
    const TOTAL_SUPPLY = 1_000_000_000;
    const TOKEN_NAME = "Intelligence Investment Token";
    const TOKEN_SYMBOL = "INTELL";

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const IntelligenceInvestmentToken = await ethers.getContractFactory(
      "IntelligenceInvestmentToken"
    );
    const intelligenceInvestmentToken =
      await IntelligenceInvestmentToken.deploy();
    return {
      owner,
      otherAccount,
      intelligenceInvestmentToken,
      DECIMALS,
      TOTAL_SUPPLY,
      TOKEN_NAME,
      TOKEN_SYMBOL,
    };
  }

  describe("Deployment", function () {
    it("Should set the right Name of INTELL token", async function () {
      const { intelligenceInvestmentToken, TOKEN_NAME } = await loadFixture(
        deployIntelligenceExchangeProtocolFixture
      );
      expect(await intelligenceInvestmentToken.name()).to.equal(TOKEN_NAME);
    });

    it("Should set the right Symbol of INTELL token", async function () {
      const { intelligenceInvestmentToken, TOKEN_SYMBOL } = await loadFixture(
        deployIntelligenceExchangeProtocolFixture
      );
      expect(await intelligenceInvestmentToken.symbol()).to.equal(TOKEN_SYMBOL);
    });

    it("Should set the right decimals", async function () {
      const { intelligenceInvestmentToken, DECIMALS } = await loadFixture(
        deployIntelligenceExchangeProtocolFixture
      );

      expect(await intelligenceInvestmentToken.decimals()).to.equal(DECIMALS);
    });

    it("Should set the right owner of INTELL token", async function () {
      const { intelligenceInvestmentToken, owner } = await loadFixture(
        deployIntelligenceExchangeProtocolFixture
      );

      expect(await intelligenceInvestmentToken.owner()).to.equal(owner.address);
    });

    it("Should set the right total supply", async function () {
      const { intelligenceInvestmentToken, TOTAL_SUPPLY } = await loadFixture(
        deployIntelligenceExchangeProtocolFixture
      );

      expect(await intelligenceInvestmentToken.totalSupply()).to.equal(
        parseUnits(TOTAL_SUPPLY)
      );
    });

    it("Should set [balanceOf(owner) == totalSupply()] when the owner deploys token", async function () {
      const { intelligenceInvestmentToken, TOTAL_SUPPLY, DECIMALS, owner } =
        await loadFixture(deployIntelligenceExchangeProtocolFixture);

      expect(
        await intelligenceInvestmentToken.balanceOf(owner.address)
      ).to.equal(parseUnits(TOTAL_SUPPLY));
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const { intelligenceInvestmentToken, owner, otherAccount } =
        await loadFixture(deployIntelligenceExchangeProtocolFixture);
      const amount = 100;

      await expect(
        intelligenceInvestmentToken.transfer(
          otherAccount.address,
          parseUnits(100)
        )
      ).to.changeTokenBalances(
        intelligenceInvestmentToken,
        [owner, otherAccount],
        [parseUnits(-amount), parseUnits(amount)]
      );
    });

    it("Should fail if sender doesn’t have enough tokens", async function () {
      const { intelligenceInvestmentToken, owner, otherAccount } =
        await loadFixture(deployIntelligenceExchangeProtocolFixture);

      const initialOwnerBalance = await intelligenceInvestmentToken.balanceOf(
        owner.address
      );

      await expect(
        intelligenceInvestmentToken.transfer(
          otherAccount.address,
          initialOwnerBalance + 0x01
        )
      ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

      expect(
        await intelligenceInvestmentToken.balanceOf(owner.address)
      ).to.equal(initialOwnerBalance);
    });

    it("Should update allowance", async function () {
      const { intelligenceInvestmentToken, owner, otherAccount } =
        await loadFixture(deployIntelligenceExchangeProtocolFixture);

      await intelligenceInvestmentToken.approve(otherAccount.address, 100);
      expect(
        await intelligenceInvestmentToken.allowance(
          owner.address,
          otherAccount.address
        )
      ).to.equal(100);
    });

    it("Should transfer tokens from one account to another with allowance", async function () {
      const { intelligenceInvestmentToken, owner, otherAccount, DECIMALS } =
        await loadFixture(deployIntelligenceExchangeProtocolFixture);

      const testAmount = 100; //INTELL as unit

      await intelligenceInvestmentToken.approve(
        otherAccount.address,
        parseUnits(testAmount)
      );

      await expect(
        intelligenceInvestmentToken
          .connect(otherAccount)
          .transferFrom(owner.address, otherAccount.address, parseUnits(100))
      ).to.changeTokenBalances(
        intelligenceInvestmentToken,
        [owner, otherAccount],
        [parseUnits(-testAmount), parseUnits(testAmount)]
      );

      expect(
        await intelligenceInvestmentToken.allowance(
          owner.address,
          otherAccount.address
        )
      ).to.equal(0);
    });

    it("Should fail if sender doesn’t have enough allowance", async function () {
      const { intelligenceInvestmentToken, owner, otherAccount, DECIMALS } =
        await loadFixture(deployIntelligenceExchangeProtocolFixture);

      const approveAmount = parseUnits(99); // INTELL as unit
      const transferAmount = parseUnits(100); // INTELL as unit

      await intelligenceInvestmentToken.approve(
        otherAccount.address,
        approveAmount
      );

      await expect(
        intelligenceInvestmentToken
          .connect(otherAccount)
          .transferFrom(owner.address, otherAccount.address, transferAmount)
      ).to.be.revertedWith("ERC20: insufficient allowance");
    });

    it("Should burn some tokens to address(0)", async function () {
      const { intelligenceInvestmentToken, owner, TOTAL_SUPPLY } =
        await loadFixture(deployIntelligenceExchangeProtocolFixture);
      const burnAmount = 1000;

      await expect(
        intelligenceInvestmentToken.burn(parseUnits(burnAmount))
      ).to.changeTokenBalance(
        intelligenceInvestmentToken,
        owner,
        parseUnits(-burnAmount)
      );

      expect(await intelligenceInvestmentToken.totalSupply()).to.equal(
        parseUnits(TOTAL_SUPPLY - burnAmount)
      );
    });
  });

  describe("Ownership", function () {
    it("Should be able to transfer current ownership to new owner", async () => {
      const { intelligenceInvestmentToken, otherAccount } =
        await loadFixture(deployIntelligenceExchangeProtocolFixture);

        await intelligenceInvestmentToken.transferOwnership(otherAccount.address);
        expect(await intelligenceInvestmentToken.owner()).to.equal(otherAccount.address)
    });

    it("Should be able to renounce ownership", async () => {
        const { intelligenceInvestmentToken } =
          await loadFixture(deployIntelligenceExchangeProtocolFixture);
  
          await intelligenceInvestmentToken.renounceOwnership();
          expect(await intelligenceInvestmentToken.owner()).to.equal(ethers.constants.AddressZero)
      });

  });
});
