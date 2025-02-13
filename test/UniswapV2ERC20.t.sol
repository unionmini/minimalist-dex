// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {UniswapV2ERC20} from "../src/UniswapV2ERC20.sol";

contract UniswapV2ERC20Test is Test {
    UniswapV2ERC20 token;
    address wallet = address(this);
    address other = address(0x1);

    uint256 constant TOTAL_SUPPLY = 10000 * 10 ** 18;
    uint256 constant TEST_AMOUNT = 10 * 10 ** 18;

    function setUp() public {
        token = new UniswapV2ERC20();
        token._mint(wallet, TOTAL_SUPPLY);
    }

    function testNameSymbolDecimals() public view {
        assertEq(token.name(), "Uniswap V2");
        assertEq(token.symbol(), "UNI-V2");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), TOTAL_SUPPLY);
        assertEq(token.balanceOf(wallet), TOTAL_SUPPLY);
    }

    function testApprove() public {
        assertTrue(token.approve(other, TEST_AMOUNT));
        assertEq(token.allowance(wallet, other), TEST_AMOUNT);
    }

    function testTransfer() public {
        assertTrue(token.transfer(other, TEST_AMOUNT));
        assertEq(token.balanceOf(wallet), TOTAL_SUPPLY - TEST_AMOUNT);
        assertEq(token.balanceOf(other), TEST_AMOUNT);
    }

    function testTransferFail() public {
        vm.expectRevert();
        token.transfer(other, TOTAL_SUPPLY + 1);

        vm.prank(other);
        vm.expectRevert();
        token.transfer(wallet, 1);
    }

    function testTransferFrom() public {
        token.approve(other, TEST_AMOUNT);

        vm.prank(other);
        assertTrue(token.transferFrom(wallet, other, TEST_AMOUNT));

        assertEq(token.allowance(wallet, other), 0);
        assertEq(token.balanceOf(wallet), TOTAL_SUPPLY - TEST_AMOUNT);
        assertEq(token.balanceOf(other), TEST_AMOUNT);
    }

    function testPermit() public {
        uint256 privateKey = 0xBEEF;
        address owner = vm.addr(privateKey);

        uint256 nonce = token.nonces(owner);
        uint256 deadline = type(uint256).max;

        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(abi.encode(token.PERMIT_TYPEHASH(), owner, other, TEST_AMOUNT, nonce, deadline))
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        token.permit(owner, other, TEST_AMOUNT, deadline, v, r, s);

        assertEq(token.allowance(owner, other), TEST_AMOUNT);
        assertEq(token.nonces(owner), 1);
    }
}
