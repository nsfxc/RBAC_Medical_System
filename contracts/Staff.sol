pragma solidity ^0.4.0;
import "./user.sol";

contract Staff is user{
	mapping(bytes32 => bool) roles;
	bytes32[] roleList;
	Admin ad;

	function Staff(){
		ad = new Admin(adminContract);
	}

	function changeRoleState(bytes32 _role) onlyBy(actionContract){
		if (roles[_role])
			roles[_role] = false;
		else
			roles[_role] = true;
	}

	function hasPermission(bytes32 _permi) returns(bool){
		for(int i = 0; i < roleList.length; i++){
			if (Ad.hasThePermission(roleList[j],_permi))
				return true;
		}
		return false;
	}
}