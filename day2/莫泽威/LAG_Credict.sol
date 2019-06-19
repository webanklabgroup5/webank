pragma solidity ^0.4.19;  //maybe the version of it can be wrong

contract LAG_Credict
{
    /*
    Functions need to be done:
    1. Init the total credict 
    2. Search the credict for a user 
    3. Transfer credict to another user 
    4. Search total credict
    5. Record the detail of every transaction of transferring credict 
    */
    
    mapping(address => uint256) User_Credict;
    
    //Record of transaction need to be stored by event (later to do)
    event transferEvent(address _from,address _to, uint256 num);
    uint256  Total_Credict;
    string  Name;
    string  Symbol;
    //constructor needs to decide the name and initial_num of credict 
    //and also the symbol of it.
    constructor(uint256 initial_num, string credict_name, string symbol) public 
    //if we use high version more than 0.5  we need to add memory after string like "string memory stmbol"
    {
        Total_Credict = initial_num;
        Name = credict_name;
        Symbol = symbol;
        User_Credict[msg.sender] = initial_num;
    }
    
    function Search_Credict_ForUser(address _owner) public returns(uint256)
    {
        return User_Credict[_owner];
    }
    
    function Get_TotalCredict() public returns(uint256)
    {
        return Total_Credict;
    }
    
    function Transfer(address _from, address _to, uint256 num) private
    {
        require(Total_Credict[_from] >= num);
        require(num >= 0);
        Total_Credict[_from] -= num;
        Total_Credict[_to] += num;
        
        //Attention
        emit transferEvent(_from,_to,num);
        require(Total_Credict[_from] + Total_Credict[_to] == Total_Credict);
    }

    function transfer(address _to, uint256 num) public
    {
        Transfer(msg.sender,_to,num);
    }
    
}
