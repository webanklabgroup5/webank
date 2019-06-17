pragma solidity ^0.4.25;

contract LAGCredit {
    
    string name = "LAGC";
    string symbol = "LAG";
    uint256 totalSupply;
    
    // address -> balances
    mapping(address => uint256) private balances;
    
    // tell client the transaction happened.
    event transferEvent(address from, address to, uint256 value);
    
    constructor(uint256 iniSupply, string iniName, string iniSymbol) public {
        totalSupply = iniSupply;
        balances[msg.sender] = totalSupply;
        name = iniName;
        symbol = iniSymbol;
    }
    
    function getTotalSupply() constant returns (uint256) {
        return totalSupply;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balances[_from] >= _value);
        require(balances[_to] + _value > balances[_to]);
        
        uint preBalances = balances[_from] + balances[_to];
        
        balances[_from] -= _value;
        balances[_to] += _value;
        
        transferEvent(_from, _to, _value);
        assert(balances[_from] + balances[_to] == preBalances);
    }
    
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
    function balanceOf(address _owner) constant returns (uint256) {
        return balances[_owner];
    }
    
    function getName() constant returns (string) {
        return name;
    }
    
    function getSymbol() constant returns (string) {
        return symbol;
    }
}