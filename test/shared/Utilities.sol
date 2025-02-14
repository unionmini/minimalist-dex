// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utilities {
    function expandTo18Decimals(uint256 n) internal pure returns (uint256) {
        return n * 10 ** 18;
    }

    function encodePrice(uint256 reserve0, uint256 reserve1) internal pure returns (uint256, uint256) {
        return (reserve1 * 2 ** 112 / reserve0, reserve0 * 2 ** 112 / reserve1);
    }
}
