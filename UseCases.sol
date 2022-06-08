// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "../contracts/4_Currency.sol";
import "../contracts/10_LiquidityPool.sol";

contract UseCases {
   
    Currency currency1;
    Currency currency2;
    LiquidityPool liquidityPool1;

    Currency currency3;
    Currency currency4;
    LiquidityPool liquidityPool2;

    constructor(Currency _currency1, Currency _currency2, LiquidityPool _liquidityPool1, 
                Currency _currency3, Currency _currency4, LiquidityPool _liquidityPool2) {
        currency1 = _currency1;
        currency2 = _currency2;
        liquidityPool1 = _liquidityPool1;

        currency3 = _currency3;
        currency4 = _currency4;
        liquidityPool2 = _liquidityPool2;

    }

    function payForInsuranceFirstLiquidityPool(uint256 _amount) external payable {
        uint256 _userCurrency1AmountPrePayment = currency1.getBalanceOfAddress();
        uint256 _lpCurrency1AmountPrePayment = liquidityPool1.getCurrency1Amount();
        uint256 insuranceAmountInWei = currency1.convert(_amount, true);

        liquidityPool1.payForInsuranceWithFirstCurrency(_amount);

        Assert.equal(currency1.getBalanceOfAddress(), _userCurrency1AmountPrePayment - _amount, "User wallet debit performed");
        Assert.equal(liquidityPool1.getCurrency1Amount(), _lpCurrency1AmountPrePayment + _amount, "Pool credit performed");
        Assert.equal(liquidityPool1.getInsuranceBalanceForAddress(), 5 * insuranceAmountInWei, "Insurance issued");
    }

    function withdrawInsuranceFromSameLiquidityPool() external payable {
        uint256 _userCurrency1AmountPrePayment = currency1.getBalanceOfAddress();
        uint256 _userCurrency2AmountPrePayment = currency2.getBalanceOfAddress();

        uint256 _lpCurrency1AmountPrePayment = liquidityPool1.getCurrency1Amount();
        uint256 _lpCurrency2AmountPrePayment = liquidityPool1.getCurrency2Amount();

        liquidityPool1.withdrawInsurance();

        bool userReceivedInsuranceInCurrency1 = _userCurrency1AmountPrePayment > currency1.getBalanceOfAddress();
        bool userReceivedInsuranceInCurrency2 = _userCurrency2AmountPrePayment > currency2.getBalanceOfAddress();

        bool insurancedPayedFromCurrency1 = liquidityPool1.getCurrency1Amount() != _lpCurrency1AmountPrePayment;
        bool insurancedPayedFromCurrency2 = liquidityPool1.getCurrency2Amount() != _lpCurrency2AmountPrePayment;


        Assert.equal(userReceivedInsuranceInCurrency1 || userReceivedInsuranceInCurrency2, true, "Insurance payed to user");
        Assert.equal(insurancedPayedFromCurrency1 || insurancedPayedFromCurrency2, true, "Insurance payed from first currency");

    }


    function withdrawInsuranceFromDifferentLiquidityPool() external payable {

    }
}
