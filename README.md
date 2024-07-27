# METACRAFTERS ETH-AVAX INTERMEDIATE PROJECT 4

This Solidity program defines a custom ERC20 token contract for Degen Gaming that allows minting, burning, transferring, and tracking player actions, with an integrated shop where players can redeem tokens for items.

## Description

This Solidity contract extends the ERC20 standard to create a custom token named 'Degen' with symbol 'DGN' with additional features like minting, burning, transferring, and owner-only functions. It tracks various game-related actions taken by players using the token and includes a shop system for purchasing items. The contract demonstrates the use of OpenZeppelin's ERC20 implementation along with ownership and burning extensions.

1. Constructor: 
The constructor initializes the contract with the name "Degen" and symbol "DGN". It sets the initial owner of the contract to the address provided as the initialOwner and populates the shop with predefined items.

2. mintTokens: 
The mintTokens function allows the contract owner to mint new tokens to a specified recipient. It records the action as a PLAY and emits the TokensEarned event.

3. transferTokens: 
The transferTokens function allows players to transfer tokens to another address. It ensures that the recipient's address is valid and that the sender has sufficient tokens. It records the transfer action for both the sender and recipient, and emits the TokensTransferred event.

4. burnTokens: 
The burnTokens function allows players to burn their own tokens. It checks that the amount to be burned is valid and within the balance of the sender. It records the burn action and emits the TokensBurned event.

5. redeemTokens: 
The redeemTokens function allows players to redeem their tokens for items from the shop. It ensures that the item exists and that the sender has sufficient tokens. It records the redeem action and emits the TokensRedeemed event.

6. checkBalance: 
The checkBalance function returns the token balance of a specified account.

7. getPlayerActions: 
The getPlayerActions function returns the action history of a specified player.

8. _recordAction: 
The _recordAction function is an internal function that records a specified action and amount for a given player. It adds the action to the playerActions mapping.

9. enum Action: 
The Action enum defines various actions that can be performed in the game, such as PLAY, WIN, LOSE, PURCHASE, REDEEM, TRANSFER, BURN, and RECEIVE.

10. struct GameAction: 
The GameAction struct stores the details of a game action, including the type of action, the amount involved, and the item name (if applicable).

11. fillShop: The fillShop function populates the shop with predefined items when the contract is deployed.

12. struct Item: The Item struct stores the details of items available in the shop, including the name and price.

## Getting Started

### Executing program

1. To run this program, you can use Remix at https://remix.ethereum.org/.
2. Create a new file by clicking on the "+" icon in the left-hand sidebar.
3. Save the file with a .sol extension.

```javascript
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
```
## Connecting MetaMask with Avalanche Fuji Network 

1. Open MetaMask and click on the network dropdown at the top.
2. Select "Add Network" and fill in the following details:
Network Name: Avalanche Fuji C-Chain
New RPC URL: [https://api.avax-test.network/ext/bc/C/rpc]

ChainID: 43113

Symbol: AVAX

4. Save and switch to the new network.
   
## To compile the code,

1. Go to the 'Solidity Compiler' tab on the left.
2. Set the Compiler to 0.8.26 or a compatible version, and click Compile.
   
## Once compiled,

1. Go to the 'Deploy & Run Transactions' tab on the left.
2. Ensure the Environment is set to "Injected Web3" to connect with metamask wallet, for a local test environment.
3. Enter the initial owner's address in the "initialOwner" field.
4. Click deploy.

After deploying, you can interact with the contract.

## Verifying Contract on Snowtrace

1. Go to https://testnet.snowtrace.io/.
2. Search for your contract address.
3. Complete the verification.

## Authors

Athulya Jayan V

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
