pragma solidity >= 0.6.0;

import "./9_Pair.sol";

contract LiquidityPool is Pair {
    constructor(Currency _currency1, Currency _currency2, uint256 _currency1Amount, uint256 _currency2Amount)
    Pair(_currency1, _currency2, _currency1Amount, _currency2Amount){}
    //first use case: insurance has to be paid in two currencies both from the same lp
    //second use case: insurance has to be paid from two currencies in different lp
    // => the one that withdraws needs a third currency to pay and can swap the amount received from the first pool
    // => call withdrawInsurance(), view currency1.balanceOFAddress and currency2.balanceOfAddress to determine what currency we received and perform the swap required
    //

    //define the time period, amount, currencies, expiration once its payed must pay premium again to be insured

    mapping(address => uint256) private insuranceBalancesToPay;//holds wei debt

    function withdrawInsurance() external payable{
        if(currency1Amount > currency2Amount){
            transferSumInsured(currency1, currency2, currency1Amount, currency2Amount);
        }
        else {
            transferSumInsured(currency2, currency1, currency2Amount, currency1Amount);
        }
    }

    function transferSumInsured(Currency _currency1, Currency _currency2, uint256 _currency1Amount, uint256 _currency2Amount) public payable {
        uint256 insuranceAmount = insuranceBalancesToPay[msg.sender];
        uint256 amountDifference = _currency1Amount - _currency2Amount;
        uint256 amountDifferenceInWei = _currency1.convert(amountDifference, true);
        //transfer the amountDifference
        if(insuranceAmount > amountDifferenceInWei ){
            uint256 residualAmount = insuranceAmount - amountDifferenceInWei;
            //split the residualAmount half and half between the pairs
            uint256 currency1AmountToTransfer = _currency1.convert(residualAmount / 2, false);
            uint256 currency2AmountToTransfer = _currency2.convert(residualAmount / 2, false);

            _currency1.transferCurrency(address(this), msg.sender, currency1AmountToTransfer + amountDifference);
            _currency2.transferCurrency(address(this), msg.sender, currency2AmountToTransfer);

            currency1Amount -= (currency1AmountToTransfer + amountDifference);
            currency2Amount -= currency2AmountToTransfer;
        }
        else if(insuranceAmount <= amountDifferenceInWei){
            uint256 currency1AmountToTransfer = _currency1.convert(insuranceAmount, false);//send the amount insured from the higher amount currency
            _currency1.transferCurrency(address(this), msg.sender, currency1AmountToTransfer);

            currency1Amount -= currency1AmountToTransfer;
        }
        insuranceBalancesToPay[msg.sender] = 0;//insurance paid
    }

    function payForInsuranceWithFirstCurrency(uint256 _amount) external payable {
        payForInsurance(currency1, _amount);
    }

    function payForInsuranceWithSecondCurrency(uint256 _amount) external payable {
        payForInsurance(currency2, _amount);
    }

    function payForInsurance(Currency _currency, uint256 _amount) public payable {
        require(_currency.getBalanceOfAddress() >= _amount, "Not enough currency");
        uint256 insuredAmountInWei = _currency.convert(_amount, true);
        insuranceBalancesToPay[msg.sender] = 5 * insuredAmountInWei;
        _currency.transferCurrency(msg.sender, address(this), _amount);
    }

    function getInsuranceBalanceForAddress() external view returns(uint256){
        return insuranceBalancesToPay[msg.sender];
    }
}