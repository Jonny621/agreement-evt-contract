// // SPDX-License-Identifier: MIT
pragma solidity^0.8.7;

import "./Agreement.sol";

contract AgreementFactory {
    Agreement[] private _agreements;

    function CreateAgreement(string memory uri_, address[] memory signers_) public returns (address) {
        Agreement agreement = new Agreement(uri_, signers_);
        _agreements.push(agreement);
        return address(agreement);
    }

    function getAgreements() public view returns (Agreement[] memory) {
        return _agreements;
    }
}