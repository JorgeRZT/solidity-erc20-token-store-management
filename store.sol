// SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Store {

    // ----------------------------------------- INITIAL CONTRACT STRUCTURE

    // Contract instance
    ERC20Basic private token;

    // Store contract owner address
    address payable public owner;

    // Constructor
    constructor() public {
        token = new ERC20Basic(21000);
        owner = msg.sender;
    }

    // Estructura cliente
    struct cliente {
        uint _tokens;
        string [] atracciones_disfrutadas;
    }

    // Mapping registro clientes
    mapping (address => cliente) public Clientes; 

    // ----------------------------------------- TOKEN MANAGEMENT

    // Price stablishment
    function TokenPrice(uint _amount) internal pure returns (uint) {
        return _amount*(1 ether);
    }

    function GetTokens(uint _amount) public payable {
        uint coste = TokenPrice(_amount);
        require (msg.value >= coste, "Compra menos Tokens o paga con mas ethers.");
        uint returnValue = msg.value - coste;
        msg.sender.transfer(returnValue);
        uint Balance = BalanceOf();
        require(_amount <= Balance, "Compra un numero menor de Tokens");
        token.transfer(msg.sender, _amount);
        Clientes[msg.sender]._tokens += _amount;
    }

    function BalanceOf() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function MyBalance() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    function CreateTokens(uint _amount) public OnlyOwner(msg.sender) {
        token.increaseTotalSuply(_amount);
    }

    modifier OnlyOwner(address _address) {
        require(_address == owner, "You are not the owner");
        _;
    }

    // ----------------------------------------- STORE MANAGEMENT

    // Events
    event get_product(string);
    event new_product(string, uint);
    event delete_product(string);

    // Struct
    struct product {
        string name;
        uint price;
        bool active;
    }

    // Mappings
    mapping (string => product) public Products;
    string[] productArray;
    mapping (address => string[]) productHistory;

    function NewProduct(string memory _name, uint _price) public OnlyOwner(msg.sender) {
        Products[_name] = product(_name, _price, true);
        productArray.push(_name);
        emit new_product(_name, _price);
    }

    function DeleteProduct(string memory _name) public OnlyOwner(msg.sender){
        Products[_name].active = false;
        emit delete_product(_name);
    }

    function GetProducts() public view returns(string [] memory) {
        return productArray;
    }

    function PayForProduct(string memory _name) public {
        uint _price = Products[_name].price;
        require(Products[_name].active, "Product not available");
        require(_price <= MyBalance(), "You need more tokens");
        token.transfer_store(msg.sender, address(this), _price);
        productHistory[msg.sender].push(_name);
        emit get_product(_name);
    }

    function History() public view returns(string [] memory) {
        return productHistory[msg.sender];
    }

    function GiveTokensBack(uint _amount) public payable {
        require (_amount > 0, "Not valid amount");
        require (_amount <= MyBalance(), "You dont have so many tokens");
        token.transfer_store(msg.sender, address(this), _amount);
        msg.sender.transfer(TokenPrice(_amount));
    }
}
