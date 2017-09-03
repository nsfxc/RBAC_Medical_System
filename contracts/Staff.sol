pragma solidity ^0.4.0;
import "./User.sol";

contract Staff is User{
	mapping(bytes32 => bool) roles;
	bytes32[] roleList;
	Admin ad;

	uint numDelegation;

	mapping(uint => delegation) delegations;

// 0: not have the access permission; 1: have non-delegable permission 2: have delegable permission
	//mapping(address => uint) accessPermissions;

	struct delegation{
		uint index;
		uint toIndex;
		address from;
		address fromContract;
		address to;
		address toContract;
		mapping(bytes32 => uint) adminPermi;
		//mapping(address => uint) accessPermi;
	}

	function Staff(address _actionContract, address _adminContract) User(_actionContract, _adminContract){
		//owner = msg.sender;
		//actionContract = _actionContract;
		//adminContract = _adminContract;
		ad = Admin(_adminContract);
		numDelegation = 0;
	}

	function changeRoleState(bytes32 _role) onlyBy(actionContract) returns(bool){
		if (roles[_role])
			roles[_role] = false;
		else
			roles[_role] = true;
		return roles[_role];
	}

	/*function changeAccessPermission(uint delegableState) {
		accessPermissions[msg.sender] = delegableState;
	}*/

	function PermissionState(bytes32 _action) returns(uint){
		for(uint i = 0; i < roleList.length; i++){
			if (ad.hasThePermission(roleList[i],_action))
				return 2;
		}
		for(i = 0; i < numDelegation; i++){
			if (delegations[i].to == owner)
				if(delegations[i].adminPermi[_action] != 0)
					return delegations[i].adminPermi[_action];
		}
		return 0;
	}

	/*function hasAccessPermission(address _add) returns(bool){
		if (accessPermissions[_add] != 0)
			return true;

		for(uint i = 0; i < numDelegation; i++){
			if (delegations[i].to == owner)
				if(delegations[i].accessPermi[_add] != 0)
					return true;		
		}
		return false;
	}*/


	function addDelegation(address _from, address _to, address _toContract, uint _toIndex, bytes32[] _deleadmin, bytes32[] _nondeleadmin) onlyBy(actionContract) returns(uint){

		delegations[numDelegation].index = numDelegation;
		delegations[numDelegation].from = _from;
		delegations[numDelegation].to = _to;
		delegations[numDelegation].toIndex = _toIndex;
		//delegations[numDelegation].fromContract = _fromContract;
		delegations[numDelegation].toContract = _toContract;

		for(uint i = 0; i < _deleadmin.length; i++)
			delegations[numDelegation].adminPermi[_deleadmin[i]] = 2;


		for(i = 0; i < _nondeleadmin.length; i++)
			delegations[numDelegation].adminPermi[_nondeleadmin[i]] = 1;


		numDelegation++;
		return (numDelegation - 1);
	}

	function revokeDelegationPrivate(uint _delegation, bytes32 _permi) internal{
		delegations[_delegation].adminPermi[_permi] = 0;
		Staff delegatee = Staff(delegations[_delegation].toContract);
		delegatee.revokeDelegation(delegations[_delegation].toIndex, _permi);
	}

	function revokeDelegation(uint _delegation, bytes32 _permi) {
		if(msg.sender != delegations[_delegation].from && msg.sender != delegations[_delegation].fromContract && msg.sender != actionContract)
			throw;

		if (delegations[_delegation].adminPermi[_permi] != 0)
			delegations[_delegation].adminPermi[_permi] = 0;
		if (PermissionState(_permi) != 2){
			for(uint i = 0; i < numDelegation; i++)
				if (delegations[i].from == owner && delegations[i].adminPermi[_permi] != 0)
					revokeDelegationPrivate(delegations[i].toIndex, _permi);

		}
	}

}