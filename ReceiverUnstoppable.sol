pragma solidity ^0.6.0;

import "../unstoppable/UnstoppableLender.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/* WRITE OUT THE PURPOSE OF THIS CONTRACT:
The logic of the wallet that will take the tokens.
*/

contract ReceiverUnstoppable {

    UnstoppableLender private pool; 
    address private owner;

    constructor(address poolAddress) public { // To share with external contracts??
        pool = UnstoppableLender(poolAddress);
        owner = msg.sender;
    }

    // Pool will call this function during the flash loan
    function receiveTokens(address tokenAddress, uint256 amount) external { 
        require(msg.sender == address(pool), "Sender must be pool");
        // Return all tokens to the pool
        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Transfer of tokens failed"); 
    }

    function executeFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        pool.flashLoan(amount);
    }
}