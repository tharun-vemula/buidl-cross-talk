// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@routerprotocol/router-crosstalk/contracts/RouterCrossTalk.sol";

contract InstituteCT is RouterCrossTalk, Ownable {
    constructor(address _genericHandler) RouterCrossTalk(_genericHandler) {}

    struct RouterLinker {
        address _rSyncContract;
        uint8 _chainID;
        address _linkedContract;
    }

    function setLinker(address _linker) external onlyOwner {
        setLink(_linker);
    }

    function MapContract(RouterLinker calldata linker) external {
        iRouterCrossTalk crossTalk = iRouterCrossTalk(linker._rSyncContract);
        require(
            msg.sender == crossTalk.fetchLinkSetter(),
            "Router Generic Handler : Only Link Setter can map contracts"
        );
        crossTalk.Link{ gas: 57786 }(linker._chainID, linker._linkedContract);
    }

    function ExternalSetValue(uint8 _chainID , uint256 _value) public returns(bool) 
    {
        // Encoding the data to send
            bytes memory data = abi.encode( _value);
        // The function interface to be called on the destination chain 
            bytes4 _interface = bytes4(keccak256("SetValue(uint256)"));
            // ChainID, Selector, Data, Gas Usage(let gas = 1000000), Gas Price(1000000000)
            (bool success, bytes32 _v) = routerSend(_chainID, _interface, data, 1000000, 1000000000);
            return success;
    }
 
    // function SetValue( uint256 _value ) external isSelf {
    //     value = _value;
    // }

    function setFeeAddress ( address _feeAddress ) external onlyOwner {
        setFeeToken(_feeAddress);
    }

    function approveFee(address _feeToken, uint256 _value) external{
        approveFees(_feeToken, _value);
    }

    // function routerSync(
    //     uint8 srcChainID,
    //     address srcAddress,
    //     bytes memory data
    // )
    //     external
    //     override
    //     isLinkSync(srcChainID, srcAddress)
    //     isHandler
    //     returns (bool, bytes memory)
    // {
    //     uint8 cid = handler.fetch_chainID();
    //     (bytes4 _selector, bytes memory _data) = abi.decode(data, (bytes4, bytes));
    
    //     (bool success, bytes memory _returnData) = _routerSyncHandler(
    //     _selector,
    //     _data
    //     );
    //     emit CrossTalkReceive(srcChainID, cid, srcAddress);
    //     return (success, _returnData);
    // }

    function _routerSyncHandler(
        bytes4 _interface ,
        bytes memory _data
        ) internal virtual override  returns ( bool , bytes memory )
    {
        (uint256 _v) = abi.decode(_data, ( uint256 ));
        (bool success, bytes memory returnData) = address(this).call(abi.encodeWithSelector(_interface, _v) );
        return (success, returnData);
    }

    function replayTransaction(
        bytes32 hash,
        uint256 _crossChainGasLimit,
        uint256 _crossChainGasPrice
    ) external {
        routerReplay(
            hash,
            _crossChainGasLimit,
            _crossChainGasPrice
        );
    }

}