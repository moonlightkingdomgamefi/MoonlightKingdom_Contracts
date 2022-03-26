  
  // SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MoonExchange is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint64;
    using SafeERC20 for IERC20;
    IERC20 public moonlightToken = IERC20( address(0x0000000000000000000000000000000000000000));
    IERC20 public starlightToken = IERC20( address(0x0000000000000000000000000000000000000000));
    uint256 public exchangePrimaryRate = 1000;
    uint256 public exchangeSecondaryRate = 1;
    uint256 public exchangeFee = 0.0003 ether;
    bool public paused = false;

    function TestGetSLT(uint256 mltAmount) public view returns (uint256) {
        require(mltAmount  > 0, "No Cheat!");
        uint256 sltGet= (exchangePrimaryRate* mltAmount)/exchangeSecondaryRate ;
        require(sltGet > 0 , "Not Reach MLT Minimum at Present Rate");
        return sltGet;
    }

    function TestGetMLT(uint256 sltAmount) public view returns (uint256) {
        require(sltAmount > 0, "No Cheat!");
        uint256 mltGet= (exchangeSecondaryRate * sltAmount)/exchangePrimaryRate ;
        require(mltGet > 0 , "Not Reach SLT Minimum at Present Rate");
        return mltGet;
    }

    function useMLTtoGetSLT(uint256 mltAmount) public payable {
        require(!paused, "Contract is paused!");
        require(msg.value >= exchangeFee, "Not enough funds!");
        uint256 sltGet= (exchangePrimaryRate* mltAmount)/exchangeSecondaryRate ;
        uint256 senderMLTBalance = moonlightToken.balanceOf(msg.sender);
        uint256 exchangeSLTBalance = starlightToken.balanceOf(address(this));
        require(senderMLTBalance >= mltAmount, "Your Moonlight balance is too low");
        require(exchangeSLTBalance >= sltGet, "Moonexchange Starlight balance is too low");
        require(mltAmount > 0, "No Cheat!");
        require(sltGet > 0, "Not Reach MLT Minimum at Present Rate");
        moonlightToken.safeTransferFrom(msg.sender, address(this), mltAmount);
        safestarlightTokenTransfer(msg.sender,sltGet);
    }


    function useSLTtoGetMLT(uint256 sltAmount) public payable {
        require(!paused, "Contract is paused!");
        require(msg.value >= exchangeFee, "Not enough funds!");
        uint256 mltGet= (exchangeSecondaryRate * sltAmount)/exchangePrimaryRate ;
        uint256 senderSLTBalance = starlightToken.balanceOf(msg.sender);
        uint256 exchangeMLTBalance = moonlightToken.balanceOf(address(this));
        require(senderSLTBalance >= sltAmount, "Your Starlight balance is too low");
        require(exchangeMLTBalance >= mltGet, "Moonexchange Moonlight balance is too low");
        require(sltAmount > 0, "No Cheat!");
        require(mltGet > 0, "Not Reach MLT Minimum at Present Rate");
        starlightToken.safeTransferFrom(msg.sender, address(this), sltAmount);
        safemoonlightTokenTransfer(msg.sender,mltGet); 
    }

    function getExchangePrimaryRate() public view returns (uint256) {
        return exchangePrimaryRate;
    }

    function getExchangeSecondaryRate() public view returns (uint256) {
        return exchangeSecondaryRate;
    }

    function updateExchangePrimaryRate(uint256 _newrate) public onlyOwner() {
        exchangePrimaryRate = _newrate;
    }
    function updateExchangeSecondaryRate(uint256 _newrate) public onlyOwner() {
        exchangeSecondaryRate = _newrate;
    }
    function setmoonlightToken(address _addr) public onlyOwner {
        moonlightToken = IERC20(_addr);
    }
    function setstarlightToken(address _addr) public onlyOwner {
        starlightToken = IERC20(_addr);
    }
    function setexchangeFee(uint256 newFee) public onlyOwner {
        exchangeFee = newFee;
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
    
    function withdrawmoonlightToken() public onlyOwner {
        address _owner = owner();
        safemoonlightTokenTransfer(_owner,moonlightToken.balanceOf(address(this)));
    }

    function withdrawstarlightToken() public onlyOwner {
        address _owner = owner();
        safestarlightTokenTransfer(_owner,starlightToken.balanceOf(address(this)));
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