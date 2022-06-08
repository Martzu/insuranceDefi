pragma solidity >=0.6.0;

import "./4_Currency.sol";

contract AAD is Currency{
    constructor(uint256 _conversionRate, uint256 _totalSupply) Currency(_conversionRate, _totalSupply){}
}