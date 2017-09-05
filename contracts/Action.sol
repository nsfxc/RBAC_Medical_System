pragma solidity ^0.4.0;

import "./Staff.sol";

/*contract User{
	modifier onlyBy(address _account);

	function breaktheglass() onlyBy(actionContract) returns(bool);
	function changeActionContract(address _action) onlyBy(actionContract);
}

contract Staff{
	function changeActionContract(address _action);
	function breaktheglass() returns(bool);
	function hasPermission(bytes32 _permi) returns(bool);
	function changeRoleState(bytes32 _role); 
}*/

contract Action{
	mapping(address => address) staffs;
	mapping(address => address) users;
	mapping(string => bytes32) actions;

	address private root;

	modifier onlyBy(address _ac){
		if (address(msg.sender) != _ac)
			throw;
		_;
	}

	modifier ActionRequirement(bytes32 _permi){
		if (msg.sender != root){
			if (staffs[msg.sender] == address(0))
				throw;
			Staff currentStaff = Staff(staffs[msg.sender]);
			if (currentStaff.PermissionState(_permi) == 0)
				throw;
		}
		_;
	}

	modifier BreakGlassRequirement(){
		_;
	}

	modifier Verify(bytes32 hash, uint8 v, bytes32 r, bytes32 s) {
        // Note: this only verifies that signer is correct.
        // You'll also need to verify that the hash of the data
        // is also correct.
        //bytes memory prefix = "\x19Ethereum Signed Message:\n32";

    	//bytes32 prefixedHash = sha3(prefix, hash);

        if( !(ecrecover(hash, v, r, s) == msg.sender))
        	throw;
        _;
    }

	function Action() {
		root = msg.sender;
	}

	function assignPermissionRequire(string _ac, bytes32 _permi) onlyBy(root){
		actions[_ac] = _permi;
	}

	function addUser(address _ad, address _contract) ActionRequirement("addUser"){
		users[_ad] = _contract;
	}

	function addStaff(address _ad, address _contract) ActionRequirement("addStaff"){
		staffs[_ad] = _contract;
	}

	function roleAssign(address _ad, bytes32 _role) ActionRequirement("roleAssign"){
		Staff currentStaff = Staff(staffs[_ad]);
		currentStaff.changeRoleState(_role);
	}

	/*function accessData(address _ad) {
		Staff currentStaff = Staff(staffs[msg.sender]);
		User currentUser = User
		if (currentStaff.hasAccessPermission(_add))

	}*/
	

	function delegate_administrative(address _delegatee, bytes32[] _delepermi, bytes32[] _nondelepermi) ActionRequirement("delegation") returns(bool){
		Staff delegator = Staff(staffs[msg.sender]);
		Staff delegatee = Staff(staffs[_delegatee]);

		for(uint i = 0; i < _delepermi.length; i++)
			if (delegator.PermissionState(_delepermi[i]) != 2)
				throw;
		for( i = 0; i < _nondelepermi.length; i++)
			if (delegator.PermissionState(_nondelepermi[i]) == 0)
				throw;

		uint index = delegator.addDelegation(msg.sender, _delegatee, staffs[_delegatee], 0, _delepermi, _nondelepermi);
		delegatee.addDelegation(msg.sender, _delegatee, staffs[_delegatee], index, _delepermi, _nondelepermi);
		return true;
	}

	function delegate_access(address _user, address _delegatee) ActionRequirement("delegation"){
		if(staffs[_delegatee] == address(0x0))
			throw;

		User currentUser = User(users[_user]);
		currentUser.changeAccessPermissionStateByDelegation(msg.sender, _delegatee);
	}

	function breakTheGlass(address _ad/*, bytes32 hash, uint8 v, bytes32 r, bytes32 s*/) ActionRequirement("breakTheGlass") /*Verify(hash, v, r, s)*/ {

		User currentUser = User(users[_ad]);
		currentUser.breakTheGlass(msg.sender);
	}

}