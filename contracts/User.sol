pragma solidity ^0.4.0;

// the staff contract that extends user contract will use 
// hasThePermission function in the adminContract to check the state of permission
/*contract Admin{
	function hasThePermission(bytes32 _role, bytes32 _permi) returns(uint);
}*/
import "./Admin.sol";


contract User{
	address owner;
	address actionContract;
	address adminContract;

	uint constant Access_event = 1;
	uint constant Delegation_event = 2;
	uint constant Break_glass_evnet = 3;

	// accounts on the blacklist cannot access user's data
	mapping(address => bool) blacklist;

	// 0: default value, not have the permission;
	// 1: have undelegable permission;
	// 2: have delegable permission;
	mapping(address => uint) accessPermissions;

	// address(0): not delegated;
	// other address: the delegator
	mapping(address => address) delegatedPermission;

	event ChangeNotification(address sender, uint status, bytes32 notificationMsg);
	
	// send the notification of activated event
	function sendEvent(uint _event, address _add, bytes32 _notification) internal returns(bool) {
        ChangeNotification(_add, _event, _notification);
        return true;
    }

	modifier onlyBy(address _account){
		if (address(msg.sender) != _account)
			throw;
		_;
	}

	// The _action and _admin are the address of action contract and admin contract
	// They can be empty address
	function User(address _action, address _admin){
		owner = msg.sender;
		if (_action != address(0x0))
			actionContract = _action;
		else
			actionContract = owner;

		if(_admin != address(0x0))
			adminContract = _admin;
		else
			adminContract = owner;
		accessPermissions[owner] = 2;
	}

	function changeActionContract(address _action) onlyBy(actionContract){
		actionContract = _action;
	}

	function changeAdminContract(address _admin) onlyBy(adminContract){
		adminContract = _admin;
	}


	function changeBlackList(address _add, bool _state) onlyBy(owner) {
		blacklist[_add]  = _state;
	}

	function changeAccessPermissionState(address _ad, uint _state) onlyBy(owner){
		accessPermissions[_ad] = _state;
	}

	// if a staff member has delegation permission and delegable access permission
	// then he can do a one-step delegation
	// the action contract will check if the staff member has the delegation permission
	function changeAccessPermissionStateByDelegation(address _delegator, address _delegatee) onlyBy(actionContract){
		if (accessPermissions[_delegator] == 2 && (!blacklist[_delegator]) && accessPermissions[_delegatee] == 0){
			if (delegatedPermission[_delegatee] == address(0x0)){
				delegatedPermission[_delegatee] = _delegator;
				sendEvent(Delegation_event, _delegatee, "Delegation");
			}
		}
	}


	// revoke the delegation by user or the delegator
	function revokeDelegation(address _delegatee){
		if (msg.sender == owner || delegatedPermission[_delegatee] == msg.sender)
			delegatedPermission[_delegatee] = address(0x0);
		else
			throw;
	}

	// In emergency situation, staff member with the break-the-glass permission can access user's data for one time
	// without having access permission
	function breakTheGlass(address _ad) onlyBy(actionContract) returns(bool){
		if (blacklist[_ad] )
			throw;

		sendEvent(Break_glass_evnet, _ad, "breakTheGlass");
		return true;
	}

	// regular access process
	function accessData() constant returns(bool){
		if (!blacklist[msg.sender])
			if (accessPermissions[msg.sender] != 0 || delegatedPermission[msg.sender] != 0){
				sendEvent(Access_event, msg.sender, "Access the data");
				return true;
			}
		return false;
	}

}