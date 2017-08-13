pragma solidity ^0.4.0;

contract Admin{
	function hasThePermission();
}

contract User{
	mapping(address => bool) accessPermission;
	address private owner;
	address actionContract;
	address adminContract;

	modifier onlyBy(address _account){
		if (msg.sender != _account)
			throw;
		_;
	}

	function user(address _action, address _admin){
		owner = msg.sender;
		actionContract = _action;
		adminContract = _admin;
	}

	function changeActionContract(address _action) onlyBy(actionContract){
		actionContract = _action;
	}

	function changeAdminContract(address _admin) onlyBy(adminContract){
		adminContract = _admin;
	}


	function changeAccessPermission(address _add) onlyBy(owner){
		if (accessPermission[_add])
			accessPermission[_add] = false;
		else
			accessPermission[_add] = true; 
	}

	function breaktheglass() onlyBy(actionContract) returns(bool){
		return true;
	}

	function accessData(address _demander) returns(bool){
		 return accessPermission[_demander];
	}

}