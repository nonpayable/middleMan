# middleMan
Exchange/Swap any NFT for NFT

# How to use
1. Deploy it on any chain.
2. Approve your token to smart contract's address.
3. Call <b>makeOffer()</b> with arguments<br>
  <i>with, [offer], [for]</i><br>
  makeOffer(address tradewith, [ERC721 offer's address, TokenID],[ERC721 for's address, TokenID])<br><br>
  <b>Example</b><br>
  makeOffer("0x0000000000000000000000000000000000000000", ["0xaa9d2c05365189B1B913e0b7877CFD5d61C9Da9a",1], ["0xaa9d2c05365189B1B913e0b7877CFD5d61C9Da9a",2]);<br>
  
4. After calling <b>makeOffer()</b> contract will emit OfferCreation(maker, taker, offer, for, ID);<br>
5. Opposite call <b>cancelOffer(uint256 tradeID)</b> or <b>takeOffer(uint256 tradeID)</b><br>
6. Or you cancel the trade with <b>cancelOffer(uint256 tradeID)</b>.
