// SPDX-License-Identifier: Unlicensed
pragma solidity  >=0.7.0 <0.9.0;

contract CryptoKids {

    // Owner Dad Contract
    address owner;

    // Event listener on the front-end
    event LogKidFundingRecieved( address add, uint amount, uint contractBalance);

    // Initializing a constructor
    constructor() {
        owner = msg.sender;
    }

    // Define Kid Objects
    struct Kid{
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    // dynamic array
    Kid[] public kids;

    // Only Ownwer can add kids address
    modifier onlyOwner{
        require(msg.sender == owner, "Only the owner can add kids");
        _;
    }

    // add kid to contract
    function addKid(
        address payable walletAddress,string  memory firstName,
        string memory lastName,uint releaseTime,
        uint amount,bool canWithdraw) public  onlyOwner{
            kids.push(Kid(
                walletAddress,
                firstName, lastName, 
                releaseTime, amount,
                canWithdraw
            ));
        }

        // Check Total balance
        function balanceOf() public view returns(uint){
            return address(this).balance;
        }

        // deposit fund to contract, specifically to a kid's account
        function deposit(address walletAddress) payable  public{
            addToKidsBalance(walletAddress);
        }

        function addToKidsBalance(address walletAddress) private{
            for(uint i = 0; i < kids.length; i++){
                if(kids[i].walletAddress == walletAddress){
                    kids[i].amount += msg.value; // send and recieve transaction
                    // Emit the notifications on the front-end.
                    emit LogKidFundingRecieved(walletAddress, msg.value, balanceOf());
                }
            }
        }

        // get index 
        function getIndex(address walletAddress) view private returns(uint){
            for(uint i = 0; i < kids.length; i++){
                if(kids[i].walletAddress == walletAddress){
                    return i;
                }
            }
            return 999;
        }

        // kid checks if able to withdraw
        function availableToWithdraw(address walletAddress) public returns(bool){
            uint i = getIndex(walletAddress);
            // block time
            require(block.timestamp > kids[i].releaseTime, "You cannot withdraw yet");
            if(block.timestamp > kids[i].releaseTime){
                kids[i].canWithdraw = true;
                return true;
            }else{
                return false;
            }
        }


        // withdraw money
        function withdraw(address payable walletAddress) payable public{
            uint i = getIndex(walletAddress);
            require(msg.sender == kids[i].walletAddress, "You must be the kid to withdraw.");
            require(kids[i].canWithdraw == true, "You are not able to withdraw at this time.");
            kids[i].walletAddress.transfer(kids[i].amount);
        } 

  
}

   



