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

contract GuardianCharacter is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using SafeERC20 for IERC20;
    string baseURI;
    string public baseExtension = ".json";
    bool public revealed = false;
    string public notRevealedUri;
    uint256 public allLuckyPoint;
 
    address public gameaddress = 0x0000000000000000000000000000000000000000;
    
    struct Guardian {
        uint256 id;
        uint8 rarity;
        uint8 level;
        uint16 atk;
        uint16 def;
        uint16 luckyPoint;
        uint64 staminaTimestamp;
        uint16 stage;
        bool lock;
     }

    Guardian[] public guardians;
  
    event NewGuardian(address indexed owner, uint256 id,uint256 roll);
    event refinevent(address indexed owner, uint256 indexed character, uint8 level,string result, uint256 successpercentageInit,uint256 successpercentageAns);

    uint256 public constant maxStamina = 200;
    uint256 public constant secondsPerStamina = 300;

    constructor(
        string memory _initBaseURI,
        string memory _initNotRevealedUri,
        string memory _name, string memory _symbol
    ) ERC721(_name, _symbol) 
    {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
        Guardian memory emptyGuardian;
        guardians.push(emptyGuardian);
    }
  
    
    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
    
    function setGameAddress(address _addr) public onlyOwner {
        gameaddress = _addr;
    }
  
  
    // public
    function mint(address _minter, uint256 packid) public payable {
        require(msg.sender == gameaddress ,"Mint Only from Game Contract!");
        require(packid <= 3, "No Cheat!");
        uint256 supply = guardians.length;
        uint8 grade;
        uint256 rAtk;
        uint256 rDef;
        uint256 rluckyPoint;
        uint256 roll = block.timestamp % 100;
        uint16 rStage;
        if (packid==0){
            if(roll < 20) {
                grade = 6; // God at 20%
                rAtk = randomWithMinMax(41,45,block.timestamp);
                rDef = randomWithMinMax(41,45,block.timestamp % 100);
                rluckyPoint = 6;
                rStage = 6;
            }
            else { 
                grade = 5; // Legend at 80%
                rAtk = randomWithMinMax(36,40,block.timestamp);
                rDef = randomWithMinMax(36,40,block.timestamp % 100);
                rluckyPoint = 5;
                rStage = 5;
            }
            
        }

        else if (packid==3){
            if(roll < 10) {
                grade = 4; // SSR at 10%
                rAtk = randomWithMinMax(26,35,block.timestamp);
                rDef = randomWithMinMax(26,35,block.timestamp % 100);
                rluckyPoint = 4;
                rStage = 4;
            }
             else if(roll < 25) {  
                grade = 3; // SR at 15%
                rAtk = randomWithMinMax(21,25,block.timestamp);
                rDef = randomWithMinMax(21,25,block.timestamp % 100);
                rluckyPoint = 3;
                rStage = 3;
            }
             else if(roll < 60) { 
                grade = 2; // S at 35%
                rAtk = randomWithMinMax(16,20,block.timestamp);
                rDef = randomWithMinMax(16,20,block.timestamp % 100);
                rluckyPoint = 2;
                rStage = 2;
            }
            else { 
                grade = 1; // R at 40%
                rAtk = randomWithMinMax(11,15,block.timestamp);
                rDef = randomWithMinMax(11,15,block.timestamp % 100);
                rluckyPoint = 1;
                rStage = 1;
            }
            
        }

        else if (packid==2){
            if(roll < 6) {
                grade = 4; // SSR at 6%
                rAtk = randomWithMinMax(26,35,block.timestamp);
                rDef = randomWithMinMax(26,35,block.timestamp % 100);
                rluckyPoint = 4;
                rStage = 4;
            }
            else if(roll < 18) { 
                grade = 3; // SR at 12%
                rAtk = randomWithMinMax(21,25,block.timestamp);
                rDef = randomWithMinMax(21,25,block.timestamp % 100);
                rluckyPoint = 3;
                rStage = 3;
            }
            else if(roll < 48) { 
                grade = 2; // S at 30%
                rAtk = randomWithMinMax(16,20,block.timestamp);
                rDef = randomWithMinMax(16,20,block.timestamp % 100);
                rluckyPoint = 2;
                rStage = 2;
            }
            else { 
                grade = 1; // R at 52%
                rAtk = randomWithMinMax(11,15,block.timestamp);
                rDef = randomWithMinMax(11,15,block.timestamp % 100);
                rluckyPoint = 1;
                rStage = 1;
            }
        }

        else {
            if(roll < 3) {
                grade = 4; // SSR at 3%
                rAtk = randomWithMinMax(26,35,block.timestamp);
                rDef = randomWithMinMax(26,35,block.timestamp % 100);
                rluckyPoint = 4;
                rStage = 4;
            }
            else if(roll < 13) { 
                grade = 3; // SR at 10%
                rAtk = randomWithMinMax(21,25,block.timestamp);
                rDef = randomWithMinMax(21,25,block.timestamp % 100);
                rluckyPoint = 3;
                rStage = 3;
            }
            else if(roll < 38) { 
                grade = 2; // S at 25%
                rAtk = randomWithMinMax(16,20,block.timestamp);
                rDef = randomWithMinMax(16,20,block.timestamp % 100);
                rluckyPoint = 2;
                rStage = 2;
            }
            else { 
                grade = 1; // R at 62%
                rAtk = randomWithMinMax(11,15,block.timestamp);
                rDef = randomWithMinMax(11,15,block.timestamp % 100);
                rluckyPoint = 1;
                rStage = 1;
            }

        }

        allLuckyPoint += rluckyPoint;
        uint64 staminaTimestamp = uint64(block.timestamp.sub(getStaminaMaxWait()));
        Guardian memory newGuardian = Guardian(supply, uint8(grade), 1,uint16(rAtk),  uint16(rDef),uint16(rluckyPoint),staminaTimestamp,uint16(rStage),false);
        guardians.push(newGuardian);
        _safeMint(_minter, supply);
        emit NewGuardian(_minter, supply,roll);
        
    }

    function refine(address _refiner,uint256 _gId) public payable {
        require(msg.sender == gameaddress , "Refine Only from Game Contract!");
        require(ownerOf(_gId) == _refiner, "Only Owner of NFT");

        Guardian storage guardian = guardians[_gId];
        
        require(guardian.level <= 254, "MAX Level");
        
        uint256 successPercentage;
        string memory calRefineResult = "Failed";
        uint256 tempUp;
        uint256 rollRefine = block.timestamp % 100;
        if (guardian.level == 1){
            successPercentage = 80;
        }
        if (guardian.level == 2){  
            successPercentage = 60;
        }
        if (guardian.level == 3){ 
            successPercentage = 40;
        }
        if (guardian.level == 4){
            successPercentage = 20;
        }
        if (guardian.level >= 5 && guardian.level <= 7){
            successPercentage = 10;
        }
        if (guardian.level >= 8 && guardian.level <= 9){
            successPercentage = 8;
        }
        if (guardian.level >= 10 && guardian.level <= 254){
            successPercentage = 5;
        }

        if(rollRefine < successPercentage) {
            guardian.level++;
            guardian.staminaTimestamp = uint64(block.timestamp.sub(getStaminaMaxWait()));
            calRefineResult = "Success";
            if (guardian.rarity == 6){
                tempUp = randomWithMinMax(11,12,block.timestamp % 100);
                guardian.atk += uint8(tempUp);
                tempUp = randomWithMinMax(11,12,block.timestamp);
                guardian.def += uint8(tempUp);
                tempUp = 6;
                guardian.luckyPoint += uint8(tempUp);
                allLuckyPoint += uint8(tempUp);
            }
            if (guardian.rarity == 5){
                tempUp = randomWithMinMax(9,10,block.timestamp % 100);
                guardian.atk += uint8(tempUp);
                tempUp = randomWithMinMax(9,10,block.timestamp);
                guardian.def += uint8(tempUp);
                tempUp = 5;
                guardian.luckyPoint += uint8(tempUp);
                allLuckyPoint += uint8(tempUp);
            }
            else if (guardian.rarity == 4){
                tempUp = randomWithMinMax(7,8,block.timestamp % 100);
                guardian.atk += uint8(tempUp);
                tempUp = randomWithMinMax(7,8,block.timestamp);
                guardian.def += uint8(tempUp);
                tempUp = 4;
                guardian.luckyPoint += uint8(tempUp);
                allLuckyPoint += uint8(tempUp);
            }
            else if(guardian.rarity == 3){
                tempUp = randomWithMinMax(5,6,block.timestamp % 100);
                guardian.atk += uint8(tempUp);
                tempUp = randomWithMinMax(5,6,block.timestamp);
                guardian.def += uint8(tempUp);
                tempUp = 3;
                guardian.luckyPoint += uint8(tempUp);
                allLuckyPoint += uint8(tempUp);
            }
            else if(guardian.rarity == 2){
                tempUp = randomWithMinMax(3,4,block.timestamp % 100);
                guardian.atk += uint8(tempUp);
                tempUp = randomWithMinMax(3,4,block.timestamp);
                guardian.def += uint8(tempUp);
                tempUp = 2;
                guardian.luckyPoint += uint8(tempUp);
                allLuckyPoint += uint8(tempUp);
            }
            else {
                tempUp = randomWithMinMax(1,2,block.timestamp % 100);
                guardian.atk += uint8(tempUp);
                tempUp = randomWithMinMax(1,2,block.timestamp);
                guardian.def += uint8(tempUp);
                tempUp = 1;
                guardian.luckyPoint += uint8(tempUp);
                allLuckyPoint += uint8(tempUp);
            }
        }
        emit refinevent(ownerOf(_gId), _gId, guardian.level,calRefineResult,successPercentage,rollRefine);
    }

    function setGuardianStage(address _setter,uint256 _gId,uint16 _stageInput) public { 
        require(msg.sender == gameaddress , "Set Only from Game Contract!");
        require(ownerOf(_gId) == _setter, "Only Owner of NFT");
        Guardian storage guardian = guardians[_gId];
        require(guardian.stage <= 65534, "MAX Stage");
        guardian.stage = _stageInput;
    }

   

    //Stamina Calculate Section
    function getStaminaMaxWait() public pure returns (uint64) {
        return uint64(maxStamina * secondsPerStamina);
    }
    function getStaminaTimestamp(uint256 id) public view  returns (uint64) {
        return guardians[id].staminaTimestamp;
    }

    function getStaminaPoints(uint256 id) public view  returns (uint8) {
        return getStaminaPointsFromTimestamp(guardians[id].staminaTimestamp);
    }

    function getStaminaPointsFromTimestamp(uint64 timestamp) public view returns (uint8) {
        if(timestamp  > block.timestamp)
            return 0;

        uint256 points = (block.timestamp - timestamp) / secondsPerStamina;
        if(points > maxStamina) {
            points = maxStamina;
        }
        return uint8(points);
    }

    function isStaminaFull(uint256 id) public view returns (bool) {
        return getStaminaPoints(id) >= maxStamina;
    }
  
    ////////////////////////////


    //WebFunction
    using SafeMath for uint256;

    function getGuardians() public view returns (Guardian[] memory) {
        return guardians;
    }
    function getLength() public view returns (uint256) {
        return guardians.length;
    }
    
    function getLuckyPointFromGuardian(uint256 _gId) public view returns (uint16) {
        return guardians[_gId].luckyPoint ;
    }
    
    function getAllLuckyPoint() public view returns (uint256) {
        return allLuckyPoint ;
    }

    function getStageNumber(uint256 _gId) public view returns (uint16) {
        return guardians[_gId].stage ;
    }
    
    function getGuardianAttack(uint256 _gId) public view returns (uint16) {
        return guardians[_gId].atk ;
    }
    function getGuardianDefense(uint256 _gId) public view returns (uint16) {
        return guardians[_gId].def ;
    }
    function getGuardianLevel(uint256 _gId) public view returns (uint8) {
        return guardians[_gId].level ;
    }
   

    function getOwnerGuardians(address _owner) public view returns (Guardian[] memory) {
        uint256[] memory allGuardiansofThisOwner = walletOfOwner(_owner);
        Guardian[] memory result = new Guardian[](balanceOf(_owner));
        for (uint256 i = 0; i < allGuardiansofThisOwner.length; i++) 
        {
                result[i] = guardians[allGuardiansofThisOwner[i]];
        }
        return result;
    }
  
    function getOwnerLuckyPoint(address _owner) public view returns (uint) {
        uint256 luckycounter = 0;
        uint256[] memory allGuardiansofThisOwner = walletOfOwner(_owner);
        for (uint256 i = 1; i <= allGuardiansofThisOwner.length; i++) 
        {
                luckycounter += guardians[i].luckyPoint;
        }
        return luckycounter;
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
  
    function randomNum(uint256 _mod, uint256 _seed, uint256 _salt) public view returns(uint256) {
      uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
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
    
    function setStaminaTimestamp(uint256 id, uint64 timestamp) public {
        require(msg.sender == gameaddress || msg.sender == owner() , "Only from Game Contract! or Owner");
        guardians[id].staminaTimestamp = timestamp;
    }

    function withdraw() public onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    function setGuardianLockByOwner(uint256 id,bool _lockInput) public onlyOwner{ 
        guardians[id].lock = _lockInput;
    }
     function getGuardianLock(uint256 id) public view returns (bool) {
        return guardians[id].lock ;
    }
}