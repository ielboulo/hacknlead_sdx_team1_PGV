import { expect } from "chai";
import { ethers } from "hardhat";
import { PropertyToken } from "../typechain-types";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

  
  async function deployContract() {
    const signers = await ethers.getSigners();
    const propertyTokenFactory = await ethers.getContractFactory("PropertyToken");
    const propertyTokenInstance = await propertyTokenFactory.deploy(
        "Zurich_5432", 
        "BBT_ZH", 
        30, 
        100,
        "https://ipfs.io/ipfs/QmWx6QtvxiAiVDkqh3bC5mUxatqLzck4xH9eGvCuCqFFvC"
    );
    await propertyTokenInstance.waitForDeployment();
    return {signers, propertyTokenInstance};
  }

  it("Should have the correct initial values", async () => {
    const { signers, propertyTokenInstance } = await loadFixture(deployContract);

    expect(await propertyTokenInstance.name()).to.equal("Zurich_5432");
    expect(await propertyTokenInstance.symbol()).to.equal("BBT_ZH");
    expect(await propertyTokenInstance.getPropertyPrice()).to.equal(30);
    expect(await propertyTokenInstance.getTotalTokens()).to.equal(100);
    expect(await propertyTokenInstance.getOfficialDocLink()).to.equal(
      "https://ipfs.io/ipfs/QmWx6QtvxiAiVDkqh3bC5mUxatqLzck4xH9eGvCuCqFFvC"
    );
    expect(await propertyTokenInstance.balanceOf(signers[0].address)).to.equal(0);
    expect(await propertyTokenInstance.balanceOf(propertyTokenInstance)).to.equal(100);

  });

  it("Should update property price", async () => {
    const { signers, propertyTokenInstance } = await loadFixture(deployContract);

    await propertyTokenInstance.connect(signers[0]).updatePropertyPrice(500);
    expect(await propertyTokenInstance.getPropertyPrice()).to.equal(500);
  });

  it("Should update official docs link", async () => {
    const { signers, propertyTokenInstance } = await loadFixture(deployContract);

    await propertyTokenInstance.connect(signers[0]).updateOfficialDocLink("https://new-ipfs-link.com/12345");
    expect(await propertyTokenInstance.getOfficialDocLink()).to.equal("https://new-ipfs-link.com/12345");
  });

  it("Should allow burning tokens", async () => {
    const { signers, propertyTokenInstance } = await loadFixture(deployContract);

    expect(await propertyTokenInstance.balanceOf(signers[0].address)).to.equal(0);
    expect(await propertyTokenInstance.balanceOf(propertyTokenInstance)).to.equal(100);
    await propertyTokenInstance.connect(signers[0]).burn(10);
    expect(await propertyTokenInstance.balanceOf(propertyTokenInstance)).to.equal(90);
  });

    it("Should not allow non-owners to update official docs link", async () => {
    const { signers, propertyTokenInstance } = await loadFixture(deployContract);

    await expect(propertyTokenInstance.connect(signers[1]).updateOfficialDocLink("https://new-ipfs-link.com")).to.be.revertedWith("Caller is not the owner");
    });

    it("Should not allow non-owners to update property price", async () => {
        const { signers, propertyTokenInstance } = await loadFixture(deployContract);
        await expect(propertyTokenInstance.connect(signers[1]).updatePropertyPrice(40)).to.be.revertedWith("Caller is not the owner");
    });

    it("Should not transfer when there is no tokens", async () => {
        const { signers, propertyTokenInstance } = await loadFixture(deployContract);

        //expect(await propertyTokenInstance.balanceOf(signers[1].address)).to.equal(0);
        await expect(propertyTokenInstance.connect(signers[1]).transferTokens(signers[2], 11)).to.be.revertedWith('Not enough tokens to transfer');
    });
