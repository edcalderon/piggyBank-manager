// We will be using Solidity version 0.6
pragma solidity >=0.6;
// Importing OpenZeppelin's SafeMath Implementation
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract PiggyBankBox{
    
    Piggy[] public piggys; 
   
    function createPiggy (
        string memory _title,
        string memory _description,
        uint _startBalance
        ) public payable {
        // set the new instance
        require(_startBalance >= 0);
        Piggy newPiggy = new Piggy(msg.sender, _title, _description, msg.value);
        // push the piggy address to piggys array
        piggys.push(newPiggy);
    }
    
    function returnAllPiggys() public view returns(Piggy[] memory){
        return piggys;
    }
}

contract Piggy {
    
    using SafeMath for uint256;
  
    address payable private owner; 
    string title;
    string description;
    uint startBalance;
    
    enum State{Active, Finalized}
    State public piggyState;
    
    uint public currentBalance;
    mapping(address => uint) public deposits;

    
    /** @dev constructor to creat an piggyBank
      * @param _owner who call createPiggy() in piggyboxBox contract
      * @param _title the title of the piggy
      * @param _description the description of the piggy
      */
      
   constructor(
        address payable _owner,
        string memory _title,
        string memory _description,
        uint _startBalance
        
        ) public {
        // initialize piggy
        owner = _owner;
        title = _title;
        description = _description;
        startBalance= _startBalance;
        currentBalance = _startBalance;
        piggyState = State.Active;
    }
        
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }    
        
     /** @dev Function to addBalance to the piggy
      * @return true
      */
    
    function addBalance() public payable returns(bool) {
        require(piggyState == State.Active);
        require(msg.value > 0);

        uint currentDeposit = deposits[msg.sender].add(msg.value);

        // set the currentBalance links to owner
        deposits[owner] = currentDeposit;
        currentBalance = currentDeposit;
        
        return true;
    }    

    function withdrawFunds() public onlyOwner {
        require(piggyState == State.Active);
        address payable recipiant;
        uint value;
        
        // check owner 
        if(msg.sender == owner){
            recipiant = owner;
            value = currentBalance;
        }
        
        // withdraw the value
        deposits[msg.sender] = 0;
        currentBalance = 0;
        recipiant.transfer(value);
    }
    
    /** @dev Function to return the contents of the piggy
      * @return the title of the piggy
      * @return the description of the piggy
      * @return the state of the piggy
      */        
        
    function returnContents() public view returns(        
        string memory,
        string memory,
        uint,
        State
        ) {
        return (
            title,
            description,
            currentBalance,
            piggyState
        );
    }  
}