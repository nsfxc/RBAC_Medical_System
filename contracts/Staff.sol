pragma solidity ^0.4.0;
import "./User.sol";

contract Staff is User{
	mapping(bytes32 => bool) roles;
	bytes32[] roleList;
	Admin ad;

	function Staff(address adminContract){
		ad = Admin(adminContract);
	}

	function changeRoleState(bytes32 _role) onlyBy(actionContract){
		if (roles[_role])
			roles[_role] = false;
		else
			roles[_role] = true;
	}

	function hasPermission(bytes32 _permi) returns(bool){
		for(uint i = 0; i < roleList.length; i++){
			if (ad.hasThePermission(roleList[i],_permi))
				return true;
		}
		return false;
	}
}