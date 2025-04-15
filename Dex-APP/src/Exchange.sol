// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public tokenAddress;

    // Exchange is inheriting ERC20, because our exchange itself is an ERC-20 contract
    // as it is responsible for minting and issuing LP Tokens
    constructor(address token) ERC20("Earned LP Tokens", "LPTokens") {
        require(token != address(0), "Token address passed is a null address");
        tokenAddress = token;
    }

    // getReserve returns the balance of `token` held by `this` contract
    function getReserve() public view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    //addLiquidity allows user to add liquidity
    function addLiquidity(
        uint256 amountOfToken
    ) public payable returns (uint256) {
        uint256 lpTokensToMint;
        uint256 ethReserveBalance = address(this).balance;
        uint256 tokenReserveBalance = getReserve();

        ERC20 token = ERC20(tokenAddress);

        //if the first liquidity provide
        if (tokenReserveBalance == 0) {
            //transfering the token from the user to the exchange
            token.transferFrom(msg.sender, address(this), amountOfToken);

            //lpTokensToMint = ethReserveBalance = msg.value
            lpTokensToMint = ethReserveBalance;

            // mint LPToken to User
            _mint(msg.sender, lpTokensToMint);

            return lpTokensToMint;
        }

        // if user is not the first liquidity provider
        uint256 ethReservePrioerToFunctionCall = ethReserveBalance - msg.value;
        uint256 mintTokenAmountRequired = (msg.value * tokenReserveBalance) /
            ethReservePrioerToFunctionCall;
        require(
            amountOfToken >= mintTokenAmountRequired,
            "Issufficient Amount"
        );

        //Transfer the token form User to Exchange
        token.transferFrom(msg.sender, address(this), mintTokenAmountRequired);

        // calculate the LPToken to mint
        lpTokensToMint =
            (totalSupply() * msg.value) /
            ethReservePrioerToFunctionCall;

        //mint LPTokens to the User
        _mint(msg.sender, lpTokensToMint);

        return lpTokensToMint;
    }

    // Remove Liquidity Function
    function removeLiquidity(
        uint256 amountOfLPTokens
    ) public returns (uint256, uint256) {
        // checks that the user has LPToken > 0
        require(amountOfLPTokens > 0, "Amount must be greater that 0");

        uint256 ethReserveBalance = address(this).balance;
        uint256 lpTokenTotalSupply = totalSupply();

        //calcuate how much eth and token that need to return to user
        uint256 ethToReturn = (ethReserveBalance * amountOfLPTokens) /
            lpTokenTotalSupply;
        uint256 tokenToReturn = (getReserve() * amountOfLPTokens) /
            lpTokenTotalSupply;

        // Burn the LPtoken to the User
        _burn(msg.sender, amountOfLPTokens);
        payable(msg.sender).transfer(ethToReturn);
        ERC20(tokenAddress).transfer(msg.sender, tokenToReturn);

        return (ethToReturn, tokenToReturn);
    }

    //to get amount from Swap
    function getOutputAmountFromSwap(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(
            inputReserve > 0 && outputReserve > 0,
            "Reserves Must Be Greater Than Zero"
        );

        uint256 inputAmountWithFee = inputAmount * 99;

        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
    }

    // to Swap ETH to Tokens
    function ethToTokenSwap(uint256 minTokenToReceive) public payable {
        uint256 tokenReserveBalance = getReserve();
        uint256 tokensToReceive = getOutputAmountFromSwap(
            msg.value,
            address(this).balance - msg.value,
            tokenReserveBalance
        );

        require(
            tokensToReceive >= minTokenToReceive,
            "Tokens Received are less than minimum token expected"
        );

        ERC20(tokenAddress).transfer(msg.sender, tokensToReceive);
    }

    // to Swap Tokens to ETH
    function tokenToEthSwap(
        uint256 tokensToSwap,
        uint256 minEthToReceive
    ) public {
        uint256 tokenReserveBalance = getReserve();
        uint256 ethToReceive = getOutputAmountFromSwap(
            tokensToSwap,
            tokenReserveBalance,
            address(this).balance
        );

        require(
            ethToReceive >= minEthToReceive,
            "ETH is less then minimun ETH expected"
        );

        ERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            tokensToSwap
        );

        payable(msg.sender).transfer(ethToReceive);
    }
}
