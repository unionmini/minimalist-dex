// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UniswapV2Factory} from "../../src/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../../src/UniswapV2Pair.sol";
import {ERC20} from "../mocks/ERC20.sol";
import {Utilities} from "./Utilities.sol";

contract Fixtures {
    using Utilities for uint256;

    function createFactory(address feeToSetter) internal returns (UniswapV2Factory) {
        return new UniswapV2Factory(feeToSetter);
    }

    function createPair(UniswapV2Factory factory, address tokenA, address tokenB) internal returns (UniswapV2Pair) {
        factory.createPair(tokenA, tokenB);
        return UniswapV2Pair(factory.getPair(tokenA, tokenB));
    }

    function deployTokens() internal returns (ERC20 tokenA, ERC20 tokenB) {
        tokenA = new ERC20(uint256(10000).expandTo18Decimals());
        tokenB = new ERC20(uint256(10000).expandTo18Decimals());
    }
}
