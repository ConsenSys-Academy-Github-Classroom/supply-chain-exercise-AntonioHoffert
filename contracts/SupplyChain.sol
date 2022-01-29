// SPDX-License-Identifier: MIT
pragma solidity >=0.5.17 <0.9.0;

contract SupplyChain {
  address public owner;
  // <owner>
  uint public skuCount;
  // <skuCount>
  mapping(uint => Item) public items;
  // <items mapping>
  enum State {
    ForSale,
    Sold,
    Shipped,
    Received
    }
    
  // <enum State: ForSale, Sold, Shipped, Received>
  State public state;
   struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
   }
  // <struct Item: name, sku, price, state, seller, and buyer>
  
  /* 
   * Events
   */
  event LogForSale(uint LogForSale);
  event LogSold(uint LogSold);
  event LogShipped(uint LogShipped);
  event LogReceived(uint LogReceived);
  // <LogForSale event: sku arg>

  // <LogSold event: sku arg>

  // <LogShipped event: sku arg>

  // <LogReceived event: sku arg>


  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner
  modifier isOwner(address _owner) { require (msg.sender == _owner); _;}

  modifier verifyCaller(address _address) { 
    require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) {
    require(msg.value >= _price); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
    _;
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  modifier forSale(State _state, uint _price) {require (_state == State.ForSale && _price != 0); _;}
  modifier sold(State _state) {require (_state == State.Sold); _;}
  modifier shipped(State _state) {require (_state == State.Shipped); _;}
  modifier received(State _state) {require (_state == State.Received); _;}


  constructor() public {
    owner = msg.sender;
    skuCount = 0;
    // 1. Set the owner to the transaction sender
    // 2. Initialize the sku count to 0. Question, is this necessary?
  }
  function getOwner() public returns(address){
    return owner;
  }
  function addItem(string memory _name, uint _price) public returns (bool) {
    // 1. Create a new item and put in array
    // 2. Increment the skuCount by one
    // 3. Emit the appropriate event
    // 4. return true
    // hint:
    items[skuCount] = Item({
     name: _name, 
     sku: skuCount, 
     price: _price, 
     state: State.ForSale, 
     seller: msg.sender, 
     buyer: address(0)
    });
    skuCount = skuCount + 1;
    emit LogForSale(skuCount);
    return true;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller, 
  // 3. set the buyer as the person who called this transaction, 
  // 4. set the state to Sold. 
  // 5. this function should use 3 modifiers to check 
  //    - if the item is for sale, 
  //    - if the buyer paid enough, 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  // 6. call the event associated with this function!
  function buyItem(uint _sku) public payable paidEnough(items[_sku].price) forSale(items[_sku].state, items[_sku].price) checkValue(_sku)
  {
    require(msg.value >=items[_sku].price);
    items[_sku].seller.transfer(items[_sku].price);
    items[_sku].buyer = msg.sender;
    items[_sku].state = State.Sold;
    emit LogSold(_sku);
  }
  
  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
    function shipItem(uint _sku) public sold(items[_sku].state) verifyCaller(items[_sku].seller)  {
    require(msg.sender == items[_sku].seller);
    items[_sku].state = State.Shipped;
    emit LogShipped(_sku);
  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint _sku) public shipped(items[_sku].state) verifyCaller(items[_sku].buyer)
  {
    items[_sku].state = State.Received;
    emit LogReceived(_sku);
  }

  // Uncomment the following code block. it is needed to run tests
 function fetchItem(uint _sku) public view 
   returns (string memory name, uint sku, uint price, uint state, address seller, address buyer)
 { 
   name = items[_sku].name;
   sku = items[_sku].sku;
   price = items[_sku].price;
   state = uint(items[_sku].state);
   seller = items[_sku].seller;
   buyer = items[_sku].buyer;
   return (name, sku, price, state, seller, buyer);
 }
}