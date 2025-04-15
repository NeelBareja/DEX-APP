
# 💱 Decentralized Exchange (DEX) Smart Contract

Welcome to the DEX smart contract repo — a decentralized exchange contract built using Solidity and deployed on the Sepolia Testnet. This smart contract forms the backbone of a token-swapping system, allowing trustless, peer-to-peer token exchanges on Ethereum-compatible chains.

> 🚀 **Live on Sepolia**  
> Contract Address: [`0x728a28a292e4ad536a21abb66800ca5c481b042`](https://sepolia.etherscan.io/address/0x728a28a292e4ad536a21abb66800ca5c481b042)  
> Verified on [Etherscan](https://sepolia.etherscan.io/address/0x728a28a292e4ad536a21abb66800ca5c481b042#code)

---

## 🧠 Overview

This smart contract enables a simple decentralized exchange between ERC20 tokens, similar in design to Uniswap V1. Users can list their tokens, perform token-to-token swaps, and manage their liquidity without relying on centralized intermediaries.

---

## ✨ Features

- 🔄 **Trustless Token Swapping**
- 📤 **Liquidity Management**
- 🔐 **ERC20 Token Compatibility**
- 🛠️ **Gas Optimized Functions**
- 📜 **Verified Source Code on Etherscan**
- 🧪 **Fully Tested with Foundry**

---

## 🛠️ Tech Stack

| Tool | Description |
|------|-------------|
| **Solidity** | Smart contract language |
| **Foundry** | Contract development & testing |
| **Etherscan API** | For source code verification |
| **Chain ID: 11155111** | Sepolia Ethereum Testnet |

---

## 🧩 Contract Structure

### 🔗 `Exchange.sol`

The core contract for this decentralized exchange. Below is a simplified and annotated version of the constructor and core logic:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange {
    IERC20 public token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function swapETHForToken() external payable {
        uint tokenAmount = msg.value; // 1:1 for simplicity
        require(token.balanceOf(address(this)) >= tokenAmount, "Not enough tokens");
        token.transfer(msg.sender, tokenAmount);
    }

    function swapTokenForETH(uint tokenAmount) external {
        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Transfer failed");
        payable(msg.sender).transfer(tokenAmount); // 1:1 for simplicity
    }

    function addLiquidity(uint tokenAmount) external payable {
        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
        // ETH comes in via msg.value
    }

    function removeLiquidity(uint tokenAmount) external {
        require(token.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens");
        require(address(this).balance >= tokenAmount, "Insufficient ETH");
        token.transfer(msg.sender, tokenAmount);
        payable(msg.sender).transfer(tokenAmount);
    }

    receive() external payable {}
}
```
## 🧠 Key Concepts

- Uses OpenZeppelin's IERC20 interface for interacting with ERC20 tokens.

- Maintains a 1:1 swap ratio between ETH and tokens (you can upgrade this logic for actual market-making mechanics like AMMs).

- Includes basic liquidity management functions.

- A fallback receive() function is implemented to accept ETH.


## Functions:

- `swapETHForToken()`

- `swapTokenForETH()`

- `addLiquidity()`

- `removeLiquidity()`

## 🧪 Local Development

### 1. Clone the repo


```bash
git clone https://github.com/NeelBareja/DEX-APP.git
cd DEX-APP
```

### 2. Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 3. Build and Test

```bash
forge build
forge test
```


## 🚀 Deployment

To deploy this project run

```bash
  forge create src/Exchange.sol:Exchange \
--rpc-url $RPC_URL \
--private-key $PRIVATE_KEY \
--constructor-args <ERC20 CONTRACT> \
--etherscan-api-key $ETHERSCAN_API_KEY \
--broadcast \
--verify
```

## 🔒 Security & Considerations

- Always use reentrancy guards in external call contexts

- Ensure proper input validation and revert messages

- Consider integrating test coverage tools like forge coverage

- Never use real funds on testnet contracts

## 📝 License

MIT License.
Use freely, fork freely — just give credit where it's due 🙌

## 📬 Contact

For queries, contributions, or collaborations:

- Twitter: @neel_bareja

- Email: neelbareja1@gmail.com

## 🌐 Useful Links

- [Etherscan Contract Page](https://sepolia.etherscan.io/address/0x728a28a292e4ad536a21abbb66800ca5c481b042)

- [Sepolia Faucet](https://sepolia-faucet.pk910.de/)

