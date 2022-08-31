// ERC20TokenSaleRefund tests 
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { utils } = ethers;
const { BigNumber } = ethers;
let contract = null;
let accounts = null;

  beforeEach(async function() {
    accounts = await ethers.getSigners();

    const ContractFactory = await ethers.getContractFactory("TokenSaleRefund");
    contract = await ContractFactory.deploy();
    await contract.deployed();

    provider = await ethers.provider;
    elevenEtherInHex = utils.hexStripZeros(
      utils.parseEther("12").toHexString()
    );

    // set account[0] to have 12 ether
    await provider.send("hardhat_setBalance", [
      accounts[0].address,
      elevenEtherInHex
    ]);

    // tests will faill if initial account doesn't have 12 ether to start
    const balance = await provider.getBalance(accounts[0].address);
    expect(balance).to.be.equal(new BigNumber.from(utils.parseEther('12')));
  });

  describe("rate", function () {
    it("Should return the correct token rate", async function () {
      const rate = utils.parseEther('0.0005');
      expect(await contract.rate()).to.be.equal(new BigNumber.from(rate));
    });
  });

  describe("mint tokens", function () {
    it("Should mint 1000 tokens for 1 eth", async function () {
      // call mintTokens with 1 ether
      await contract.mintTokens({value: utils.parseEther('1')});
      
      // 1000 wei tokens to ether representation
      tokens = new BigNumber.from(utils.parseEther('1000'));
      // check if the user has been minted 1000 tokens
      expect(await contract.balanceOf(accounts[0].address)).to.be.equal(tokens);
    });
    
    it("Should mint 1100 tokens for 11.22 eth, return 0.22 eth back to sender", async function () {
      // call mintTokens with 11.22 ether
      await contract.mintTokens({value: utils.parseEther('11.22')});

      // 11000 wei tokens to ether representation
      tokens = new BigNumber.from(utils.parseEther('11000'));
      // check if the user has been minted 11000 tokens
      expect(await contract.balanceOf(accounts[0].address)).to.be.equal(tokens);

      // check if the user has been given back the .22 ether (started with 12)
      // User should roughly have 1 ether left minus gas fees
      const balance = await provider.getBalance(accounts[0].address);
      expect(balance).to.be.closeTo(
        new BigNumber.from(utils.parseEther("1")),
        new BigNumber.from(utils.parseEther("0.001"))
      );
    });

  });

  describe("sell back", function () {
    it("Revert if user doesn't have any tokens", async function () {
      // initial user token balance is 0
      tokens = new BigNumber.from(utils.parseEther('0'));
      expect(await contract.balanceOf(accounts[0].address)).to.be.equal(tokens); 

      // should revert on call
      await expect(contract.sellBack(1)).to.be.revertedWith("You do not have any tokens to send!");
    });
    
    it("Revert if contract has insufficient funds", async function () {
      // buy 1000 tokens 
      await contract.mintTokens({value: utils.parseEther('1')});

      // contract has 1 ether, reduce this to 0.1
      etherInHex = utils.hexStripZeros(
        utils.parseEther("0.1").toHexString()
      );

      await provider.send("hardhat_setBalance", [
        contract.address,
        etherInHex
      ]);

      // attempt to sell for 0.5 ether 
      await expect(contract.sellBack(1000)).to.be.revertedWith("Contract doesn't have enough Ether!");
    });

    it("recieve 0.5 ether for selling back 1000 tokens", async function () {
      // buy 1000 tokens 
      await contract.mintTokens({value: utils.parseEther('1')});

      // make sure transaction succeeds  
      await expect(contract.sellBack(1000)).to.not.be.reverted;

      //  check if they recieved 0.5 ether back
      // 12 - 1 + 0.5 = 11.5
      const balance = await provider.getBalance(accounts[0].address);
      expect(balance).to.be.closeTo(
        new BigNumber.from(utils.parseEther("11.5")),
        new BigNumber.from(utils.parseEther("0.001"))
      ); 
    });
    
  describe("withdraw", function () {
    it("deployer (accounts[0]) can withdraw funds", async function () {
      // buy 1000 tokens (accounts[0]) to get ether into contract
      await contract.mintTokens({value: utils.parseEther('1')});

      // withdraw funds 
      await expect(contract.withdraw()).to.not.be.reverted;

      // check balance 12 - 1 + 1 = 12 ether (roughly)
      const userBalance = await provider.getBalance(accounts[0].address);
      expect(userBalance).to.be.closeTo(
        new BigNumber.from(utils.parseEther("12")),
        new BigNumber.from(utils.parseEther("0.001"))
      );
      
      // check balance of contract is 0
      const contractBalance = await provider.getBalance(contract.address);
      expect(contractBalance).to.be.equal(new BigNumber.from('0'));
    });
    
    it("revert on non-deployer withdrawal", async function () {
      // buy 1000 tokens (accounts[0]) to get ether into contract
      await contract.mintTokens({value: utils.parseEther('1')});

      // withdraw funds with accounts[1] should revert as not deployer
      await expect(contract.connect(accounts[1]).withdraw()).to.be.reverted;

    });
  });

  });