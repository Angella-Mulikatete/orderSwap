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
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        uint256 deadline;
        bool isFilled;
    }
    uint256 public orderCount;

    constructor() Ownable(msg.sender){}

    mapping(address => uint256[]) public orderIds;//list of order IDs for each token for order tracking.
    mapping (address => mapping(address => uint256)) balances; // store balance of the token for @ depositor [tokenAddres][]
    mapping(address =>mapping(uint256 => order)) orders; //track oredrs for @ token by address and orderId, [user][tokenAddress]

    event OrderCreated(uint256 orderId, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut, uint256 deadline);
    event OrderFilled(uint256 orderId, address indexed buyer, address indexed seller, uint256 amount);
    event OrderCancelled(uint256 orderId);


//deposit token to the contract
    function depositTokens(address _tokenAddress, uint256 _amount) external {
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender][_tokenAddress] += _amount;
    } 

    function createOrder(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOut,
        uint256 _deadline
        ) external returns(uint256){
            // uint256 orderId = orderIds[_tokenIn].length ++;
                 require(balances[msg.sender][_tokenIn] >= _amountIn, "Insufficient token balance");
                 require(_deadline > block.timestamp, "Invalid expiration time");
                 require(_amountIn > 0 && _amountOut > 0, "Invalid amounts");
            orderCount++;
            uint256 orderId = orderCount;
            orders[_tokenIn][orderId] = order({
                depositor: msg.sender,
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                amountIn: _amountIn,
                amountOut: _amountOut,
                deadline: _deadline,
                isFilled: false
            });

            emit OrderCreated(orderId, _tokenIn, _tokenOut, _amountIn, _amountOut, _deadline);
            return orderId;
        }
}