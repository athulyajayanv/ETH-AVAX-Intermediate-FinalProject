// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract DegenGamingToken is ERC20, Ownable, ERC20Burnable {
    // Enum representing different game actions
    enum Action { PLAY, WIN, LOSE, PURCHASE, REDEEM, TRANSFER, BURN, RECEIVE }

    // Struct to store details of a game action
    struct GameAction {
        Action action;    
        uint256 amount;     
        string itemName;    
    }

    // Struct to store details of items available in the shop
    struct Item {
        string name;       
        uint256 price;      
    }

    // Array to store all items in the shop
    Item[] public shop;

    // Mapping to store the price of each item by its name
    mapping(string => uint256) public itemPrices;

    // Mapping to store actions performed by each player
    mapping(address => GameAction[]) public playerActions;

    // Events to log various actions
    event TokensEarned(address indexed recipient, uint256 amount, string action);
    event TokensTransferred(address indexed sender, address indexed recipient, uint256 amount);
    event TokensBurned(address indexed burner, uint256 amount);
    event TokensRedeemed(address indexed redeemer, uint256 amount, string itemName);
    event ItemAdded(string itemName, uint256 price);

    // Constructor to initialize the contract 
    constructor(address initialOwner) ERC20("Degen", "DGN") Ownable(initialOwner) {
        fillShop();
    }

    // Function to mint new tokens to a specified recipient
    function mintTokens(address recipient, uint256 amount) external onlyOwner {
        _mint(recipient, amount); 
        _recordAction(recipient, Action.PLAY, amount, "");  
        emit TokensEarned(recipient, amount, "Tokens earned from gameplay");  
    }

    // Function to transfer tokens from the caller to another address
    function transferTokens(address to, uint256 amount) external {
        require(to != address(0), "Invalid recipient"); 
        require(amount > 0 && amount <= balanceOf(msg.sender), "Invalid amount"); 

        _transfer(msg.sender, to, amount);  
        _recordAction(msg.sender, Action.TRANSFER, amount, ""); 
        _recordAction(to, Action.RECEIVE, amount, "");  
        emit TokensTransferred(msg.sender, to, amount);  
    }

    // Function to burn a specified amount of tokens from the caller's balance
    function burnTokens(uint256 amount) external {
        require(amount > 0 && amount <= balanceOf(msg.sender), "Invalid amount");  

        _burn(msg.sender, amount);  
        _recordAction(msg.sender, Action.BURN, amount, "");  
        emit TokensBurned(msg.sender, amount);  
    }

    // Function to redeem tokens for an item from the shop
    function redeemTokens(string memory itemName) external {
        uint256 itemPrice = itemPrices[itemName]; 
        require(itemPrice > 0, "Item does not exist");  
        
        uint256 currentTokens = balanceOf(msg.sender);  
        require(currentTokens >= itemPrice, "Insufficient token amount to redeem item");  

        _burn(msg.sender, itemPrice);  
        _recordAction(msg.sender, Action.REDEEM, itemPrice, itemName);  
        emit TokensRedeemed(msg.sender, itemPrice, itemName);  
    }

    // Internal function to populate the shop with predefined items
    function fillShop() internal onlyOwner {
        _addItem("Armor", 100);
        _addItem("Sword", 150);
        _addItem("Potion", 200);
        _addItem("Shield", 250);
    }

    // Function to add a new item to the shop
    function addItem(string memory name, uint256 price) public onlyOwner {
        _addItem(name, price);
    }

    // Internal function to add an item to the shop and emit an event
    function _addItem(string memory name, uint256 price) internal {
        itemPrices[name] = price; 
        shop.push(Item(name, price));  
        emit ItemAdded(name, price);  
    }

    // Function to retrieve the list of items available in the shop
    function getShopItems() external view returns (Item[] memory) {
        return shop;
    }

    // Function to get a player's action history
    function getPlayerActions(address player) external view returns (GameAction[] memory) {
        return playerActions[player];
    }

    // Internal function to record a player's game action
    function _recordAction(address player, Action action, uint256 amount, string memory itemName) internal {
        playerActions[player].push(GameAction({
            action: action,
            amount: amount,
            itemName: itemName
        })); 
    }
}
