pragma solidity 0.8.17;

import "https://github.com/filecoin-project/filecoin-solidity/blob/master/contracts/v0.8/MinerAPI.sol";
import "https://github.com/filecoin-project/filecoin-solidity/blob/master/contracts/v0.8/types/CommonTypes.sol";
import "https://github.com/filecoin-project/filecoin-solidity/blob/master/contracts/v0.8/utils/BigInts.sol";
import "https://github.com/filecoin-project/filecoin-solidity/blob/master/contracts/v0.8/utils/FilAddresses.sol";
import "https://github.com/filecoin-project/filecoin-solidity/blob/master/contracts/v0.8/PrecompilesAPI.sol";

contract Test {
    uint constant X = 10 ** 18;

    uint64 contractActorID;
    mapping(address => int) balances;
    mapping(address => CommonTypes.FilActorId) mortgage;

    constructor() {
        contractActorID = PrecompilesAPI.resolveEthAddress(address(this));
    }

    function deposit() payable public {
        balances[msg.sender] += int(msg.value);
    }

    function changeOwner(CommonTypes.FilActorId minerActor) public {
        MinerAPI.changeOwnerAddress(minerActor, FilAddresses.fromActorID(contractActorID));
        mortgage[msg.sender] = minerActor;
    }

    function retrieveOwner(uint64 retrieveID) public {
        require(balances[msg.sender] >= 0);
        MinerAPI.changeOwnerAddress(mortgage[msg.sender], FilAddresses.fromActorID(retrieveID));
    }

    function withdraw(uint amount) public {
        balances[msg.sender] -= int(amount);
        require(balances[msg.sender] > -int(50 * X));
        
        if (balances[msg.sender] < 0) {
            require(CommonTypes.FilActorId.unwrap(mortgage[msg.sender]) != 0);
        }

        payable(msg.sender).transfer(amount);
    }

    

    fallback() external payable {}

    receive() external payable {}
}