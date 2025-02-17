# Uniswap V2 Core Implementation

A Foundry implementation of Uniswap V2 Core contracts with comprehensive tests.

## Overview

This repository contains a Solidity implementation of the Uniswap V2 Core protocol using the Foundry development framework. It includes the core contracts, periphery contracts, and comprehensive tests.

## Contracts

- `UniswapV2Factory`: Creates and manages Uniswap V2 pairs
- `UniswapV2Pair`: Implements the core AMM logic
- `UniswapV2Router02`: Handles routing and user interactions
- `UniswapV2ERC20`: Base token implementation for LP tokens

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/downloads)

### Installation

```bash
# Clone the repository
git clone https://github.com/unionmini/minimalist-dex
cd minimalist-dex

# Install dependencies
forge install

# Build the project
make build
```

### Configuration

Create a `.env` file in the root directory:

```env
PRIVATE_KEY=
HOLESKY_RPC_URL=
HOLESKY_BLOCKSCOUT_API_URL=
HOLESKY_BLOCKSCOUT_API_KEY=
FEE_TO_SETTER=

TEST_RPC_URL=
```

## Testing

Run the test suite:

```bash
# Run all tests
make test
```

## Deployment

Deploy the contracts:

```bash
# deploy to holesky
make deploy
```

## Security

This project uses Slither for static analysis. Configure excluded detectors in `slither.config.json`.

Run security checks:

```bash
slither .
```

## Documentation

For more detailed information about Uniswap V2, refer to:

- [Uniswap V2 Core Documentation](https://docs.uniswap.org/contracts/v2/overview)
- [Uniswap V2 Whitepaper](https://uniswap.org/whitepaper.pdf)

## License

This project is licensed under the MIT License.
