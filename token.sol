pragma solidity >=0.4.22 <0.6.0;

import "./kyc.sol";
import "./sto.sol";

contract Token {
    
    event LogCreateSTO(address sender, address sto, string symbol, string name, string nation, string tax, string web);
    event LogApproveSTO(address sender, string symbol);    

    kyc KYC;
    
    address public owner;
    address public custodian;
    
    mapping(string => STO) mapSTO;
    
    uint256 public PRICE = 0;
    
    modifier onlyKYC(address addr)
    {
        require(KYC.get(addr) >= 0);
        _;
    }
    
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyValue(uint256 value)
    {
        require(msg.value >= value);
        _;
    }

    modifier onlyCreate(string symbol)
    {
        require(msg.sender != owner);
        require(msg.sender != custodian);
        require(address(mapSTO[symbol]) == address(0x0));
        _;
    }
    
    modifier onlyApprove(string symbol)
    {
        require(msg.sender == custodian);
        require(address(mapSTO[symbol]) != address(0x0));
        _;
    }

    constructor(address _kyc, address _custodian) 
    {
        require(msg.sender != _custodian);
        
        owner = msg.sender;
        custodian = _custodian;
        
        KYC = kyc(_kyc);
    }
    
    function createSTO(string symbol, string name, string nation, string tax, string web)
        public
        payable
        onlyKYC(msg.sender)
        onlyValue(PRICE)
        onlyCreate(symbol)
    {
        address addr = new STO(msg.sender, symbol, name, nation, tax, web);
        mapSTO[symbol] = STO(addr);
        
        if(addr != 0x0)
        {
            emit LogCreateSTO(msg.sender, addr, symbol, name, nation, tax, web);   
        }
          
    }
    
    function approveSTO(string symbol)
        public
        onlyKYC(msg.sender)
        onlyApprove(symbol)
    {
        mapSTO[symbol].unlock();
        
        emit LogApproveSTO(msg.sender, symbol);
    }

}

















