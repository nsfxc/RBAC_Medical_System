pragma solidity ^0.4.0;

contract Admin{
	//bytes32[] private permissionList;
	//bytes32[] private roleList;

	mapping(bytes32 => Role) roles;

	address private owner;
	address private actionContract;

	struct Role{
		bytes32 role;
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

	function changeRolePermission(bytes32 _role, bytes32 _permi, uint _state) onlyBy(owner){
		roles[_role].role  = _role;
		roles[_role].permissions[_permi] = _state;
	}

	function hasThePermission(bytes32 _role, bytes32 _permi) returns(uint){
		if (roles[_role].role == _role)
			return roles[_role].permissions[_permi];
		else
			return 0;
	}
}