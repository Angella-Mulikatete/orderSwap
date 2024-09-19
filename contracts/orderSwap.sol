// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "./interfaces/IERC20.sol";

contract OrderSwap is Ownable{

    struct order{
        address depositor;
        address tokenIn;
        address expectedToken;
        uint256 amountIn;
        uint256 expectedAmount;
        uint256 deadline;
        bool isFilled;
    }
    uint256 public orderCount;

    constructor() Ownable(msg.sender){}

    mapping(address => uint256[]) public orderIds;//list of order IDs for each token(address) for order tracking. token => id
    mapping (address => mapping(address => uint256)) balances; // store balance of the token for @ depositor [tokenAddres][]
   // mapping(address =>mapping(uint256 => order)) orders; //track oredrs for @ token by address and orderId, [user][tokenAddress]
     mapping(uint256 => order) public orders;

    event OrderCreated(uint256 orderId, address indexed tokenIn, address indexed expectedToken, uint256 amountIn, uint256 expectedAmount, uint256 deadline);
    event OrderFilled(uint256 orderId, address indexed buyer, address indexed seller, uint256 amount);
    event OrderCancelled(uint256 orderId);


//deposit token to the contract
    function depositTokens(address _tokenAddress, uint256 _amount) external {
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender][_tokenAddress] += _amount;
    } 
//uint256 orderId = orderIds[_tokenIn].length;
//orderIds[_tokenIn].push(orderId);
    function createOrder(address _tokenIn,address _expectedToken,uint256 _amountIn, uint256 _expectedAmount,uint256 _deadline) external returns(uint256){
        //  order count for new order ID
        orderCount++;
        uint256 orderId = orderCount;
        orderIds[_tokenIn].push(orderId);
        orderIds[_expectedToken].push(orderId);

        require(balances[msg.sender][_tokenIn] >= _amountIn, "Insufficient token balance");
        require(_deadline > block.timestamp, "Invalid expiration time");
        require(_amountIn > 0 && _expectedAmount > 0, "Invalid amounts");
        orderCount++;
        // uint256 orderId = orderCount;
        orders[orderId] = order({
            depositor: msg.sender,
            tokenIn: _tokenIn,
            expectedToken: _expectedToken,
            amountIn: _amountIn,
            expectedAmount: _expectedAmount,
            deadline: _deadline,
            isFilled: false
        });

        emit OrderCreated(orderId, _tokenIn, _expectedToken, _amountIn, _expectedAmount, _deadline);
        return orderId;
    }

    function fillOrder(uint256 orderId) external {
        order storage _orders = orders[orderId];

        require(!_orders.isFilled, "Order already filled");
        require(block.timestamp <= _orders.deadline, "Order expired");
        require(balances[_orders.depositor][_orders.tokenIn] >= _orders.amountIn, "depositor has insufficient tokens");

         // Transfer tokenOut from buyer to depositor
        IERC20(_orders.expectedToken).transferFrom(msg.sender, _orders.depositor, _orders.expectedAmount);

        // Transfer tokenIn from contract to buyer
        balances[_orders.depositor][_orders.tokenIn] -= _orders.amountIn;
        IERC20(_orders.tokenIn).transfer(msg.sender, _orders.amountIn);

        _orders.isFilled = true;
        emit OrderFilled(orderId, msg.sender, _orders.expectedToken, _orders.amountIn);
    }
    
}


         // //check for any match
        // bool foundMatch = false;

        // for(uint256 i = 0; i < orderIds[_orders.expectedToken].length; i ++){
        //     order storage matchOrder = orders[i];
        //     if(matchOrder.expectedToken == _orders.tokenIn && matchOrder.expectedAmount >= _orders.amountIn && matchOrder.amountIn >= _orders.expectedAmount && matchOrder.deadline >= block.timestamp){
        //         foundMatch = true;
        //         executeSwap(_orders, matchOrder);
        //         break;
        //     }
        // }
        // require(foundMatch, "No matching order found");
        
    // function executeSwap(order storage order, order storage matchOrder )internal {
    //     IERC20(order.tokenIn).transfer(matchOrder.expectedToken, order.amountIn);
    //     IERC20(matchOrder.tokenIn).transfer(order.expectedToken, matchOrder.expectedAmount);

    //     balances[order.depositor][order.tokenIn]-= order.amountIn;
    //     balances[]

    // }