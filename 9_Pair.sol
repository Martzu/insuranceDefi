pragma solidity >= 0.6.0;

import "./4_Currency.sol";

contract Pair{

    Currency currency1;
    Currency currency2;

    uint256 currency1Amount;
    uint256 currency2Amount;

    constructor(Currency _currency1, Currency _currency2, uint256 _currency1Amount, uint256 _currency2Amount){
        //add currentSupply validation for pools constructor
        //can avoid currentSupplyValidation, on deployment the amounts are taken from deployers wallet

        _currency1.transferCurrency(msg.sender, address(this), _currency1Amount);
        currency1 = _currency1;
        currency1Amount = _currency1Amount;

        _currency2.transferCurrency(msg.sender, address(this), _currency2Amount);
        currency2 = _currency2;
        currency2Amount = _currency2Amount;

    }

    function buyFirstCurrency(uint256 _amount) external payable{
        buyCurrency(currency2, currency1, _amount);
    }

    function buySecondCurrency(uint256 _amount) external payable{
        buyCurrency(currency1, currency2, _amount);
    }

    function buyCurrency(Currency _currency1, Currency _currency2, uint256 _amount) internal {
        require(currency1.getBalanceOfAddress() >= _amount, "You do not have enough currency");
        require(_amount <= currency2Amount, "Cannot buy more than the total amount in the pair");

        uint256 _feeAmount = calculateFee(currency1, _amount);
        _amount = _amount - _feeAmount;

        uint256 _currency2Amount = convert(_currency1, _currency2, _amount);//convert amount after extracting the fee

        _currency1.transferCurrency(msg.sender, address(this), _amount + _feeAmount);//contract receives the amount and the fee
        _currency2.transferCurrency(address(this), msg.sender, _currency2Amount);

        currency1Amount -= _amount + _feeAmount;
        currency2Amount += _currency2Amount;

    }

    function calculateFee(Currency _currency, uint256 _amount) internal view returns(uint256){
        uint256 _weiAmount = _currency.convert(_amount, true);
        uint256 _fee = _weiAmount / 1000; //0.1% fee per exchange
        uint256 _currencyFeeAmount = _currency.convert(_fee, false);
        return _currencyFeeAmount;
    }

    function convert(Currency _currency1, Currency _currency2, uint256 _amount) internal view returns(uint256){

        uint256 _firstConversionAmount = _currency1.convert(_amount, true);
        uint256 _finalConversionAmount = _currency2.convert(_firstConversionAmount, false);
        return _finalConversionAmount;
    }


    function getCurrency1Amount() external view returns(uint256) {
        return currency1Amount;
    }

    function getCurrency2Amount() external view returns(uint256) {
        return currency2Amount;
    }
}