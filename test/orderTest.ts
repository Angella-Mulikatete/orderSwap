import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";


describe("OrderSwap", function(){
    async function deployOrderSWap(){
        const [owner, depositor, buyer, otherAddress] = await ethers.getSigners();
        const OrderSwap = await hre.ethers.getContractFactory("OrderSwap");

      // Deploy test ERC20 tokens
        const ERC20 = await hre.ethers.getContractFactory("Token");
       
        const TokenA = await ERC20.deploy("TokenA", "TKA", 18, 1000000);
        const depositAmount_tokenA = ethers.parseUnits("1000", 18);
        await TokenA.transfer(depositor, depositAmount_tokenA); //deposit some amount of tokensA to the depositor's address
        
    
        const tokenB = await ERC20.deploy("TokenB", "TKB", 18, 1000000);
        const depositAmount_tokenB = ethers.parseUnits("500", 18);
        await tokenB.transfer(depositor, depositAmount_tokenB);
        
        const orderSwap = await OrderSwap.deploy();
        await TokenA.connect(depositor).approve(orderSwap, depositAmount_tokenA); // depositor approves the smartcontract to spend on its behalf
        return { orderSwap, TokenA, tokenB, owner, depositor, buyer };
    }

    describe("deployment", function(){
        it("should deploy the contract", async()=>{
            const {orderSwap, owner} = await loadFixture(deployOrderSWap);
             expect(await orderSwap.owner()).to.equal(owner.address);
        });
    });

    describe("deposit Tokens", function(){
       it("should allow deposit of tokens", async() => {
          const {orderSwap, TokenA, depositor} = await loadFixture(deployOrderSWap);
  
          const depositAmount = ethers.parseUnits("100", 18);
          await orderSwap.connect(depositor).depositTokens(TokenA, depositAmount);

          const balance = await orderSwap.getBalance(depositor, TokenA);
          expect(balance).to.equal(depositAmount);

        });
    });

    describe("create Order", function(){
       it("should create an order", async() => {
       const {orderSwap, TokenA, depositor,tokenB, buyer} = await loadFixture(deployOrderSWap);
         
          const depositAmount = ethers.parseUnits("100", 18);
          const expectedAmountOfTokenB = ethers.parseUnits("50",18);
          await orderSwap.connect(depositor).depositTokens(TokenA, depositAmount);
          const deadline = (await time.latest()) + 30; // 30 seconds later

          const tx = await orderSwap.connect(depositor).createOrder(
            TokenA,
            tokenB,
            depositAmount,
            expectedAmountOfTokenB,
            deadline
          );

          const receipt = await tx.wait();
         const orderId = (receipt?.logs?.find((e: any) => e.event === "OrderCreated") as any)?.args?.orderId;
          expect(orderId).to.not.be.null;
          const order = await orderSwap.orders(orderId);
          expect(order.depositor).to.equal(depositor.address);
          expect(order.tokenIn).to.equal(TokenA);
          expect(order.expectedToken).to.equal(tokenB);
          expect(order.amountIn).to.equal(depositAmount);
          expect(order.expectedAmount).to.equal(expectedAmountOfTokenB);
       });  
    });
});