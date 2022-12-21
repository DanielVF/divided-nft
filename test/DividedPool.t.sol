// SPDX-License-Identifier: MIT
// Author: Daniel Von Fange (@DanielVF)

pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/DividedPool.sol";
import "../src/DividedFactory.sol";
import "solmate/test/utils/mocks/MockERC721.sol";

contract DividedTest is Test {
    DividedPool public pool;
    DividedFactory public factory;
    MockERC721 public nft;

    address ALICE = address(0xA11CE);
    address BOB = address(0xB0BB);
    uint256 constant FULL_SHARDS = 100 * 1e18;

    function setUp() public {
        nft = new MockERC721("Rocket", "RKT");
        nft.mint(address(this), 1);
        nft.mint(ALICE, 2);
        nft.mint(BOB, 3);
        nft.mint(address(this), 4);

        factory = new DividedFactory();

        pool = DividedPool(factory.deploy(address(nft)));

        nft.transferFrom(address(this), address(pool), 4);
        pool.swap(new uint256[](0), address(this), address(this));
    }

    function testFactoryPoolStore() public {
        assertEq(address(pool), factory.pools(address(nft)));
    }

    function testDoubleDeploy() public {
        address aNFT = address(new MockERC721("RocketA", "RKTA"));
        address bNFT = address(new MockERC721("RocketB", "RKTB"));
        address a = factory.deploy(aNFT);
        address b = factory.deploy(bNFT);
        assert(a != b);
    }

    function testNftIn() public {
        assertEq(pool.totalSupply(), FULL_SHARDS);
        assertEq(pool.balanceOf(address(this)), FULL_SHARDS);
        assertEq(nft.ownerOf(1), address(this));

        nft.transferFrom(address(this), address(pool), 1);
        pool.swap(new uint256[](0), address(this), address(this));

        assertEq(pool.totalSupply(), 2 * FULL_SHARDS);
        assertEq(pool.balanceOf(address(this)), 2 * FULL_SHARDS);
        assertEq(nft.ownerOf(1), address(pool));
    }

    function testNftOut() public {
        uint256[] memory outs = new uint256[](1);
        outs[0] = 4;
        pool.swap(outs, address(this), address(this));
        assertEq(nft.ownerOf(4), address(this));
        assertEq(pool.balanceOf(address(this)), 0);
    }

    function testSwap() public {
        uint256[] memory outs = new uint256[](1);
        outs[0] = 4;
        nft.transferFrom(address(this), address(pool), 1);
        pool.swap(outs, address(this), address(this));

        assertEq(nft.ownerOf(4), address(this), "NFT out");
        assertEq(nft.ownerOf(1), address(pool), "NFT in");
        assertEq(pool.balanceOf(address(this)), FULL_SHARDS);
    }

    function testSweep() public {
        nft.transferFrom(address(this), address(pool), 1);
        vm.prank(BOB);
        pool.swap(new uint256[](0), BOB, BOB);
        assertEq(pool.balanceOf(BOB), FULL_SHARDS, "Out funds");
    }

    function testOtherPay() public {
        // Bob approves Alice to spend his pool tokens
        // So alice can use them to swap an NFT out.
        uint256[] memory outs = new uint256[](1);
        outs[0] = 4;
        pool.transfer(BOB, FULL_SHARDS);
        vm.prank(BOB);
        pool.approve(ALICE, FULL_SHARDS);
        vm.prank(ALICE);
        pool.swap(outs, BOB, ALICE);
    }

    function testNoSteal() public {
        // Bob does not approve Alice to spend his pool tokens
        // So alice cannot use them to swap an NFT out.
        uint256[] memory outs = new uint256[](1);
        outs[0] = 4;
        pool.transfer(BOB, FULL_SHARDS);
        vm.prank(ALICE);
        vm.expectRevert();
        pool.swap(outs, BOB, ALICE);
    }
}
