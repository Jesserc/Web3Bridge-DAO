// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { IERC20 } from "../interfaces/IERC20.sol";

contract vault1 {

    constructor (address _tokenContract, address _owner ) {
        tokenContract = IERC20(_tokenContract);
        owner = _owner;
    }

    bool withdrawTimeReached;
    uint216 amountDepositedForSharing;
    uint8 numberOfPaidUsers;
    address owner;
    IERC20 tokenContract;
    
    struct earlyPayment {
        address earlyPayers;
        bool withdrawn;
    }

    mapping (address => earlyPayment) EarlyPayers;

    function depositIntoVault (uint216 _amount) external {
        amountDepositedForSharing += _amount;
        IERC20(tokenContract).transferFrom(msg.sender, address(this), _amount);
    }

    function addAddressOfEarlyPayment () external {
        numberOfPaidUsers++;
        earlyPayment storage EP = EarlyPayers[msg.sender];
        EP.earlyPayers = msg.sender;
    }
 
    function withdrawShare (address _addr) external {
        earlyPayment storage EP = EarlyPayers[msg.sender];
        assert(EP.withdrawn == false);
        uint216 share = individualShare();
        amountDepositedForSharing -= share;
        EP.withdrawn = true;
        IERC20(tokenContract).transfer(_addr, share);
        numberOfPaidUsers--;
    }

    function individualShare () private view returns (uint216 share){
       share =  amountDepositedForSharing / numberOfPaidUsers;
    } 

    function openVault () public {
        assert(msg.sender == owner);
        withdrawTimeReached = true;
    }

}