pragma solidity ^0.4.25;

contract LAGCredit {
    
    string name = "LAGCredit";
    string symbol = "LAGC";
    uint256 totalCredit;
    mapping(address => uint256) private credits;
    
    constructor(string iniName, string iniSymbol, uint256 iniCredit) public {
        name = iniName;
        symbol = iniSymbol;
        totalCredit = iniCredit;
        credits[msg.sender] = totalCredit;
    }
    
    event transferEvent(address from, address to, uint256 value);
    
    function transfer(address toAddr, uint256 value) public {
        _transfer(msg.sender, toAddr, value);
    }
    
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != 0x0);
        require(credits[_from] >= _value);
        require(credits[_to] + _value > credits[_to]);
        
        uint256 preCredit = credits[_from] + credits[_to];
        
        credits[_from] -= _value;
        credits[_to] += _value;
        
        transferEvent(_from, _to, _value);
        assert(credits[_from] + credits[_to] == preCredit);
    }
    
    function getName() constant returns (string) {
        return name;
    }
    
    function getSymbol() constant returns (string) {
        return symbol;
    }
    
    function getTotalCredit() constant returns (uint256) {
        return totalCredit;
    }
    
    function getCredit(address addr) constant returns (uint256) {
        return credits[addr];
    }
    
    function getAddr() constant returns (address) {
        return msg.sender;
    }
}
