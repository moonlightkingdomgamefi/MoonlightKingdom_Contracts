// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./MoonlightKingdomGames.sol";

contract GuardianPrimeEgg is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using SafeERC20 for IERC20;
    string baseURI;
    string public baseExtension = "";
    bool public revealed = false;
    string public notRevealedUri;
    uint256 public eggcost = 500 ether;
    uint256 public hatchcost = 1 ether;
    uint256 public eggMaxSupply = 100;
    uint256 public refPercent = 10;
    uint256 public cashBackPercent = 2;
    address public devWalletAddress = 0x0000000000000000000000000000000000000000;
    bool public mintpaused = true;
    bool public hatchpaused = true;
    struct Egg {
        uint256 id;
     }
    struct ReferralLog {
        address minterAddress;
        address refAddress;
        uint256 refValue;
        uint256 eggId;
     }   

    Egg[] public eggs;
    MoonlightKingdomGames public games;
    ReferralLog[] public referralLog;

    event NewEgg(address indexed owner, uint256 id);
    event HatchEvent(address indexed owner,  uint256 id);

    constructor(
        string memory _initBaseURI,
        string memory _initNotRevealedUri,
        string memory _name, 
        string memory _symbol
    ) ERC721(_name, _symbol) 
    {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
        Egg memory emptyEgg;
        eggs.push(emptyEgg);
        devWalletAddress = msg.sender;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
    
    function setGameAddress(MoonlightKingdomGames _addr) public onlyOwner {
        games = _addr;
    }

    function setDevWalletAddress(address _addr) public onlyOwner {
        devWalletAddress = _addr;
    }

    function setrefPercent(uint256 newrefPercent) public onlyOwner {
        refPercent = newrefPercent;
    }

    function setcashBackPercent(uint256 newcashBackPercent) public onlyOwner {
        cashBackPercent = newcashBackPercent;
    }
    function getallReferralLog() public view returns (ReferralLog[] memory) {
        return referralLog;
    }
    // public
    function mint(address _ref) public payable { 
        require(msg.value >= eggcost, "Not enough funds!");
        require(!mintpaused, "Sell is paused!");
        uint256 supply = eggs.length-1;
        require(supply < eggMaxSupply,"Sold Out !");

        address payable giftAddress = payable(_ref);
        address payable cashBackAddress = payable(msg.sender);
        uint256 giftValue;
        uint256 cashBackValue;
        if(_ref != devWalletAddress && _ref != msg.sender){
            giftValue = msg.value * refPercent / 100 ;
            cashBackValue = msg.value * cashBackPercent / 100 ;
            (bool refSuccess, ) = payable(giftAddress).call{value: giftValue}("");
            (bool cashBackSuccess, ) = payable(cashBackAddress).call{value: cashBackValue}("");
            require(refSuccess, "Could not send Gift to Ref!");
            require(cashBackSuccess, "Could not send CashBack to Minter!");
            Egg memory newEgg = Egg(supply+1);
            eggs.push(newEgg);
            _safeMint(msg.sender, supply+1);
            emit NewEgg(msg.sender, supply+1);
            ReferralLog memory newReferralLog = ReferralLog( msg.sender,_ref,giftValue,supply+1);
            referralLog.push(newReferralLog);
        }
        else {
            Egg memory newEgg = Egg(supply+1);
            eggs.push(newEgg);
            _safeMint(msg.sender, supply+1);
            emit NewEgg(msg.sender, supply+1);
        }
    }

    function hatch(uint256 _eId) public payable { 
        require(msg.value >= hatchcost, "Not enough funds!");
        require(ownerOf(_eId) == msg.sender, "Only Owner of Egg");
        require(!hatchpaused, "Hatch is paused!");
        games.mintCharacter(msg.sender,0);
        _burn(_eId);
        emit HatchEvent( msg.sender,_eId);
    }
    //WebFunction
    using SafeMath for uint256;

    function getEggs() public view returns (Egg[] memory) {
        return eggs;
    }


    function getOwnerEggs(address _owner) public view returns (Egg[] memory) {
        uint256[] memory allEggsofThisOwner = walletOfOwner(_owner);
        Egg[] memory result = new Egg[](balanceOf(_owner));
        for (uint256 i = 0; i < allEggsofThisOwner.length; i++) 
        {
                result[i] = eggs[allEggsofThisOwner[i]];
        }
        return result;
    }
  
    //Utility
     function randomWithMinMax(uint min, uint max, uint modinput) internal pure returns (uint) {
        // inclusive,inclusive (don't use absolute min and max values of uint256)
        // deterministic based on seed provided
        uint diff = max.sub(min).add(1);
        uint randomVar = uint(keccak256(abi.encodePacked(modinput))).mod(diff);
        randomVar = randomVar.add(min);
        return randomVar;
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
        tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
    }

    //only owner
    function reveal() public onlyOwner() {
        revealed = true;
    }
    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setStartSellEgg() public onlyOwner {
        mintpaused = false;
    }

    function setStopSellEgg() public onlyOwner {
        mintpaused = true;
    }

    function setStartHatchEgg() public onlyOwner {
        hatchpaused = false;
    }

    function setStopHatchEgg() public onlyOwner {
        hatchpaused = true;
    }

    function setEggCost(uint256 neweggcost) public onlyOwner {
        eggcost = neweggcost;
    }

    function setHatchCost(uint256 newhatchcost) public onlyOwner {
        hatchcost = newhatchcost;
    }
    

    function setEggMaxSupply(uint256 neweggmaxsupply) public onlyOwner {
        eggMaxSupply = neweggmaxsupply;
    }
    
    function getEggLength() public view returns (uint256) {
        return eggs.length;
    }
    
    function withdraw() public onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
    }
}