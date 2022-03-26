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
import "./GuardianCharacter.sol";
import "./GuardianWeapon.sol";

contract MoonlightKingdomGames is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint64;
    using SafeERC20 for IERC20;
    mapping(address => uint256) lastBlockNumberCalled;
    uint256 tempRandLucky;
    bool public paused = true;
    uint256 public latestluckyCardNumber;
    uint256 public latesttempRandLucky;
    uint256[] public storeLuckyCardNumber;
    
    uint8 public staminaCostFight = 40;
    uint8 public staminaCostFightWithWeapon = 10;
    
    IERC20 public moonlightToken = IERC20( address(0x0000000000000000000000000000000000000000));
    IERC20 public starlightToken = IERC20( address(0x0000000000000000000000000000000000000000));
    address public eggaddress = 0x0000000000000000000000000000000000000000;
    address public generaleggaddress = 0x0000000000000000000000000000000000000000;
    //Moonlight Cost//
    uint256 public pack1price = 15000 ether;
    uint256 public pack2price = 30000 ether;
    uint256 public pack3price = 45000 ether;
    uint256 public mintweaponcost = 15000 ether;
    uint256 public burnweaponrefund = 5000 ether;
    //Starlight Cost//
    uint256 public refineCost = 5000000 ether;
    uint256 public refineweaponcost = 2500000 ether;
    
    uint256 public constant maxStamina = 200;
    uint256 public constant secondsPerStamina = 300;
    //Fee//
    uint256 public cost = 0.1 ether;
    //////

    uint256 public maxSupply = 20;
    uint16 public maxStageNumber = 20;

    GuardianCharacter public characters;
    GuardianWeapon public weapons;

    event mintcharacter(address indexed owner, uint256 indexed character, uint8 level,string result, uint256 guardianRoll,uint256 monsterRoll);
    event refinevent(address indexed owner, uint256 indexed character, uint8 level,string result, uint256 successpercentageInit,uint256 successpercentageAns);
    event fightResult(uint256 indexed character,uint256 indexed weapon, string result, uint256 guardianRoll,uint256 monsterRoll,uint256 multiplier);

    struct AdventureLog {
        uint256 id;
        uint256 wId;
        string result;
        uint guardianRoll;
        uint dmonsterRollef;
        uint Timestamp;
     }   

    struct MintCharacterPrizeLog {
        uint256 mid;
        uint256 wid;
        address winner;
        uint256 prize;
     }     

    struct MonsterStage {
       
        uint16 atk;
        uint16 def;
        uint256 reward;
        uint8 elemental;
    } 
    AdventureLog[] public adventurelog;
    MonsterStage[] public monsterStage;
    MintCharacterPrizeLog[] public mintcharacterprizelog;

    function addMonsterStage(uint16 atkinput,uint16 definput,uint256 rewardinput,uint8 elementalinput)public onlyOwner{
        require(elementalinput<=5,"Not More Than 5");
        MonsterStage memory newMonsterStage = MonsterStage(atkinput, definput,rewardinput,elementalinput);
        monsterStage.push(newMonsterStage);
    }

    function editMonsterStage(uint16 monid,uint16 atkinput,uint16 definput,uint256 rewardinput,uint8 elementalinput)public onlyOwner{
        require(elementalinput<=5,"Not More Than 5");
        require(monid<=monsterStage.length,"Not More Than Length");
        monsterStage[monid].atk = atkinput;
        monsterStage[monid].def = definput;
        monsterStage[monid].reward = rewardinput;
        monsterStage[monid].elemental = elementalinput;
    }

    function editMaxStageNumber(uint16 newnumber)public onlyOwner{
        maxStageNumber = newnumber;
    }
    
    function initMonsterStage()public onlyOwner{
        MonsterStage memory newMonsterStage = MonsterStage(0, 0, 0, 0);
        monsterStage.push(newMonsterStage);
        //Mission 1//
        newMonsterStage = MonsterStage(14, 9, 550000 ether,2);
        monsterStage.push(newMonsterStage);
        newMonsterStage = MonsterStage(17, 13, 700000 ether,3);
        monsterStage.push(newMonsterStage);
        newMonsterStage = MonsterStage(20, 15, 850000 ether,4);
        monsterStage.push(newMonsterStage);
        newMonsterStage = MonsterStage(22, 19, 950000 ether,5);
        monsterStage.push(newMonsterStage);
        newMonsterStage = MonsterStage(30, 28, 1400000 ether,0);
        monsterStage.push(newMonsterStage);
        //Mission 2//
        newMonsterStage = MonsterStage(25, 21, 1100000 ether,3);
        monsterStage.push(newMonsterStage);
        newMonsterStage = MonsterStage(28, 22, 1250000 ether,2);
        monsterStage.push(newMonsterStage);
        newMonsterStage = MonsterStage(30, 25, 1400000 ether,5);
        monsterStage.push(newMonsterStage);
        newMonsterStage = MonsterStage(33, 28, 1500000 ether,4);
        monsterStage.push(newMonsterStage);
        newMonsterStage = MonsterStage(42, 35, 1900000 ether,1);
        monsterStage.push(newMonsterStage);
    }

    function mintCharacter(address _minter,uint256 _packid) public payable {
        require(_packid <= 3, "No Cheat!");
        if(_packid==0){
            require(msg.sender == eggaddress);
        }
        require(!paused, "Contract is paused!");
        uint256 supply = characters.getLength()-1;
        require(supply + 1 <= maxSupply, "Max supply reached!");
        uint256 amount = 0;
        if (_packid==3){
            if(msg.sender == generaleggaddress){
                characters.mint(_minter, _packid);
            }
            else {
                amount = pack3price  ;  
                require(msg.value >= cost, "Not enough funds!");
                uint256 balance = moonlightToken.balanceOf(msg.sender);
                require(amount <= balance, "Moonlight balance is too low");
                moonlightToken.safeTransferFrom(msg.sender, address(this), amount);
                characters.mint(_minter, _packid);
            }
        }
        else if (_packid==2){
             if(msg.sender == generaleggaddress){
                characters.mint(_minter, _packid);
            }
            else {
                amount = pack2price  ;  
                require(msg.value >= cost, "Not enough funds!");
                uint256 balance = moonlightToken.balanceOf(msg.sender);
                require(amount <= balance, "Moonlight balance is too low");
                moonlightToken.safeTransferFrom(msg.sender, address(this), amount);
                characters.mint(_minter, _packid);
            }
        }
        else if(_packid==1){
             if(msg.sender == generaleggaddress){
                 
                characters.mint(_minter, _packid);
            }
            else {
                amount = pack1price ;   
                require(msg.value >= cost, "Not enough funds!");
                uint256 balance = moonlightToken.balanceOf(msg.sender);
                require(amount <= balance, "Moonlight balance is too low");
                moonlightToken.safeTransferFrom(msg.sender, address(this), amount);
                characters.mint(_minter, _packid);
            }
        }
        else if(_packid==0){
            characters.mint(_minter, _packid);
        }

        supply = characters.getLength()-1;
        
        uint k=0;
        if (supply == maxSupply){
            k = 1;
        }

        if(supply > 0) {
            uint256 allLuckyPoint = characters.getAllLuckyPoint();
            latesttempRandLucky = randomNum(allLuckyPoint, block.timestamp, allLuckyPoint + 1) + 1;
            tempRandLucky = latesttempRandLucky;
            bool calcheck = true ;
            uint256 i = 1;
            while (calcheck) {
                
                 tempRandLucky = tempRandLucky - characters.getLuckyPointFromGuardian(i);
                 
                if (tempRandLucky <= 0) {
                    latestluckyCardNumber = i;
                    calcheck = false ;
                    storeLuckyCardNumber.push(latestluckyCardNumber);
                    }
                i++;
            }
            address giftAddress;
            uint256 giftValue;
            giftAddress = characters.ownerOf(latestluckyCardNumber);
            
            if (k == 0){
                giftValue= amount * 30 / 100;
                if(_packid == 0 || amount == 0){
                    giftValue = 5000 ether;
                }
            }
            if (k == 1){
                giftValue = moonlightToken.balanceOf(address(this)) * 10 / 100;
            }
            
            safemoonlightTokenTransfer(giftAddress , giftValue);

            MintCharacterPrizeLog memory newMintCharacterPrizeLog = MintCharacterPrizeLog( supply,latestluckyCardNumber, giftAddress,giftValue);
            mintcharacterprizelog.push(newMintCharacterPrizeLog);
        }
        
    }

    function refineCharacter(uint256 _gId) public payable {
        require(tx.origin == msg.sender, "No Spam");
        require(lastBlockNumberCalled[msg.sender] < block.number, "No Spam");
        lastBlockNumberCalled[msg.sender] = block.number;
        require(characters.ownerOf(_gId) == msg.sender, "Only Owner of NFT");
        require(msg.value >= cost, "Not enough funds!");
        require(!paused, "Contract is paused!");
        uint256 amount = refineCost;
        uint256 balance = starlightToken.balanceOf(msg.sender);
        require(amount <= balance, "Starlight balance is too low");
        starlightToken.safeTransferFrom(msg.sender, address(this), amount);
        characters.refine(msg.sender, _gId);
    }

    function adventure(uint256 id,uint8 monId,uint256 wId,uint256 fightMultiplier) public payable {
        require(tx.origin == msg.sender, "No Spam");
        require(lastBlockNumberCalled[msg.sender] < block.number, "No Spam");
        lastBlockNumberCalled[msg.sender] = block.number;

        require(characters.ownerOf(id) == msg.sender, "Only Owner of Guardian");
        require(weapons.ownerOf(wId) == msg.sender, "Only Owner of Weapon");
        require(fightMultiplier >= 1 && fightMultiplier <= 5, "1 to 5 Only");
        require(weapons.getWeaponLock(wId) == false, "Weapon Locked!");
        require(msg.value >= cost * fightMultiplier, "Not enough funds!");
        require(!paused, "Contract is paused!");
        require(monId <= maxStageNumber && monId != 0, "No Cheat! (Exceeds Max Stage or Zero Stage)");
        require(monId <= characters.getStageNumber(id), "No Cheat! (Need More Moon Power)");
        string memory adventureresult ;
        
        MonsterStage storage monster = monsterStage[monId];
        require(getAdventurePoolPrize() >= monster.reward * fightMultiplier, "Adventure Rewards Pool is Not Enough!");

        uint8 staminaPoints = getStaminaPointsFromTimestamp(characters.getStaminaTimestamp(id));
        require(staminaPoints >= staminaCostFight * fightMultiplier , "Guardian Not enough stamina!");
        uint64 drainTime = uint64(staminaCostFight * secondsPerStamina * fightMultiplier );
        if(staminaPoints >= maxStamina) { // if stamina full, we reset timestamp and drain from that
            characters.setStaminaTimestamp(id,uint64(block.timestamp - getStaminaMaxWait() + drainTime));
        }
        else {
            uint64 charStamp = (characters.getStaminaTimestamp(id) + drainTime);
            characters.setStaminaTimestamp(id,charStamp);
        }
      
        uint8 weaponstaminaPoints = getStaminaPointsFromTimestamp(weapons.getStaminaTimestamp(wId));
        require(weaponstaminaPoints >= staminaCostFightWithWeapon  * fightMultiplier, "Weapon Not enough stamina!");
        uint64 weapondrainTime = uint64(staminaCostFightWithWeapon * secondsPerStamina  * fightMultiplier);
        if(weaponstaminaPoints >= maxStamina) { // if stamina full, we reset timestamp and drain from that
            weapons.setStaminaTimestamp(wId,uint64(block.timestamp - getStaminaMaxWait() + weapondrainTime));
        }
        else {
            uint64 weaponStamp = (weapons.getStaminaTimestamp(wId) + weapondrainTime);
            weapons.setStaminaTimestamp(wId,weaponStamp);
        }
        
        uint256 gpMulti = elementalCalculator(monster.elemental,weapons.getWeaponElemental(wId));
        
        uint[4] memory calculatedFightResult = fightSimulationCalculated(characters.getGuardianAttack(id) + weapons.getWeaponAttack(wId),characters.getGuardianDefense(id),gpMulti,monster.atk,monster.def);
        if (calculatedFightResult[2] > calculatedFightResult[3]) {
            if (characters.getStageNumber(id) <= monId){
                characters.setGuardianStage(msg.sender,id,monId+1);
            }
            starlightToken.transfer(msg.sender , monster.reward * fightMultiplier);
            adventureresult = "WIN";
        }
        else if (calculatedFightResult[2] == calculatedFightResult[3]) {
            starlightToken.transfer(msg.sender,  (monster.reward * fightMultiplier)*30/100);
            adventureresult = "DRAW";
        }
        else {
            adventureresult = "LOSE";
        }
        
        emit fightResult( id,wId,adventureresult,calculatedFightResult[2],calculatedFightResult[3],gpMulti);
        
        AdventureLog memory newAdventurelog = AdventureLog( id,wId,adventureresult,calculatedFightResult[2],calculatedFightResult[3],block.timestamp);
        adventurelog.push(newAdventurelog);
    }
    

    function fightSimulationCalculated(uint256 gAtk, uint256 gDef, uint256 _gMulti, uint256 mAtk, uint256 mDef) public view returns (uint[4] memory) {
        uint[4] memory simResult;
        uint hp=100;
        uint maxGuardianDmg = (((gAtk*_gMulti)/100) *10)/mDef;
        uint maxMonsterDmg = (mAtk*10)/ gDef;
        uint guardianHit=0;
        uint monsterHit=0;
        bool finish =false;
        uint guardianHittotal=0;
        uint monsterHittotal=0;
        while (finish == false) 
        {
            guardianHit = randomNum(maxGuardianDmg,block.timestamp%maxMonsterDmg,block.timestamp%maxGuardianDmg)+1;
            guardianHittotal =  guardianHittotal + guardianHit;
            if(guardianHittotal >= hp){
                 finish = true;
                 break;
            }
            monsterHit =  randomNum(maxMonsterDmg,block.timestamp%maxGuardianDmg,block.timestamp%maxMonsterDmg)+2;
            monsterHittotal = monsterHittotal + monsterHit;
            if (monsterHittotal >= hp){
                finish = true;
                break;
            }
        }
        simResult = [maxGuardianDmg,maxMonsterDmg,guardianHittotal,monsterHittotal];
        return simResult;
    }

    function elementalCalculator(uint256 monsterElemental,uint256 weaponElemental) internal pure returns (uint8) {
        uint8 elementalmultiplier=100;
        if (weaponElemental == 0){
                if (monsterElemental == 0){elementalmultiplier=100;}
                if (monsterElemental == 1){elementalmultiplier=150;}
                if (monsterElemental == 2){elementalmultiplier=200;}
                if (monsterElemental == 3){elementalmultiplier=200;}
                if (monsterElemental == 4){elementalmultiplier=200;}
                if (monsterElemental == 5){elementalmultiplier=200;}
        }
        if (weaponElemental == 1){
                if (monsterElemental == 0){elementalmultiplier=150;}
                if (monsterElemental == 1){elementalmultiplier=100;}
                if (monsterElemental == 2){elementalmultiplier=200;}
                if (monsterElemental == 3){elementalmultiplier=200;}
                if (monsterElemental == 4){elementalmultiplier=200;}
                if (monsterElemental == 5){elementalmultiplier=200;}
        }
        if (weaponElemental == 2){
                if (monsterElemental == 0){elementalmultiplier=75;}
                if (monsterElemental == 1){elementalmultiplier=75;}
                if (monsterElemental == 2){elementalmultiplier=100;}
                if (monsterElemental == 3){elementalmultiplier=200;}
                if (monsterElemental == 4){elementalmultiplier=100;}
                if (monsterElemental == 5){elementalmultiplier=75;}
        }
        if (weaponElemental == 3){
                if (monsterElemental == 0){elementalmultiplier=75;}
                if (monsterElemental == 1){elementalmultiplier=75;}
                if (monsterElemental == 2){elementalmultiplier=75;}
                if (monsterElemental == 3){elementalmultiplier=100;}
                if (monsterElemental == 4){elementalmultiplier=200;}
                if (monsterElemental == 5){elementalmultiplier=100;}
        }
        if (weaponElemental == 4){
                if (monsterElemental == 0){elementalmultiplier=75;}
                if (monsterElemental == 1){elementalmultiplier=75;}
                if (monsterElemental == 2){elementalmultiplier=100;}
                if (monsterElemental == 3){elementalmultiplier=75;}
                if (monsterElemental == 4){elementalmultiplier=100;}
                if (monsterElemental == 5){elementalmultiplier=200;}
        }
        if (weaponElemental == 5){
                if (monsterElemental == 0){elementalmultiplier=75;}
                if (monsterElemental == 1){elementalmultiplier=75;}
                if (monsterElemental == 2){elementalmultiplier=200;}
                if (monsterElemental == 3){elementalmultiplier=100;}
                if (monsterElemental == 4){elementalmultiplier=75;}
                if (monsterElemental == 5){elementalmultiplier=100;}
        }
    
        return elementalmultiplier;
    }

    function mintWeapon() public payable {
        require(tx.origin == msg.sender, "No Spam");
        require(lastBlockNumberCalled[msg.sender] < block.number, "No Spam");
        lastBlockNumberCalled[msg.sender] = block.number;
        
        require(msg.value >= cost, "Not enough funds!");
        require(!paused, "Contract is paused!");
       
        uint256 amount = mintweaponcost;
        uint256 balance = moonlightToken.balanceOf(msg.sender);
        require(amount <= balance, "Moonlight balance is too low");
        moonlightToken.safeTransferFrom(msg.sender, address(this), amount);
        weapons.mint(msg.sender);
    }

    function refineWeapon(uint256 _wId) public payable {
        require(tx.origin == msg.sender, "No Spam");
        
        require(lastBlockNumberCalled[msg.sender] < block.number, "No Spam");
        
        lastBlockNumberCalled[msg.sender] = block.number;
        
        require(weapons.ownerOf(_wId) == msg.sender, "Only Owner of NFT");
        require(msg.value >= cost, "Not enough funds!");
        require(!paused, "Contract is paused!");
        uint256 amount = refineweaponcost;
        uint256 balance = starlightToken.balanceOf(msg.sender);
        require(amount <= balance, "Starlight balance is too low");
        starlightToken.safeTransferFrom(msg.sender, address(this), amount);
        weapons.refine(msg.sender, _wId);
    }

    function burnWeapon(uint256 _wId) public payable {
        require(tx.origin == msg.sender, "No Spam");
        require(lastBlockNumberCalled[msg.sender] < block.number, "No Spam");
        lastBlockNumberCalled[msg.sender] = block.number;

        require(weapons.ownerOf(_wId) == msg.sender, "Only Owner of NFT");
        require(msg.value >= cost, "Not enough funds!");
        require(moonlightToken.balanceOf(address(this)) >= burnweaponrefund,"Moonlight balance Not Enough");
        require(!paused, "Contract is paused!");
        weapons.burnweapon(msg.sender, _wId);
        moonlightToken.transfer(msg.sender , burnweaponrefund);
    }

    //Parameter Setting//
    function setPack1Price(uint256 _value) public onlyOwner {
        pack1price = _value;
    }
    function setPack2Price(uint256 _value) public onlyOwner {
        pack2price = _value;
    }
    function setPack3Price(uint256 _value) public onlyOwner {
        pack3price = _value;
    }
    function setRefineCost(uint256 _value) public onlyOwner {
        refineCost = _value;
    }
    function setMintweaponcost(uint256 _value) public onlyOwner {
        mintweaponcost = _value;
    }
    function setRefineweaponcost(uint256 _value) public onlyOwner {
        refineweaponcost = _value;
    }
    function setmoonlightToken(address _addr) public onlyOwner {
        moonlightToken = IERC20(_addr);
    }
    function setstarlightToken(address _addr) public onlyOwner {
        starlightToken = IERC20(_addr);
    }
    
    function setCharactersAddress(GuardianCharacter _addr) public onlyOwner {
        characters = _addr;
    }

    function setWeaponsAddress(GuardianWeapon _addr) public onlyOwner {
        weapons = _addr;
    }

    function setEggAddress(address _addr) public onlyOwner {
        eggaddress = _addr;
    }
    function setGeneralEggAddress(address _addr) public onlyOwner {
        generaleggaddress = _addr;
    }

    function setCost(uint256 _newCost) public onlyOwner() {
        cost = _newCost;
    }
    
    function setMaxSupply(uint256 _newMaxSupply) public onlyOwner() {
        maxSupply = _newMaxSupply;
    }

    function setburnweaponrefund(uint256 _newburnweaponrefund) public onlyOwner() {
        burnweaponrefund = _newburnweaponrefund;
    }
    
    
    ////////
    function randomWithMinMax(uint min, uint max, uint modinput) internal pure returns (uint) {
        // inclusive,inclusive (don't use absolute min and max values of uint256)
        // deterministic based on seed provided
        uint diff = max.sub(min).add(1);
        uint randomVar = uint(keccak256(abi.encodePacked(modinput))).mod(diff);
        randomVar = randomVar.add(min);
        return randomVar;
    }
    
    function randomNum(uint256 _mod, uint256 _seed, uint256 _salt) public view returns(uint256) {
      uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
    }
     function getStaminaMaxWait() public pure returns (uint64) {
        return uint64(maxStamina * secondsPerStamina);
    }
    function getStoreLuckyCardNumber() public view returns (uint256[] memory) {
        return storeLuckyCardNumber;
    }
    
    function getAdventurePoolPrize() public view returns (uint256) {
        return starlightToken.balanceOf(address(this));
    }
    
    function getJackpotPoolPrize() public view returns (uint256) {
        return moonlightToken.balanceOf(address(this)) * 10 / 100;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function safemoonlightTokenTransfer(address _to, uint256 _amount) internal {
        uint256 moonlightTokenBal = moonlightToken.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > moonlightTokenBal) {
            transferSuccess = moonlightToken.transfer(_to, moonlightTokenBal);
        } else {
            transferSuccess = moonlightToken.transfer(_to, _amount);
        }
        require(transferSuccess, "safemoonlightTokenTransfer: Transfer failed");
    }

    function safestarlightTokenTransfer(address _to, uint256 _amount) internal {
        uint256 starlightTokenBal = starlightToken.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > starlightTokenBal) {
            transferSuccess = starlightToken.transfer(_to, starlightTokenBal);
        } else {
            transferSuccess = starlightToken.transfer(_to, _amount);
        }
        require(transferSuccess, "safestarlightTokenTransfer: Transfer failed");
    }

    function withdraw() public onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    function withdrawmoonlightToken() public onlyOwner {
        address _owner = owner();
        safemoonlightTokenTransfer(_owner,moonlightToken.balanceOf(address(this)));
    }

    function withdrawstarlightToken() public onlyOwner {
        address _owner = owner();
        safestarlightTokenTransfer(_owner,starlightToken.balanceOf(address(this)));
    }

    function getallAdventureLog() public view returns (AdventureLog[] memory) {
        return adventurelog;
    }

    function getallMintPrizeLog() public view returns (MintCharacterPrizeLog[] memory) {
        return mintcharacterprizelog;
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
    
    function getMonsters() public view returns (MonsterStage[] memory) {
        return monsterStage;
    }
}
  
