// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Q2Vesting is Ownable {
  using SafeMath for uint256;

  IERC20 public token;

  mapping(address => uint256) public unLockDateMap;
  mapping(address => uint256) public unLockTokenAmount;

  event WithDrawnToken(address indexed manager, uint256 amount);
  event InvestorAccountAdded(
    address indexed manager,
    uint256 _unLockDate,
    uint256 amount
  );

  modifier unlockCheck() {
    require(
      unLockTokenAmount[msg.sender] != 0,
      "You do not have permission to unlock"
    );
    _;
  }

  constructor(address _token) {
    token = IERC20(_token);
  }

  function addInvestorAccount(
    address _investorAccount,
    uint256 unLockDate,
    uint256 amount
  ) public onlyOwner {
    require(
      unLockDateMap[_investorAccount] == 0,
      "Investor Accoun Already Added"
    );
    unLockDateMap[_investorAccount] = unLockDate;
    unLockTokenAmount[_investorAccount] = amount;
    emit InvestorAccountAdded(_investorAccount, unLockDate, amount);
  }

  function blockTimestamp() public view virtual returns (uint256) {
    return block.timestamp;
  }

  function balanceOf() public view returns (uint256) {
    return token.balanceOf(address(this));
  }

  function unlockQ2() public unlockCheck {
    require(
      blockTimestamp() > unLockDateMap[msg.sender],
      "It's not time to unlock"
    );
    _safeTransfer(unLockTokenAmount[msg.sender]);
    unLockTokenAmount[msg.sender] = 0;
    emit WithDrawnToken(msg.sender, unLockTokenAmount[msg.sender]);
  }

  function unLockTime(address userAddress) public view returns (uint256) {
    return unLockDateMap[userAddress];
  }

  function unLockAmount(address userAddress) public view returns (uint256) {
    return unLockTokenAmount[userAddress];
  }

  function _safeTransfer(uint256 tokenNum) private {
    require(
      balanceOf() >= tokenNum,
      "Insufficient available balance for transfer"
    );
    token.transfer(msg.sender, tokenNum);
  }
}
