pragma solidity >=0.6.0;

contract Currency{
    mapping(address => uint256) private balances;
    uint256 private totalSupply;
    uint256 currentSupply;
    uint256 private conversionRate;

    constructor(uint256 _conversionRate, uint256 _totalSupply) {
        conversionRate = _conversionRate;
        totalSupply = _totalSupply;
        currentSupply = _totalSupply;
    }

    event Transfer(address _from, address _to, uint256 _amount);

    function buy() external payable {
        uint256 _value = msg.value;
        require(_value > 1 wei, "Minimum transaction is 1 wei");

        uint256 _amount = convert(_value, conversionRate, true);
        //currentSupply -= _amount;
        balances[msg.sender] = _amount;
    }

    function sell(uint256 _amount) external payable {
        require(_amount <= balances[msg.sender], "Cannot sell more than you own");
        balances[msg.sender] -= _amount;
        //currentSupply += _amount;

        uint256 _value = convert(_amount, conversionRate, false);
        payable(msg.sender).transfer(_value);
        
        
    }

    function transferCurrency(address _from, address _to, uint256 _amount) external payable {
        require(balances[_from] >= _amount, "Cannot send more than you own");
        balances[_from] -= _amount;
        balances[_to] += _amount;

        emit Transfer(_from, _to, _amount);
    }

    function getBalanceOfAddress() external view returns(uint256) {
        return balances[msg.sender];
    }

    function convert(uint256 _amount, bool _from) external view returns(uint256) {
        return convert(_amount, conversionRate, _from);
    }

    function convert(uint256 _amount, uint256 _conversionRate, bool from) public pure returns(uint256) {
        return from ? _amount / _conversionRate : _amount * _conversionRate;
    }

    function getConversionRate() public view returns(uint256) {
        return conversionRate;
    }

}