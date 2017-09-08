pragma solidity ^0.4.0;

import "./Staff.sol";

contract Action{
	mapping(address => address) staffs;
	mapping(address => address) users;

	address private root;

	modifier onlyBy(address _ac){
		if (address(msg.sender) != _ac)
			throw;
		_;
	}

	// The action can be taken by the administrator or staff member with permission _permi

	modifier ActionRequirement(bytes32 _permi){
		if (msg.sender != root){
			if (staffs[msg.sender] == address(0)){
				throw;
				sendEvent(msg.sender, "Requirement not satisfied!");
			}
			Staff currentStaff = Staff(staffs[msg.sender]);
			if (currentStaff.PermissionState(_permi) == 0){
				throw;
				sendEvent(msg.sender, "Requirement not satisfied!");
			}
		}
		_;
	}

	modifier Verify(bytes32 hash, uint8 v, bytes32 r, bytes32 s) {
        // Note: this only verifies that signer is correct.

        if( !(ecrecover(hash, v, r, s) == msg.sender)){
        	throw;
        	sendEvent(msg.sender, "Wrong signature!");
        }
        _;
    }

    event ChangeNotification(address sender, bytes32 notificationMsg);
	
	// send the notification of activated event
	function sendEvent(address _add, bytes32 _notification) internal returns(bool) {
        ChangeNotification(_add, _notification);
        return true;
    }

	function Action() {
		root = msg.sender;
	}

	// changme the administrator

	function changeAdministrator(address _add) onlyBy(root){
		if (staffs[_add] != address(0x0))
			root = _add;
	}

	// Add a new user, if the user is not a staff member, than store the user's contract address

	function addUser(address _ad, address _contract) ActionRequirement("addUser"){
		if (staffs[_ad] == address(0x0))
			users[_ad] = _contract;
		else
			sendEvent(_ad, "User is a staff member.");
	}

	// Add a new staff, store the staff member's contract address
	// If the staff member is also a user, erase the user contract as staff contract extends user contract

	function addStaff(address _ad, address _contract) ActionRequirement("addStaff"){
		staffs[_ad] = _contract;
		if (users[_ad] != address(0x0))
			users[_ad] = address(0x0);
	}

	// assign the role _role to staff member with address _ad

	function roleAssign(address _ad, bytes32 _role) ActionRequirement("roleAssign"){
		if (staffs[_ad] != address(0x0)){
			Staff currentStaff = Staff(staffs[_ad]);
			currentStaff.changeRoleState(_role);
		}
	}


	// delegate delegable permissions _delepermi and undelegable permissions _nondelepermi
	// from msg.sender to _delegatee

	function delegate_administrative(address _delegatee, bytes32[] _delepermi, bytes32[] _nondelepermi) ActionRequirement("delegation") returns(bool){
		Staff delegator = Staff(staffs[msg.sender]);
		Staff delegatee = Staff(staffs[_delegatee]);

		if ((!delegator.canDelegate()) || (!delegatee.canDelegate())){
			sendEvent(msg.sender,"To many delegations!");
			throw;
		}

		for(uint i = 0; i < _delepermi.length; i++)
			if (delegator.PermissionState(_delepermi[i]) != 2)
				throw;
		for( i = 0; i < _nondelepermi.length; i++)
			if (delegator.PermissionState(_nondelepermi[i]) == 0)
				throw;

		uint index = delegator.addDelegation(msg.sender, staffs[msg.sender], staffs[_delegatee], 0, _delepermi, _nondelepermi);
		delegatee.addDelegation(msg.sender,staffs[msg.sender], staffs[_delegatee], index, _delepermi, _nondelepermi);
		return true;
	}


	// delegate access permission of user _user from msg.sender to _delegatee

	function delegate_access(address _user, address _delegatee) ActionRequirement("delegation"){
		if(staffs[_delegatee] == address(0x0))
			throw;

		User currentUser = User(users[_user]);
		currentUser.changeAccessPermissionStateByDelegation(msg.sender, _delegatee);
	}

	// break-the-glass of user _ad by msg.sender

	function breakTheGlass(address _ad, bytes32 hash, uint8 v, bytes32 r, bytes32 s) ActionRequirement("breakTheGlass") Verify(hash, v, r, s) {

		User currentUser = User(users[_ad]);
		currentUser.breakTheGlass(msg.sender);
	}

}