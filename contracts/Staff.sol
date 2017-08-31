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
		address from;
		address to;
		mapping(string => uint) adminPermi;
		//mapping(address => uint) accessPermi;
	}

	function Staff(address _actionContract, address _adminContract) User(_actionContract, _adminContract){
		//owner = msg.sender;
		//actionContract = _actionContract;
		//adminContract = _adminContract;
		ad = Admin(_adminContract);
		numDelegation = 0;
	}

	function changeRoleState(bytes32 _role) onlyBy(actionContract) {
		if (roles[_role])
			roles[_role] = false;
		else
			roles[_role] = true;
	}

	/*function changeAccessPermission(uint delegableState) {
		accessPermissions[msg.sender] = delegableState;
	}*/

	function PermissionState(string _action) returns(uint){
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


	function addDelegation(address _from, address _to, string[] _deleadmin, string[] _nondeleadmin) onlyBy(actionContract){

		delegations[numDelegation].int = numDelegation;
		delegations[numDelegation].from = _from;
		delegations[numDelegation].to = _to;

		for(int i = 0; i < _delegable.length; i++)
			delegations[numDelegation].adminPermi[_deleadmin[i]] = true;
		/*for(int i = 0; i < _undelegable.length; i++){
			delegations[numDelegation].accessPermi[_deleaccess[i]] = true;
			accessPermissions[_deleaccess[i]] = 2;
		}*/

		for(int i = 0; i < _delegable.length; i++)
			delegations[numDelegation].adminPermi[_nondeleadmin[i]] = true;
		/*for(int i = 0; i < _undelegable.length; i++){
			delegations[numDelegation].accessPermi[_nondeleaccess[i]] = true;
			if (accessPermissions[_deleaccess[i]] != 2)
				accessPermission[_deleaccess[i]] = 1;
		}*/

		numDelegation++;
	}


}