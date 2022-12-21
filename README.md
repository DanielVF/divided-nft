# Divided NFTs

WETH for NFTs.

Permissionless pooling of NFT's into an ERC20.

_Testing in prod. Not currently audited, use at your own risk._


### Why?

There is a big missing ecosystem at the intersection of NFTs and DeFi.

But current solutions in this area interoperable or composable, either horizontally or vertically. Some have everything be in-house, others shard only single NFT's, and some shard NFT's as more NFTs. There's tremendous power in permissionless, interoperable base layers - and even more in already being compatible with an entire existing ecosystem.

What if any NFT ERC721 contract could be transformed into an ERC20? Then the all the tools already built for DeFi would just work.


### How?

Each NFT collection contract gets its own canonical DividedPool contract. Put an NFT in, get 100 1e18 pool tokens out. Put 100 pool tokens back in, get your choice of an NFT back out.

There are no fees for going in, out, or swapping. There are no permissions or whitelists or DAO. This does not earn money. This is WETH-like.

These pool tokens can then be used on AMMs, defi, lending platforms, perps, whatever.

Pooled NFT's are no longer owned by individual owners. Anyone with the right amount of tokens can grab any NFT from the pool at any time. This is for cattle, not pets. (Maybe it's like a pet store). This instant ability to convert back to an NFT enables lending platform like uses, where selling collateral is a core feature.


### Registry / Architecture

The Architecture is uniswap like. Almost everything is done is via a router contract, however protocols and bots can use pool contracts directly for gas savings.

| Name | Address |
| --- | --- |
|Router | [0x50b0f12da172ad237bb66f9d0cc3b53920b7bfd9](https://etherscan.io/address/0x50b0f12da172ad237bb66f9d0cc3b53920b7bfd9)|
|Factory | [0xbb08603acfe5ea5bd34474af4c32c931aabd7e17](https://etherscan.io/address/0xbb08603acfe5ea5bd34474af4c32c931aabd7e17)|
|Demo Pool| [0x85584521e1C762B8e22e03E127E7723CFcf05C4b](https://etherscan.io/address/0x85584521e1C762B8e22e03E127E7723CFcf05C4b)|
|Demo NFT| [Overlords AI](https://opensea.io/collection/overlords-ai)|

Demo pool tokens can be bought and sold on Uniswap v3.


Router functions (make sure to set yourself as the `to` address):

```javascript
function nftIn(address collection, uint256 tokenId, address to);
function nftOut(address collection, uint256 tokenId, address to);
function nftSwap(address collection, uint256 tokenIn, uint256 tokenOut, address to);
function batchNftIn(address collection, uint256[] calldata tokenIds, address to);
function batchNftOut(address collection, uint256[] calldata tokenIds, address to);
function batchNftSwap(address collection, uint256[] calldata tokenIns, uint256[] calldata tokenOuts, address to);
```

### Playing with it

There is no UI right now. It's etherscan all the way. Thing you could try:

- Get an NFT from OpenSea, swap it using the router for an NFT of your choice in the pool.
- Get 100 pool tokens from uniswap, use them to pull out the NFT you want from pool, via the router.
- Make your own pool for an NFT contract using the DividedFactoy contract.


### Contributing / Further discussions

Code is MIT.

If you find a bug, DM me on twitter, plskthx. Rewards in AI generated art.

For discussion on the experiment let's try using GitHub discussions on this repo.





