// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pausable.sol";
import "./EIP712.sol";

contract ERC20 is Pausable, EIP712 {

    // ERC20 State Variables
    bytes32 private immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    uint8 private _decimals;
    address private _owner;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    mapping(address => uint256) private _nonces;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(
        string memory name_,
        string memory symbol_
    ) EIP712(name_, "1") {
        _owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _totalSupply = 100 * 10E18;
        _mint(msg.sender, _totalSupply);
    }
    // permit functions
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(owner != address(0), "ERC20: Invalid owner address");
        require(block.timestamp <= deadline, "ERC20: Expired permit");

        bytes32 digest = _toTypedDataHash(
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    owner,
                    spender,
                    value,
                    _nonceHandle(owner),
                    deadline
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");
        _approve(owner, spender, value);
    }

    // nonces
    function nonces(address owner) public view returns (uint256) {
        return _nonces[owner];
    }
    // nonces increment
    function _nonceHandle(address _addr) internal returns(uint256 curNonce){
        curNonce = _nonces[_addr];
        _nonces[_addr]++;

    }
    
    // pause interface => owner check🌈
    function pause() public virtual whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() public virtual whenPaused onlyOwner {
        _unpaused();
    }


    // owner check
    modifier onlyOwner() {
        _checkOwner(msg.sender);
        _;
    }
    function _checkOwner(address _addr) internal view {
        require(_owner == _addr, "Ownable: caller is not the owner");
    }


    // ERC20 View area
    function name() public view returns(string memory){
        return _name;
    }
    function symbol() public view returns(string memory){
        return _symbol;
    }
    function decimals() public view returns(uint8){
        return _decimals;
    }
    function totalSupply() public view returns(uint256){
        return _totalSupply;
    }
    function balanceOf(address _addr) public view returns(uint256){
        return _balances[_addr];
    }

    function allowance(address _addr, address _spender) public view returns (uint256) {
        return _allowances[_addr][_spender];
    }


    function transfer(address to, uint256 value) whenNotPaused external returns (bool succes) {
        address owner = msg.sender;
        _transfer(owner, to, value);

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) whenNotPaused external returns (bool succes) {
        require(spender != address(0), "Invalid address");  // zer0 address check
        address _addr = msg.sender;

        _approve(_addr, spender, value);
        emit Approval(_addr, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) whenNotPaused external returns (bool succes) {
        require(from != address(0), "Invalid address");  // zer0 address check
        require(to != address(0), "Invalid address");  // zer0 address check
        require(_balances[from] >= value, "Insufficient balance");    // balance check

        uint256 currentAllowance = _allowances[from][msg.sender]; 

        if (currentAllowance != ~uint256(0)) {
            require(currentAllowance >= value, "Insufficient allowance");    // allowance check
            unchecked {
                _allowances[from][msg.sender] -= value;
            }

        }
        _transfer(from, to, value);
        emit Transfer(from, to, value);
        return true;

    }

    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Invalid address");  // zer0 address check
        require(to != address(0), "Invalid address");  // zer0 address check

        uint256 fromBalance = _balances[from];
        require(fromBalance >= value, "Insufficient balance");    // balance check
        unchecked {
            _balances[from] = fromBalance - value;
            _balances[to] += value;
        }
        emit Transfer(from, to, value);
    }

    function _mint(address _to, uint256 _value) internal {
        require(_to != address(0), "[+] Invalid address");  // zer0 address check
        require(_totalSupply + _value >= _totalSupply, "[+] Mint Overflow Check");    // overflow check

        unchecked {
            _balances[_to] += _value;
            _totalSupply += _value;
        }

        emit Transfer(address(0), _to, _value);
    }

    function _burn (address _from, uint256 _value) internal {
        require(_from != address(0), "Invalid address");  // zer0 address check
        require(_balances[_from] >= _value, "Insufficient balance");    // balance check
        

        unchecked {
            _balances[_from] -= _value;
            _totalSupply -= _value;
        }
        emit Transfer(_from, address(0), _value);
    }

    function _approve(
        address _addr,
        address _spender,
        uint256 _value
    ) internal {
        require(_addr != address(0), "Invalid address");  // zer0 address check
        require(_spender != address(0), "Invalid address");  // zer0 address check
        
        _allowances[_addr][_spender] = _value;
        emit Approval(_addr, _spender, _value);
    }
}
