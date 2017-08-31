pragma solidity ^0.4.0;

import "./Staff.sol";

/*contract User{
	modifier onlyBy(address _account);

	function breaktheglass() onlyBy(actionContract) returns(bool);
	function changeActionContract(address _action) onlyBy(actionContract);
}

contract Staff{
	function changeActionContract(address _action);
	function breaktheglass() returns(bool);
	function hasPermission(bytes32 _permi) returns(bool);
	function changeRoleState(bytes32 _role); 
}*/

contract Action{
	mapping(address => address) staffs;
	mapping(address => address) users;
	mapping(string => bytes32) actions;

	address private root;

	modifier onlyBy(address _ac){
		if (address(msg.sender) != _ac)
			throw;
		_;
	}

	modifier ActionRequirement(bytes32 _permi){
		if (!(msg.sender == root)){
			if (staffs[msg.sender] == address(0))
				throw;
			Staff currentStaff = Staff(staffs[msg.sender]);
			if (!currentStaff.hasPermission(_permi))
				throw;
		}
		_;
	}

	modifier BreakGlassRequirement(){
		_;
	}

	function Action() {
		root = msg.sender;
	}

	function assignPermissionRequire(string _ac, bytes32 _permi) onlyBy(root){
		actions[_ac] = _permi;
	}

	function addUser(address _ad, address _contract) ActionRequirement(actions["addUser"]){
		users[_ad] = _contract;
	}

	function addStaff(address _ad, address _contract) ActionRequirement(actions["addStaff"]){
		staffs[_ad] = _contract;
	}

	function roleAssign(address _ad, bytes32 _role) ActionRequirement(actions["roleAssign"]){
		Staff currentStaff = Staff(staffs[_ad]);
		currentStaff.changeRoleState(_role);
	}

	/*function accessData(address _ad) {
		Staff currentStaff = Staff(staffs[msg.sender]);
		User currentUser = User
		if (currentStaff.hasAccessPermission(_add))

	}*/

	function breakTheGlass(address _ad) ActionRequirement(actions["breakTheGlass"]) BreakGlassRequirement() returns(bool){
		User currentUser = User(users[_ad]);
		return currentUser.breaktheglass();
	}

}