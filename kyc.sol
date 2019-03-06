pragma solidity >=0.4.22 <0.6.0;

contract kyc {
    
    uint LEVEL_1 = 1;
    uint LEVEL_2 = 2;
    uint LEVEL_3 = 3;
    
    address owner;
    mapping(address => uint) mapLevel;
    mapping(address => uint) mapRequest;
    
    event LogRegister(address addr);
    event LogRequest(address,uint);
    event LogRemove(address addr);
    event LogUpdate(address addr, uint level);
    event LogUpdown(address addr, uint level);
    
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;    
    }
    
    modifier onlyRegister(address addr)
    {
        require(mapLevel[addr] <= LEVEL_1);
        _;
    }
    
    modifier onlyRequest(address addr)
    {
        require(mapLevel[addr] >= LEVEL_1);
        require(mapRequest[addr] < LEVEL_3);
       _;
    }    
    
    modifier onlyUpdate(address addr)
    {
        require(mapRequest[addr] != 0);
        require(mapLevel[addr] < LEVEL_3);
       _;
    }
    
    modifier onlyUpdown(address addr)
    {
        require(mapLevel[addr] > LEVEL_1);
       _;
    }
    
    
    constructor() 
    {
        owner = msg.sender;
    }
    
    function register(address addr) 
        public
        onlyRegister(addr)
    {
        mapLevel[addr] = 1;
        
        emit LogRegister(addr);
    }
    
    function request(address addr)
        public
        onlyRequest(addr)
    {
        uint level = get(addr) + 1;
        mapRequest[addr] = level;
        
        emit LogRequest(addr, level);
    }
    
    function remove(address addr)
        public
        onlyOwner
    {
        mapLevel[addr] = 0;
        mapRequest[addr] = 0;
        
        emit LogRemove(addr);
    }
    
    function update(address addr) 
        public
        onlyOwner
        onlyUpdate(addr)
    {
        mapLevel[addr] += 1;
        mapRequest[addr] = 0;
        
        emit LogUpdate(addr, mapLevel[addr]);
    }
    
    function updown(address addr) 
        public
        onlyOwner
        onlyUpdown(addr)
    {
        mapLevel[addr] -= 1;
        emit LogUpdown(addr, mapLevel[addr]);
    }    
    
    function get(address addr)
        public
        returns(uint)
    {
        return mapLevel[addr];
    }
    
}