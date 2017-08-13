pragma solidity ^0.4.0;

contract Admin{
	//bytes32[] private permissionList;
	//bytes32[] private roleList;

	mapping(bytes32 => Role) roles;

	address private owner;
	address private actionContract;

	struct Role{
		bytes32 role;
		mapping(bytes32 => bool) permissions;
	}

	modifier onlyBy(address _account){
		if (msg.sender != _account)
			throw;
		_;
	}

	function admin(address _action){
		owner = msg.sender;
		actionContract = _action;
	}

	function changeRolePermission(bytes32 _role, bytes32 _permi) onlyBy(owner){
		roles[_role].role  = _role;
		roles[_role].permissions[_permi] = (!roles[_role].permissions[_permi]);

	}

	function hasThePermission(bytes32 _role, bytes32 _permi) return(bool){
		if (roles[_role].role == _role && roles[_role].permissions[_permi])
			return true;
		else
			return false;
	}
}