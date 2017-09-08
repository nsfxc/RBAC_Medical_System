pragma solidity ^0.4.0;

contract Admin{

	// Each role has a name and a mapping of related permissions
	mapping(bytes32 => Role) roles;

	address private owner;
	address private actionContract;

	struct Role{
		bytes32 role;
		// 0: not have this permission
		// 1: have undelegable permission
		// 2: have delegable permission
		mapping(bytes32 => uint) permissions;
	}

	modifier onlyBy(address _account){
		if (msg.sender != _account)
			throw;
		_;
	}

	function Admin(address _action){
		owner = msg.sender;
		actionContract = _action;
	}

	// Change the permission state of permission _permi for role _role 
	function changeRolePermission(bytes32 _role, bytes32 _permi, uint _state) onlyBy(owner){
		roles[_role].role  = _role;
		roles[_role].permissions[_permi] = _state;
	}

	// check if a role has the permission _permi and return the state of the permission (delegable or not)
	function hasThePermission(bytes32 _role, bytes32 _permi) returns(uint){
		if (roles[_role].role == _role)
			return roles[_role].permissions[_permi];
		else
			return 0;
	}
}