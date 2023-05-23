// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NazCoin {
    string public name = "NazCoin";
    string public symbol = "NAZ";
    uint256 public totalSupply = 1000000 * 10 ** 18;
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public constant marketingWallet = 0xf7779ED8B572d7da3f8c19C2dE3dD55c60b9561e;

    uint256 public constant marketingFee = 10;
    uint256 public constant feeDivider = 100;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "Invalid address");
        require(_to != address(0), "Invalid address");
        require(_value > 0, "Invalid amount");

        uint256 marketingAmount = _value * marketingFee / feeDivider;

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value - marketingAmount;

        balanceOf[marketingWallet] += marketingAmount;

        emit Transfer(_from, _to, _value);
        emit Transfer(_from, marketingWallet, marketingAmount);
    }
    
    function getMarketingBalance() external view returns (uint256) {
        return balanceOf[marketingWallet];
    }
    
    function withdrawMarketingBalance() external {
        uint256 marketingBalance = balanceOf[marketingWallet];
        require(marketingBalance > 0, "No balance to withdraw");
        balanceOf[marketingWallet] = 0;
        payable(marketingWallet).transfer(marketingBalance);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
