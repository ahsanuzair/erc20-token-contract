// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ERC20Token{
    string public tokenName; 
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address immutable i_owner;
    uint256 immutable public MAX_SUPPLY;

    event Transfer (address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Mint(address indexed _to, uint256 _tokensToMint);

    modifier onlyOwner(){
        require(msg.sender == i_owner, "You're not the owner");
        _;
    }

    constructor (uint256 _initialSupply, uint256 _maxSupply, string memory _tokenName, string memory _symbol, uint8 _decimals){
        tokenName = _tokenName;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * (10 ** (decimals));
        MAX_SUPPLY = _maxSupply * (10 ** (decimals));

        i_owner =  msg.sender;

        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }

    function getTotalSupply() public view returns (uint256){
        return totalSupply;
    }

    function allowance (address _owner, address _spender) public view returns (uint256){
        return _allowances[_owner][_spender];
    }

    function transfer (address to, uint256 amount) public returns (bool success) {
        require(balances[msg.sender] >= amount, "Insufficient balance for transfer");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        require(_spender != address(0), "Spender address cannot be zero");

        _allowances[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool success) {
        require(from != address(0), "Sender addresses must be valid");
        require(to != address(0), "Recipient addresses must be valid");
        require(balances[from] >= amount, "Don't have enough balance");
        require(_allowances[from][msg.sender] >= amount, "Transfer amount exceeds allowance");

        _allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool){
        require(_spender != address(0), "Spender address cannot be zero");
        require(balances[msg.sender] >= _addedValue, "Allowance increase exceeds owner balance");

        _allowances[msg.sender][_spender] += _addedValue;

        emit Approval(msg.sender, _spender, _addedValue);
        return true;
    }

    function decreaseAllowance (address _spender, uint256 _subtractedValue) public returns (bool) {
        require(_allowances[msg.sender][_spender] >= _subtractedValue, "Decreased amount exceeds current allowance");
        _allowances[msg.sender][_spender] -= _subtractedValue;

        emit Approval(msg.sender, _spender,  _allowances[msg.sender][_spender]);
        return true;
    }

    function burn(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Burn amount exceeds balance");
        balances[msg.sender] -= _amount;
        totalSupply -= _amount;

        emit Burn(msg.sender, _amount);
    }

    function mint(address _to, uint256 _tokensToMint) public onlyOwner{
        require(totalSupply + _tokensToMint <= MAX_SUPPLY, "Minting exceeds maximum token supply");
        totalSupply += _tokensToMint;
        balances[_to] += _tokensToMint;

        emit Mint(_to, _tokensToMint);
    }


}