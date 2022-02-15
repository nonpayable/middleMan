// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/utils/ERC721Holder.sol";

contract middleMan is ERC721Holder{
    address sc;
    constructor(){
        sc = address(this);
    }
    struct NFT{
        address token;
        uint256 id;
    }

    struct Trade{
        address maker;
        address taker;
        bool makerReady;
        bool takerReady;
        NFT offer;
        NFT _for;
        uint256 offerID;
        uint256 at;
    }

    mapping(uint256 => Trade) tradeInfo;
    uint256 public offerID;

    event OfferCreation(address indexed maker, address indexed taker, NFT offer, NFT _for, uint256 ID);

    function checkAvailable(address with, NFT calldata A, NFT calldata B) internal view returns(bool){
        // owned by A is sender's offer
        // ~~~~~~~~ B is the other side of trade
        bool isOwnedbyA = (IERC721(A.token).ownerOf(A.id) == msg.sender);
        bool isOwnedbyB = (IERC721(B.token).ownerOf(B.id) == with);
        return (isOwnedbyA && isOwnedbyB);
    }

    function makeOffer(address with, NFT calldata offer, NFT calldata _for) external{
        IERC721 token = IERC721(offer.token);
        require(checkAvailable(with, offer, _for),"?");
        // require(token.getApproved(offer.id) == sc,"Approve your token!");
        // increase offerID
        offerID++;
        // set maker and taker addresses
        tradeInfo[offerID].maker = msg.sender;
        tradeInfo[offerID].taker = with;
        // set maker ready
        tradeInfo[offerID].makerReady = true;
        // set offerID
        tradeInfo[offerID].offerID = offerID;
        // set nfts
        tradeInfo[offerID].offer = offer;
        tradeInfo[offerID]._for = _for;
        // set started block
        tradeInfo[offerID].at = block.number;
        // make a transfer
        token.safeTransferFrom(msg.sender, sc, offer.id);
        emit OfferCreation(msg.sender, with, offer, _for, offerID);
    }

    function takeOffer(uint256 _offerID) external{
        // is maker or taker
        require(tradeInfo[_offerID].taker == msg.sender);
        NFT storage _for = tradeInfo[_offerID]._for;
        IERC721 token = IERC721(_for.token);
        tradeInfo[_offerID].takerReady = true;
        // to ensure
        require((tradeInfo[_offerID].makerReady) && (tradeInfo[_offerID].takerReady));
        // require(token.getApproved(_for.id) == sc,"Approve your token!");
        token.safeTransferFrom(tradeInfo[_offerID].taker, sc, _for.id);

        makeTransaction(_offerID);
    }

    function cancelOffer(uint256 _offerID) external{
        // is maker or taker
        require((tradeInfo[_offerID].maker == msg.sender) || (tradeInfo[_offerID].taker == msg.sender));
        NFT storage offer = tradeInfo[_offerID].offer;
        IERC721(offer.token).safeTransferFrom(sc, tradeInfo[_offerID].maker, offer.id);
        delete tradeInfo[_offerID];
    }
    
    function makeTransaction(uint256 _offerID) internal{
        // probably vuln some how
        // require(msg.sender == sc,"Caller aren't contract!");
        require((tradeInfo[_offerID].makerReady) && (tradeInfo[_offerID].takerReady));
        IERC721 _offer = IERC721(tradeInfo[_offerID].offer.token);
        IERC721 _for = IERC721(tradeInfo[_offerID]._for.token);

        // make a transaction
        _offer.safeTransferFrom(sc, tradeInfo[_offerID].taker, tradeInfo[_offerID].offer.id);
        _for.safeTransferFrom(sc, tradeInfo[_offerID].maker, tradeInfo[_offerID]._for.id);

        // delete to save storage
        // delete tradeInfo[_offerID];
    }

}
