# solidity智能合约语言

## 基本数据类型，数据结构
### 数据类型
uint 包括uint8到uint256每隔8位的无符号整数<br>
uint 是uint256的别名，默认uint为uin256

### 防止溢出 SafeMath
``` solidity
using SafeMath for uint256;

uint256 a = 5;
uint256 b = a.add(3); // 5 + 3 = 8
uint256 c = a.mul(2); // 5 * 2 = 10
```

※address

### 数据结构 
#### mapping key-value
``` solidity
mapping(address => uint) public accountBalance;
mapping(uint => string) userIdToName;
```

### storage, memory

## 函数

### public, private<br>internal, external
内部函数习惯以 '_'打头 private
internal == private 只能内部访问，继承不可访问<br>
external只能在外部访问 < public内外部，继承也可以访问<br>

###处理多个返回值

``` solidity
function fun1() returns (uint1, uint2, uint3){}
(,,param3) = fun1();
```

### view, pure 不消耗gas
view只读不写<br>
pure不读不写<br>

``` solidity
function sayHello() public view returns (string) {
  return myString;
}

function _multiply(uint a, uint b) private pure returns (uint) {
  return a * b;
}
```

### event 事件 (前端会监听)
``` solidity
event IntegersAdded(uint x, uint y, uint result);

function add(uint _x, uint _y) public {
  ...
  emit IntegersAdded(_x, _y, result);
  ...
}
```

### modifier 函数修饰符
``` solidity
modifier onlyOwner() {
  require(isOwner());
  _;//类似函数返回，出栈回到原函数
}

function renounceOwnership() public onlyOwner {
  emit OwnershipTransferred(_owner, address(0));
  _owner = address(0);
}
```

函数`renounceOwnership()`会在运行函数体之前运行`modifier`修饰的函数`onlyOwner`<br>
还可以带参数，堆叠多个`modifier`等
``` solidity
function test() external view onlyOwner anotherModifier { /* ... */ }
```

### 调用者 msg.sender

## Keccak256
SHA3 返回256位16进制数字<br>
``` solidity
keccak256(abi.encodePacked("${string}"));
```
## require 类似 assert

## 时间单位 seconds, minutes, hours, days, weeks, years



