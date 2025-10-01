//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {EthPriceConverter} from "./EthPriceConverter.sol";

error NotOwner();

contract FundMe {

    using EthPriceConverter for uint256;
    
    uint256 public constant MINIMUM_USD = 5e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable{
        require(msg.value.getConversionRate() > MINIMUM_USD, "You need more");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner{
        for(uint256 i = 0; i < funders.length; i++){
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Failed Withdrawal");
    }

    modifier onlyOwner(){
        // require(msg.sender == i_owner, "You are not the owner");
        if(msg.sender != i_owner) {revert NotOwner();}
        _;
    }

    receive() external payable{
        fund();
    }

    fallback() external payable {
        fund();
     }
}