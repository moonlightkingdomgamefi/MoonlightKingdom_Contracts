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

contract GuardianWeapon is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    string baseURI;
    string public baseExtension = ".json";
    bool public revealed = false;
    string public notRevealedUri;
    address public gameaddress = 0x0000000000000000000000000000000000000000;
    uint256 public constant maxStamina = 200;
    uint256 public constant secondsPerStamina = 300;
    struct Weapon {
        uint256 id;
        uint8 rarity;
        uint8 level;
        uint16 atk;
        uint8 elemental;
        bool lock;
        uint64 staminaTimestamp;
     }

    Weapon[] public weapons;
  
    event NewWeapon(address indexed owner, uint256 id,uint256 roll);
    event refinevent(address indexed owner, uint256 indexed weapon, uint8 level,string result, uint256 successpercentageInit,uint256 successpercentageAns);
    event burnevent(address indexed owner, uint256 indexed weapon); 

    constructor(
        string memory _initBaseURI,
        string memory _initNotRevealedUri,
        string memory _name, string memory _symbol
       
    ) ERC721(_name, _symbol) 
    {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
        Weapon memory emptyWeapon;
        weapons.push(emptyWeapon);
    }


    function mint(address _minter) public payable {
        require(msg.sender == gameaddress ,"Mint Only from Game Contract!");
        uint256 supply = weapons.length;
        uint8 grade;
        uint256 rAtk;
        uint256 rElemental;
        uint256 roll = block.timestamp % 100;
        if(roll < 5) {
            grade = 4; // SSR at 5%
            rAtk = randomWithMinMax(21,25,block.timestamp); 
            rElemental =  randomWithMinMax(0,5,block.timestamp); 
        }
        else if(roll < 20) { 
            grade = 3; // SR at 15%
            rAtk = randomWithMinMax(16,20,block.timestamp); 
            rElemental =  randomWithMinMax(0,5,block.timestamp); 
        }
        else if(roll < 55) { 
            grade = 2; // S at 35%
            rAtk = randomWithMinMax(11,15,block.timestamp);
            rElemental =  randomWithMinMax(2,5,block.timestamp);  
        }
        else { 
            grade = 1; // R at 45%
            rAtk = randomWithMinMax(6,10,block.timestamp);
            rElemental =  randomWithMinMax(2,5,block.timestamp); 
        }
        uint64 staminaTimestamp = uint64(block.timestamp.sub(getStaminaMaxWait()));
        Weapon memory newWeapon = Weapon(supply, uint8(grade), 1,uint16(rAtk),uint8(rElemental),false,staminaTimestamp);
        weapons.push(newWeapon);
        _safeMint(_minter, supply);
        emit NewWeapon(_minter, supply,roll);
    }
    function burnweapon(address _burner,uint256 _wId) public payable{
        require(msg.sender == gameaddress , "Burn Only from Game Contract!");
        require(ownerOf(_wId) == _burner, "Only Owner of NFT");
        _burn(_wId);
        emit burnevent(_burner,_wId);
    }

    function refine(address _refiner,uint256 _wId) public payable {
        require(msg.sender == gameaddress , "Refine Only from Game Contract!");
        require(ownerOf(_wId) == _refiner, "Only Owner of NFT");
        Weapon storage weapon = weapons[_wId];
        require(weapon.level <= 254, "MAX Level");
        uint256 successPercentage;
        string memory calRefineResult = "Failed";
        uint256 tempUp;
        uint256 rollRefine = block.timestamp % 100;
        if (weapon.level == 1){
            successPercentage = 90;
        }
        if (weapon.level == 2){  
            successPercentage = 80;
        }
        if (weapon.level == 3){ 
            successPercentage = 60;
        }
        if (weapon.level == 4){
            successPercentage = 40;
        }
        if (weapon.level >= 5 && weapon.level <= 7){
            successPercentage = 30;
        }
        if (weapon.level >= 8 && weapon.level <= 9){
            successPercentage = 20;
        }
        if (weapon.level >= 10 && weapon.level <= 254){
            successPercentage = 10;
        }

        if(rollRefine < successPercentage) {
            weapon.level++;
            calRefineResult = "Success";
            if (weapon.rarity == 4){
                tempUp = randomWithMinMax(7,8,block.timestamp % 100);
                weapon.atk += uint8(tempUp);
            }
            else if(weapon.rarity == 3){
                tempUp = randomWithMinMax(5,6,block.timestamp % 100);
                weapon.atk += uint8(tempUp);
            }
            else if(weapon.rarity == 2){
                tempUp = randomWithMinMax(3,4,block.timestamp % 100);
                weapon.atk += uint8(tempUp);
            }
            else {
                tempUp = randomWithMinMax(1,2,block.timestamp % 100);
                weapon.atk += uint8(tempUp);
            }
        }
        emit refinevent(ownerOf(_wId), _wId, weapon.level,calRefineResult,successPercentage,rollRefine);
    }
    function getWeaponAttack(uint256 _wId) public view returns (uint16) {
        return weapons[_wId].atk ;
    }
    function getWeaponLevel(uint256 _wId) public view returns (uint8) {
        return weapons[_wId].level ;
    }
    function getWeaponRarity(uint256 _wId) public view returns (uint8) {
        return weapons[_wId].rarity ;
    }
    function getWeaponLock(uint256 _wId) public view returns (bool) {
        return weapons[_wId].lock ;
    }
    function getWeaponElemental(uint256 _wId) public view returns (uint8) {
        return weapons[_wId].elemental ;
    }

    using SafeMath for uint256;
    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
    
    function setGameAddress(address _addr) public onlyOwner {
        gameaddress = _addr;
    }

    function setWeaponLockByOwner(uint256 _wId,bool _lockInput) public onlyOwner{ 
        Weapon storage weapon = weapons[_wId];
        weapon.lock = _lockInput;
    }

    function setWeaponAtk(uint256 _wId,uint16 _sAtk) public onlyOwner{ 
        Weapon storage weapon = weapons[_wId];
        weapon.atk = _sAtk;
    }

    function setWeaponRarity(uint256 _wId,uint8 _sRarity) public onlyOwner{ 
        Weapon storage weapon = weapons[_wId];
        require(_sRarity <= 4, "No More Than 4");
        weapon.rarity = _sRarity;
    }

    function setWeaponElemental(uint256 _wId,uint8 _sElemental) public onlyOwner{ 
        Weapon storage weapon = weapons[_wId];
        require(_sElemental <= 5, "No More Than 5");
        weapon.elemental = _sElemental;
    }
    
    function setWeaponLevel(uint256 _wId,uint8 _sLevel) public onlyOwner{ 
        Weapon storage weapon = weapons[_wId];
        require(_sLevel <= 255, "No More Than 255");
        weapon.level = _sLevel;
    }

    function randomWithMinMax(uint min, uint max, uint modinput) internal pure returns (uint) {
        // inclusive,inclusive (don't use absolute min and max values of uint256)
        // deterministic based on seed provided
        uint diff = max.sub(min).add(1);
        uint randomVar = uint(keccak256(abi.encodePacked(modinput))).mod(diff);
        randomVar = randomVar.add(min);
        return randomVar;
    }

    function customMint(uint256 _cRare,uint256 _cAtk,uint8 _cElemental) public onlyOwner {
        uint256 supply = weapons.length;
        uint64 staminaTimestamp = uint64(block.timestamp.sub(getStaminaMaxWait()));
        Weapon memory newWeapon = Weapon(supply, uint8(_cRare), 1,uint16(_cAtk),uint8(_cElemental),false,staminaTimestamp);
        weapons.push(newWeapon);
        _safeMint(msg.sender, supply);
        emit NewWeapon(msg.sender, supply,100);
    }

    function getWeapons() public view returns (Weapon[] memory) {
        return weapons;
    }
    
    function getOwnerWeapons(address _owner) public view returns (Weapon[] memory) {
        uint256[] memory allWeaponsofThisOwner = walletOfOwner(_owner);
        Weapon[] memory result = new Weapon[](balanceOf(_owner));
        for (uint256 i = 0; i < allWeaponsofThisOwner.length; i++) 
        {
            result[i] = weapons[allWeaponsofThisOwner[i]];
        }
            return result;
    }

    function walletOfOwner(address _owner)public view returns (uint256[] memory)
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

    function withdraw() public onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }


    //Stamina Calculate Section
    function getStaminaMaxWait() public pure returns (uint64) {
        return uint64(maxStamina * secondsPerStamina);
    }
    function getStaminaTimestamp(uint256 id) public view  returns (uint64) {
        return weapons[id].staminaTimestamp;
    }

    function getStaminaPoints(uint256 id) public view  returns (uint8) {
        return getStaminaPointsFromTimestamp(weapons[id].staminaTimestamp);
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
    function setStaminaTimestamp(uint256 id, uint64 timestamp) public {
        require(msg.sender == gameaddress || msg.sender == owner() , "Only from Game Contract! or Owner");
        weapons[id].staminaTimestamp = timestamp;
    }

}