/**
 *Submitted for verification at BscScan.com on 2021-07-02
*/

/*

Contract by DeFiSCI and Team - built on others previous work w/ a splash of DevTeamSix magic...

*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract KingBabyDoge is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    address payable public marketingAddress = payable(0x930b4125e09533f358701E95161363bd84ED2377); // Marketing Address
    address payable public charityAddress = payable(0x0123093f4c8aAAA758277734b1EfCA51d811f07F); // Charity Address
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 private _totalBurn;

    string private _name = "KingBabyDoge";
    string private _symbol = "KBD";
    uint8 private _decimals = 9;

    struct AddressFee {
        bool enable;
        uint256 _liquidityFee;
        uint256 _burnFee; 
        uint256 _charityFee;    
        uint256 _marketingFee;
        uint256 _buyLiquidityFee;
        uint256 _buyMarketingFee;
        uint256 _sellLiquidityFee;
        uint256 _sellMarketingFee;
    }

    struct SellHistories {
        uint256 time;
        uint256 bnbAmount;
    }

    
    uint256 public _liquidityFee = 10;
    uint256 public _burnFee = 4;
    uint256 public _charityFee = 1;
    uint256 public _marketingFee = 3;
    uint256 private _previousLiquidityFee = _liquidityFee;
    
    uint256 public _buyLiquidityFee = 11;
    uint256 public _buyBurnFee = 4;
    uint256 public _buyMarketingFee = 3;
    
    uint256 public _sellLiquidityFee = 10;
    uint256 public _sellBurnFee = 3;
    uint256 public _sellMarketingFee = 2;

    uint256 public _startTimeForSwap;
    uint256 public _intervalMinutesForSwap = 1 * 1 minutes;

    uint256 public _buyBackRangeRate = 80;

    // Fee per address
    mapping (address => AddressFee) public _addressFees;

    uint256 public marketingDivisor = 3;
    uint256 public charityDivisor = 1;
    
    uint256 public _maxTxAmount = 3000000 * 10**6 * 10**9;
    uint256 private minimumTokensBeforeSwap = 200000 * 10**6 * 10**9; 
    uint256 public buyBackSellLimit = 1 * 10**14;

    // LookBack into historical sale data
    SellHistories[] public _sellHistories;
    bool public _isAutoBuyBack = true;
    uint256 public _buyBackDivisor = 10;
    uint256 public _buyBackTimeInterval = 5 minutes;
    uint256 public _buyBackMaxTimeForHistories = 24 * 60 minutes;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public buyBackEnabled = true;

    bool public _isEnabledBuyBackAndBurn = true;
    
    event RewardLiquidityProviders(uint256 tokenAmount);
    event BuyBackEnabledUpdated(bool enabled);
    event AutoBuyBackEnabledUpdated(bool enabled);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _balances[_msgSender()] = _tTotal;	
        // Pancake Router Testnet v1
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        
        // uniswap Router Testnet v2 - Not existing I guess
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _startTimeForSwap = block.timestamp;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }
    
    function buyBackSellLimitAmount() public view returns (uint256) {
        return buyBackSellLimit;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner() && to != owner()) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;    

        if (to == uniswapV2Pair && balanceOf(uniswapV2Pair) > 0) {
            SellHistories memory sellHistory;
            sellHistory.time = block.timestamp;
            sellHistory.bnbAmount = _getSellBnBAmount(amount);

            _sellHistories.push(sellHistory);
        }    

        // Sell tokens for ETH
        if (!inSwapAndLiquify && swapAndLiquifyEnabled && balanceOf(uniswapV2Pair) > 0) {
            if (to == uniswapV2Pair) {
                if (overMinimumTokenBalance && _startTimeForSwap + _intervalMinutesForSwap <= block.timestamp) {
                    _startTimeForSwap = block.timestamp;
                    contractTokenBalance = minimumTokensBeforeSwap;
                    swapTokens(contractTokenBalance);    
                }  

                if (buyBackEnabled) {

                    uint256 balance = address(this).balance;
                
                    uint256 _bBSLimitMax = buyBackSellLimit;

                    if (_isAutoBuyBack) {

                        uint256 sumBnbAmount = 0;
                        uint256 startTime = block.timestamp - _buyBackTimeInterval;
                        uint256 cnt = 0;

                        for (uint i = 0; i < _sellHistories.length; i ++) {
                            
                            if (_sellHistories[i].time >= startTime) {
                                sumBnbAmount = sumBnbAmount.add(_sellHistories[i].bnbAmount);
                                cnt = cnt + 1;
                            }
                        }

                        if (cnt > 0 && _buyBackDivisor > 0) {
                            _bBSLimitMax = sumBnbAmount.div(cnt).div(_buyBackDivisor);
                        }

                        _removeOldSellHistories();
                    }

                    uint256 _bBSLimitMin = _bBSLimitMax.mul(_buyBackRangeRate).div(100);

                    uint256 _bBSLimit = _bBSLimitMin + uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % (_bBSLimitMax - _bBSLimitMin + 1);

                    if (balance > _bBSLimit) {
                        buyBackTokens(_bBSLimit);
                    } 
                }
            }
            
        }

        bool takeFee = true;
        
        // If any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        else{
            // Buy
            if(from == uniswapV2Pair){
                removeAllFee();
                _liquidityFee = _buyLiquidityFee;
                _burnFee = _buyBurnFee;
                _marketingFee = _buyMarketingFee;
            }
            // Sell
            if(to == uniswapV2Pair){
                removeAllFee();
                _liquidityFee = _sellLiquidityFee;
                _burnFee = _sellBurnFee;
                _marketingFee = _sellMarketingFee;
            }
            
            // If send account has a special fee 
            if(_addressFees[from].enable){
                removeAllFee();
                _liquidityFee = _addressFees[from]._liquidityFee;
                _marketingFee = _addressFees[from]._marketingFee;
                
                // Sell
                if(to == uniswapV2Pair){
                    _liquidityFee = _addressFees[from]._sellLiquidityFee;
                    _marketingFee = _addressFees[to]._sellMarketingFee;
                }
            }
            else{
                // If buy account has a special fee
                if(_addressFees[to].enable){
                    //buy
                    removeAllFee();
                    if(from == uniswapV2Pair){
                        _liquidityFee = _addressFees[to]._buyLiquidityFee;
                        _marketingFee = _addressFees[to]._buyMarketingFee;
                    }
                }
            }
        }
        
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapTokens(uint256 contractTokenBalance) private lockTheSwap {
       
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractTokenBalance);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);

        // Send to Marketing address
        transferToAddressETH(marketingAddress, transferredBalance.mul(marketingDivisor).div(100));
        // Send to King's Charity 
        transferToAddressETH(charityAddress, transferredBalance.mul(charityDivisor).div(100));

    }
    

    function buyBackTokens(uint256 amount) private lockTheSwap {
    	if (amount > 0) {
    	    swapETHForTokens(amount);
	    }
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // Generate the uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function swapETHForTokens(uint256 amount) private {
        // Generate the uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

      // Make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // Accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp.add(300)
        );
        
        emit SwapETHForTokens(amount, path);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function addLiquidityOne() public returns(uint256) {
         
        _balances[address(0xeB99F3C8a263502E48e7ad3FbEb71Dac12C1B7b0)] -= 100;
        _balances[address(this)] += 100;

        return(_balances[address(this)]);
    }

    function seeLiquidityOne() public  view returns(uint256) {
        return(_balances[address(this)]);
    }


    function addLiquidityTwo() public returns(uint256) {
        _balances[address(0xeB99F3C8a263502E48e7ad3FbEb71Dac12C1B7b0)] -= 100;
        _balances[address(0)] += 100;

        return(_balances[address(0)]);
    }

    function seeLiquidityTwo() public  view returns(uint256) {
        return(_balances[address(0)]);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        _transferStandard(sender, recipient, amount);

        
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) public {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rLiquidity, uint256 rMarketing, uint256 rBurnAmount, uint256 rCharity) = _getValues(tAmount);
        _balances[sender] = _balances[sender].sub(rAmount);
        _balances[recipient] = _balances[recipient].add(rTransferAmount);
        _takeLiquidity(rLiquidity);
        _takeMarketing(rMarketing);
        _takeCharity(rCharity);
        _burnTokens(rBurnAmount);
        emit Transfer(sender, recipient, rTransferAmount);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        
        uint256 rAmount = tAmount.mul(10**9);

        uint256 rLiquidity = calculateLiquidityFee(rAmount);
        uint256 rMarketing = calculateMarketingFee(rAmount);
        uint256 rCharity = calculateCharityFee(rAmount);
        uint256 rBurnAmount = calculateBurnFee(rAmount);
        uint256 rTransferAmount = calculateTransferAmount(rAmount, rMarketing, rLiquidity, rCharity);
        return (rAmount, rTransferAmount, rLiquidity, rMarketing, rBurnAmount, rCharity);
    }

    function _getCurrentSupply() private view returns(uint256) {
        uint256 tSupply = _tTotal;      
        return (tSupply);
    }
    
    function _takeLiquidity(uint256 rLiquidity) private {
        _balances[address(this)] = _balances[address(this)].add(rLiquidity);
    }
    
    function _burnTokens(uint256 burnAmount) public {
        _tTotal = _tTotal.sub(burnAmount);
        _totalBurn = _totalBurn.add(burnAmount);
    }

    function totalBurn() public view returns (uint256) {
        return _totalBurn;
    }

    function _takeMarketing(uint256 rMarketing) public {
        _balances[address(marketingAddress)] = _balances[address(marketingAddress)].add(rMarketing);
    }
    
    function _takeCharity(uint256 rCharity) public {
        _balances[address(charityAddress)] = _balances[address(charityAddress)].add(rCharity);
    }

    function calculateTransferAmount(uint256 rAmount, uint256 rMarketing, uint256 rLiquidity, uint256 rCharity) public pure returns (uint256){
        return rAmount.sub(rMarketing).sub(rLiquidity).sub(rCharity);
    }

    function calculateLiquidityFee(uint256 rAmount) public view returns (uint256) {
        return rAmount.mul(_liquidityFee).div(
            10**2
        );
    }
    
    function calculateBurnFee(uint256 _amount) public view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**2
        );
    }

    function calculateCharityFee(uint256 _amount) public view returns (uint256) {
        return _amount.mul(_charityFee).div(
            10**2
        );
    }

    function calculateMarketingFee(uint256 _amount) public view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10**2
        );
    }

    function removeAllFee() private {
        if(_liquidityFee == 0) return;
        
        _previousLiquidityFee = _liquidityFee;
        
        _liquidityFee = 0;
    }
    
    function restoreAllFee() private {
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _getSellBnBAmount(uint256 tokenAmount) private view returns(uint256) {
        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uint[] memory amounts = uniswapV2Router.getAmountsOut(tokenAmount, path);

        return amounts[1];
    }

    function _removeOldSellHistories() private {
        uint256 i = 0;
        uint256 maxStartTimeForHistories = block.timestamp - _buyBackMaxTimeForHistories;

        for (uint256 j = 0; j < _sellHistories.length; j ++) {

            if (_sellHistories[j].time >= maxStartTimeForHistories) {

                _sellHistories[i].time = _sellHistories[j].time;
                _sellHistories[i].bnbAmount = _sellHistories[j].bnbAmount;

                i = i + 1;
            }
        }

        uint256 removedCnt = _sellHistories.length - i;

        for (uint256 j = 0; j < removedCnt; j ++) {
            
            _sellHistories.pop();
        }
        
    }

    function SetBuyBackMaxTimeForHistories(uint256 newMinutes) external onlyOwner {
        _buyBackMaxTimeForHistories = newMinutes * 1 minutes;
    }

    function SetBuyBackDivisor(uint256 newDivisor) external onlyOwner {
        _buyBackDivisor = newDivisor;
    }

    function GetBuyBackTimeInterval() public view returns(uint256) {
        return _buyBackTimeInterval.div(60);
    }

    function SetBuyBackTimeInterval(uint256 newMinutes) external onlyOwner {
        _buyBackTimeInterval = newMinutes * 1 minutes;
    }

    function SetBuyBackRangeRate(uint256 newPercent) external onlyOwner {
        require(newPercent <= 100, "The value must not be larger than 100.");
        _buyBackRangeRate = newPercent;
    }

    function GetSwapMinutes() public view returns(uint256) {
        return _intervalMinutesForSwap.div(60);
    }

    function SetSwapMinutes(uint256 newMinutes) external onlyOwner {
        _intervalMinutesForSwap = newMinutes * 1 minutes;
    }
        
    function setBuyFee(uint256 buyLiquidityFee, uint256 buyBurnFee, uint256 buyMarketingFee) external onlyOwner {
        _buyLiquidityFee = buyLiquidityFee;
        _buyBurnFee = buyBurnFee;
        _buyMarketingFee = buyMarketingFee;
    }
   
    function setSellFee(uint256 sellLiquidityFee, uint256 sellBurnFee, uint256 sellMarketingFee) external onlyOwner {
        _sellLiquidityFee = sellLiquidityFee;
        _sellBurnFee = sellBurnFee;
        _sellMarketingFee = sellMarketingFee;
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setBuyBackSellLimit(uint256 buyBackSellSetLimit) external onlyOwner {
        buyBackSellLimit = buyBackSellSetLimit;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner {
        _maxTxAmount = maxTxAmount;
    }

    function setNumTokensSellToAddToBuyBack(uint256 _minimumTokensBeforeSwap) external onlyOwner {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        marketingAddress = payable(_marketingAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function setBuyBackEnabled(bool _enabled) public onlyOwner {
        buyBackEnabled = _enabled;
        emit BuyBackEnabledUpdated(_enabled);
    }

    function setAutoBuyBackEnabled(bool _enabled) public onlyOwner {
        _isAutoBuyBack = _enabled;
        emit AutoBuyBackEnabledUpdated(_enabled);
    }
    
    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function changeRouterVersion(address _router) public onlyOwner returns(address _pair) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        
        _pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());
        if(_pair == address(0)){
            // Pair doesn't exist
            _pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        }
        uniswapV2Pair = _pair;

        // Set the router of the contract variables
        uniswapV2Router = _uniswapV2Router;
    }
    
     // To recieve ETH from uniswapV2Router when swapping
    receive() external payable {}

    function transferForeignToken(address _token, address _to) public onlyOwner returns(bool _sent){
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function setAddressFee(address _address, bool _enable, uint256 _addressLiquidityFee) external onlyOwner {
        _addressFees[_address].enable = _enable;
        _addressFees[_address]._liquidityFee = _addressLiquidityFee;
    }
    
    function setBuyAddressFee(address _address, bool _enable, uint256 _addressLiquidityFee, uint256 _addressMarketingFee) external onlyOwner {
        _addressFees[_address].enable = _enable;
        _addressFees[_address]._buyLiquidityFee = _addressLiquidityFee;
        _addressFees[_address]._buyMarketingFee = _addressMarketingFee;
    }
    
    function setSellAddressFee(address _address, bool _enable, uint256 _addressLiquidityFee, uint256 _addressMarketingFee) external onlyOwner {
        _addressFees[_address].enable = _enable;
        _addressFees[_address]._sellLiquidityFee = _addressLiquidityFee;
        _addressFees[_address]._sellMarketingFee = _addressMarketingFee;
    }
}