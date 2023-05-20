const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LendingPlatform", function () {
  let LendingPlatform, lendingPlatform, owner, addr1, addr2;
  const LPtoken = "0xea455a4A28653BD24d43b87029D93Fb67d4C691b";
  const USDC = "0x8267cF9254734C6Eb452a7bb9AAF97B392258b21";

  beforeEach(async () => {
    LendingPlatform = await ethers.getContractFactory("LendingPlatform");
    [owner, addr1, addr2] = await ethers.getSigners();
    lendingPlatform = await LendingPlatform.deploy(LPtoken);
  });

  describe("Deployment", function () {
    it("Should set the right LPToken", async function () {
      expect(await lendingPlatform.LPToken()).to.equal(LPtoken);
    });
  });

  describe("Lend Eth", function () {
    it("Should revert if no Ether is sent", async function () {
      await expect(lendingPlatform.connect(addr1).lendEth()).to.be.revertedWith(
        "NotEnoughEth"
      );
    });

    it("Should lend Ether if Ether is sent", async function () {
      const initialBalance = await ethers.provider.getBalance(addr1.address);
      await lendingPlatform
        .connect(addr1)
        .lendEth({ value: ethers.utils.parseEther("1.0") });
      const finalBalance = await ethers.provider.getBalance(addr1.address);
      expect(initialBalance.sub(finalBalance)).to.be.above(
        ethers.utils.parseEther("1.0")
      );
      const lender = await lendingPlatform.lender(addr1.address);
      expect(lender.lendedAmount).to.equal(ethers.utils.parseEther("1.0"));
    });
  });

  describe("withdrawEth", function () {
    it("Should revert if the share is zero", async function () {
      await lendingPlatform
        .connect(addr1)
        .lendEth({ value: ethers.utils.parseEther("1.0") });
      await expect(
        lendingPlatform.connect(addr1).withdrawEth(0)
      ).to.be.revertedWith("NotEnoughEth");
    });

    it("Should allow withdrawing Ether", async function () {
      await lendingPlatform
        .connect(addr1)
        .lendEth({ value: ethers.utils.parseEther("1.0") });
      await lendingPlatform
        .connect(addr1)
        .withdrawEth(ethers.utils.parseEther("0.5"));
      const lender = await lendingPlatform.lender(addr1.address);
      expect(lender.lpShare).to.equal(ethers.utils.parseEther("0.5"));
    });
  });

  describe("depositCollateral", function () {
    it("Should revert if no Ether is sent", async function () {
      await expect(
        lendingPlatform.connect(addr1).depositCollateral()
      ).to.be.revertedWith("NotEnoughEth");
    });

    it("Should allow depositing collateral", async function () {
      await lendingPlatform
        .connect(addr1)
        .depositCollateral({ value: ethers.utils.parseEther("1.0") });
      const collateralAmount = await lendingPlatform.collateral(addr1.address);
      expect(collateralAmount).to.equal(ethers.utils.parseEther("1.0"));
    });
  });

  describe("borrow", function () {
    it("Should revert if the amount is zero", async function () {
      await expect(lendingPlatform.connect(addr1).borrow(0)).to.be.revertedWith(
        "Invalid Amount"
      );
    });
    // Add more scenarios for successful borrow
  });

  describe("repayUsdcDebt", function () {
    it("Should revert if the USDC token is not the right one", async function () {
      await expect(
        lendingPlatform
          .connect(addr1)
          .repayUsdcDebt(ethers.utils.parseEther("1.0"), LPtoken)
      ).to.be.revertedWith(
        "Please repay the debt with same currency you borrowed"
      );
    });
    // Add more scenarios for successful repayment
  });
});
