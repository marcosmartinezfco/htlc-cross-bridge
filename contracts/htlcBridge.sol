//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/IERC20.sol";

contract htlcBridge {

    event NewPortal(address indexed Sender, uint Amount, address Contract);

    struct Transfer {
        bytes32 commitment;     //merkle tree root hash
        address sender;         //used to generate commitment (leaf)
        address receiver;       //used to generate commitment (leaf)
        address tokenContract;  //used to generate commitment (leaf)
        uint amount;            //used to generate commitment (leaf)
        bytes32 hashLock;
        uint timeLock;
    }

    mapping(address=>Transfer) _transfers;
    mapping(address=>bool) _hasActiveTransfer;
    mapping(address=>mapping(address=>uint)) _lockedValue;

    modifier noActiveTransfer {
        require(_hasActiveTransfer[msg.sender] == false, "Error: Ongoing Transfer, wait until it either completes or expires");
        _;
    }

    function initPortal(bytes32 _commitment, bytes32 _hashLock, address _tokenContract, address _receiver, uint _amount) external noActiveTransfer{
        IERC20 tokenContract = IERC20(_tokenContract);
        require(tokenContract.allowance(msg.sender, address(this)) >= _amount, "Error: Insuficient allowance");
        _hasActiveTransfer[msg.sender] = true;
        _lockedValue[msg.sender][_tokenContract] += _amount;
        _transfers[msg.sender] = Transfer(_commitment, msg.sender, _receiver, _tokenContract, _amount, _hashLock, block.timestamp + 1 hours);
        tokenContract.transferFrom(msg.sender, address(this), _amount);
        emit NewPortal(msg.sender, _amount, _tokenContract);
    }

    function getTransfer(address _sender) external view
    returns(
        bytes32,
        address,
        address,
        address,
        uint,
        bytes32
    ){
        require(_hasActiveTransfer[_sender], "Error: There aren't any ongoing transfer for the sender");
        Transfer memory transfer = _transfers[_sender];
        return (transfer.commitment, _sender, transfer.receiver, transfer.tokenContract, transfer.amount, transfer.hashLock);
    }

    function getCommitment(address _sender, address _receiver, address _tokenContract, uint _amount) public pure returns(bytes32) {
        return _hashThis(abi.encodePacked(
                    _hashThis(abi.encodePacked(_hashThis(abi.encode(_sender)),_hashThis(abi.encode(_receiver)))),
                    _hashThis(abi.encodePacked(_hashThis(abi.encode(_tokenContract)),_hashThis(abi.encode(_amount))))
            ));
    }

    function _hashThis(bytes memory _input) private pure returns(bytes32){
        return sha256(_input);
    }
}