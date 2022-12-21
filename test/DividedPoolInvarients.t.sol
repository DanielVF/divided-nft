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
    MintOnlyMockERC721 public nft;

    address ALICE = address(0xA11CE);
    address BOB = address(0xB0BB);
    uint256 constant FULL_SHARDS = 100 * 1e18;

    function setUp() public {
        nft = new MintOnlyMockERC721("Rocket", "RKT");
        nft.mint(1);
        nft.mint(2);
        nft.mint(3);
        nft.mint(4);

        nft.transferFrom(address(this), ALICE, 2);
        nft.transferFrom(address(this), BOB, 3);

        factory = new DividedFactory();

        pool = DividedPool(factory.deploy(address(nft)));

        nft.transferFrom(address(this), address(pool), 4);
        pool.swap(new uint256[](0), address(this), address(this));
    }

    function invariantBalancedTokens() public {
        vm.prank(BOB);
        pool.swap(new uint256[](0), address(this), address(this));
        assertEq(nft.balanceOf(address(pool)) * FULL_SHARDS, pool.totalSupply());
    }
}

contract MintOnlyMockERC721 is ERC721 {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function tokenURI(uint256) public pure virtual override returns (string memory) {}

    function mint(uint256 tokenId) public virtual {
        _mint(msg.sender, tokenId);
    }
}
