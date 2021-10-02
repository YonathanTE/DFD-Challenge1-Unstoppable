pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/* WRITE OUT THE PURPOSE OF THIS CONTRACT: 
Allowing the deposit into the pool & borrowing abilities for any potential address.
*/

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}

contract UnstoppableLender is ReentrancyGuard { // Using ReentrancyGuard as a parent contract
    using SafeMath for uint256;

    IERC20 public damnValuableToken;
    uint256 public poolBalance;

// Brings in the tokenAddress from the DamnValuableToken.sol
    constructor(address tokenAddress) public { 
        require(tokenAddress != address(0), "Token address cannot be zero");
        damnValuableToken = IERC20(tokenAddress);
    }
// Using the nonReentrant modifier by applying it to the function so that there's no nested (reentrant) calls to them. 
    function depositTokens(uint256 amount) external nonReentrant { // nonReentrant prevents a contract from calling itself, directly or indirectly.
        require(amount > 0, "Must deposit at least one token");
        // Transfer token from sender. Sender must have first approved them.
        damnValuableToken.transferFrom(msg.sender, address(this), amount);
        poolBalance = poolBalance.add(amount);
    }
// Same as Line 26.
    function flashLoan(uint256 borrowAmount) external nonReentrant {  // Goal is to prevent this from working
// nonReentrant can't call another nonReentrant, so the function needs to be made external to avoid this. Also, this enables the function to call a 'private' function that does the work.
        require(borrowAmount > 0, "Must borrow at least one token");

        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool"); // Pool has to have more or equal to the borrowed amount

        // Ensured by the protocol via the `depositTokens` function
        assert(poolBalance == balanceBefore);
        
        // Borrowing through the flashloan. The wallet borrowing & the loan amount.
        damnValuableToken.transfer(msg.sender, borrowAmount); 
        
        // Assigns the address of the borrower for the tokenAddress & amount of tokens?
        IReceiver(msg.sender).receiveTokens(address(damnValuableToken), borrowAmount);
        
        // Uses logic from the previously written code from line(s) 38 through 41.
        uint256 balanceAfter = damnValuableToken.balanceOf(address(this)); 
        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
    }

}
