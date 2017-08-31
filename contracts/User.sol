pragma solidity ^0.4.0;

contract Admin{
	function hasThePermission(bytes32 _role, bytes32 _permi) returns(bool);
}


contract User{
	address owner;
	address actionContract;
	address adminContract;

	mapping(address => bool) blacklist;
	mapping(address => uint) accessPermissions;
	mapping(address => uint) delegatedPermissions;

	event connect();
	event notify();

	modifier onlyBy(address _account){
		if (address(msg.sender) == _account)
			throw;
		_;
	}

	function User(address _action, address _admin){
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


	function changeBlackList(address _add) onlyBy(owner) returns(bool){
		blacklist[_add]  = (!blacklist[_add]);
		return black[_add];
	}

	function changeAccessPermissionState(address _ad, uint _state) onlyBy(owner){
		accessPermissions[_ad] = _state;
	}

	function delegation(address _ad, uint _state) {
		if (accessPermissions[msg.sender] == 2 && (!blacklist[_ad]))
			accessPermission[_ad] = _state;
		nofity();
	}

	function breaktheglass() onlyBy(actionContract) returns(bool){
		return true;
	}

	function accessData(address _add) returns(bool){
		if (accessPermissions[msg.sender]){
			connect();
			return true;
		}
		return false;
	}

}