pragma solidity ^0.4.0;

// the staff contract that extends user contract will use 
// hasThePermission function in the adminContract to check the state of permission
contract Admin{
	function hasThePermission(bytes32 _role, bytes32 _permi) returns(bool);
}


contract User{
	address owner;
	address actionContract;
	address adminContract;

	// accounts on the blacklist cannot access user's data
	mapping(address => bool) blacklist;

	// 0: default value, not have the permission;
	// 1: have undelegable permission;
	// 2: have delegable permission;
	mapping(address => uint) accessPermissions;

	//event connect();
	//event notify();

	modifier onlyBy(address _account){
		if (address(msg.sender) == _account)
			throw;
		_;
	}

	function User(address _action, address _admin){
		owner = msg.sender;
		actionContract = _action;
		adminContract = _admin;
		accessPermissions[owner] = 2;
	}

	function changeActionContract(address _action) onlyBy(actionContract){
		actionContract = _action;
	}

	function changeAdminContract(address _admin) onlyBy(adminContract){
		adminContract = _admin;
	}


	function changeBlackList(address _add) onlyBy(owner) returns(bool){
		blacklist[_add]  = (!blacklist[_add]);
		return blacklist[_add];
	}

	function changeAccessPermissionState(address _ad, uint _state) onlyBy(owner){
		accessPermissions[_ad] = _state;
	}

	// if a staff member has delegation permission and delegable access permission
	// then he can do a one-step delegation
	// the action contract will check if the staff member has the delegation permission
	function changeAccessPermissionStateByDelegation(address _delegator, address _delegatee) onlyBy(actionContract){
		if (accessPermissions[_delegator] == 2 && (!blacklist[_delegator]))
			if (accessPermissions[_delegatee] != 1)
				accessPermissions[_delegatee] = 1;
		//nofity();
	}

	// In emergency situation, staff member with the break-the-glass permission can access user's data for one time
	// without having access permission
	function breakTheGlass(address _ad) onlyBy(actionContract) returns(bool){
		if (blacklist[_ad] )
			throw;
		//notify();
		//connect();
		return true;
	}

	// regular access process
	function accessData() returns(bool){
		if (accessPermissions[msg.sender] != 0){
			//connect();
			return true;
		}
		return false;
	}

}