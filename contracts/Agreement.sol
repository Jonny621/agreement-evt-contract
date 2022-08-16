// // SPDX-License-Identifier: MIT
pragma solidity^0.8.7;

import "@newton-protocol/evt-lib/contracts/evt-base/EVT.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"]
contract Agreement is EVT, ERC721URIStorage, AccessControl {

    event AgreementReDraft(address indexed signer, string uri_);
    event AgreementSign(address indexed signer);
    event AgreementSubmit(address indexed signer);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant SIGN_ROLE = keccak256("SIGN_ROLE");

    string public agreementURI;
    address[] public signers;
    EnumerableSet.AddressSet private _signs;


    constructor(string memory uri_, address[] memory signers_) EVT("Agreement", "AGR") {
        require(signers_.length > 1, "");
        agreementURI = uri_;
        signers = signers_;
        for(uint256 i = 0; i < signers.length; i++) {
            _grantRole(SIGN_ROLE, signers[i]);
        }
    }
    // 重新起草合同
    function reDraft(string memory uri_) public onlyRole(SIGN_ROLE) {
        require(!isPass(), "Agreement has passed");
        agreementURI = uri_;
        for(uint256 i = 0; i < _signs.length(); i++) {
            _signs.remove(_signs.at(i));
        }

        emit AgreementReDraft(msg.sender, uri_);
    }
    // 查看合同是否都签字通过
    function isPass() public view returns (bool) {
        return signers.length == _signs.length();
    }
    // 进行签字
    function sign() public onlyRole(SIGN_ROLE) {
        require(!_signs.contains(msg.sender), "has signed");
        _signs.add(msg.sender);

        emit AgreementSign(msg.sender);
    }

    // 如果签字通过，进行合约生效操作
    function submitAgreement() public onlyRole(SIGN_ROLE) {
        require(isPass(), "Agreement has not passed");
        for(uint256 i = 0; i < signers.length; i++) {
            _safeMint(signers[i], i);
            _setTokenURI(i, agreementURI);
        }

        emit AgreementSubmit(msg.sender);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, EVT, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}