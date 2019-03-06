pragma solidity >=0.4.22 <0.6.0;

import "./kyc.sol";


contract MultiSig {
    
    event LogAddOwner(address sender, address addr);
    event LogRemoveOwner(address sender, address addr);
    event LogChangeRequire(address sender, uint256 n);
    event LogNewTx(address sender, address destination, uint256 value, bytes data);
    event LogSignTx(address sender, uint256 id);
    event LogSendTx(address sender, uint256 id, bool ok);
    
    kyc KYC;
    
    address public master;
    
    uint256 constant public M = 50;
    uint256 public N;
    uint256 public count;
    uint256 public nRequire;
 
    
    mapping(address => bool) public mapOwners;
    mapping(uint256 => Tx) public mapTxs;
    mapping (uint256 => mapping (address => bool)) public mapConfirms;

    struct Tx {
        bool Executed;
        address Destination;
        uint256 Value;
        uint256 NumSign;
        bytes Data;
    }
    
    modifier onlyKYC(address addr)
    {
        require(KYC.get(addr) >= 0);
        _;
    }    

    modifier onlyWallet() {
        require (msg.sender == address(this));
        _;
    }
    
    modifier onlyOwners(address addr)
    {
        require(mapOwners[addr]);
        _;
    }

    modifier onlyNotOwners(address addr)
    {
        require(!mapOwners[addr]);
        _;
    }

    modifier onlyMaster(address addr)
    {
        require(addr == master);
        _;
    }
    
    modifier onlyAddOwner()
    {
        require(nRequire + 1 <= N);
        _;
    }
    
    modifier onlyRemoveOwner()
    {
        require(nRequire - 1 > 0);
        _;
    }
    
    modifier onlyChangeRequire(uint256 n)
    {  
        require(n > nRequire && n <= M);
        _;
    }
    
    modifier onlySignTx(uint256 id)
    {
        require(!mapTxs[id].Executed);
        require(!mapConfirms[id][msg.sender]);
        _;
    }
    
    modifier onlySendTx(uint256 id)
    {
        require(mapTxs[id].NumSign >= nRequire);
        _;
    }

    
    constructor(uint256 n)
    {
        master = msg.sender;
        
        if(n > M)
        {
            n = M;
        }
        
        if(n < 1)
        {
            n = 1;
        }
        N = n;
        
        addOwner(msg.sender);
    }
    
    function addOwner(address addr)
        public
        onlyMaster(msg.sender)
        onlyNotOwners(addr)
    {
        nRequire ++;
        mapOwners[addr] = true;
        
        emit LogAddOwner(msg.sender, addr);
    }
    
    function removeOwner(address addr)
        public
        onlyMaster(msg.sender)
        onlyOwners(addr)
    {
        nRequire --;
        mapOwners[addr] = false;
        
        emit LogRemoveOwner(msg.sender, addr);
    }
    
    function changeRequire(uint256 n)
        public
        onlyMaster(msg.sender)
        onlyChangeRequire(n)
    {
        N = n;
        
        emit LogChangeRequire(msg.sender, n);
    }
    
    function newTx(address destination, uint256 value, bytes data)
        public
        onlyOwners(msg.sender)    
    {
        Tx memory tx = Tx(false, destination, value, 0, data);

        count ++;
        mapTxs[count] = tx;
        
        emit LogNewTx(msg.sender, destination, value, data);
        
        signTx(count);
    }
    
    function signTx(uint256 id)
        public
        onlyOwners(msg.sender)
        onlySignTx(id)
    {
        mapTxs[id].NumSign ++;
        mapConfirms[id][msg.sender] = true;
        
        emit LogSignTx(msg.sender, id);
        
        sendTx(id);
    }
    
    function sendTx(uint256 id)
        public
        onlyOwners(msg.sender)
        onlySendTx(id)
    {
        bool ok = mapTxs[id].Destination.call.value(mapTxs[id].Value)(mapTxs[id].Data);
        mapTxs[id].Executed = ok;
        
        emit LogSendTx(msg.sender, id, ok);
    }
    
}