pragma solidity ^0.4.0;
import "./User.sol";

contract Staff is User{
	mapping(bytes32 => bool) roles;

	// next available index of delegation
	uint[] nextAvailable;

	bytes32[] roleList;
	Admin ad;

	// The current number of admin delegation
	uint numDelegation;

	// The maximul number of admin delegation a staff may have
	uint maxDelegation = 50;

	// delegations made from this staff or to this staff
	mapping(uint => delegation) delegations;

	struct delegation{
		// index of this delegation
		uint index;
		// delegation from
		address from;
		address fromContract;
		// delegation to
		uint toIndex;
		address toContract;
		// permissions delegated by this delegation
		mapping(bytes32 => uint) adminPermi;
		// the number of active permissions
		uint numPermi;
	}

	event ChangeNotification(address sender, bytes32 notificationMsg);
	
	// send the notification of activated event
	function sendEvent(address _add, bytes32 _notification) internal returns(bool) {
        ChangeNotification(_add, _notification);
        return true;
    }

	function Staff(address _actionContract, address _adminContract) User(_actionContract, _adminContract){
		ad = Admin(_adminContract);
		numDelegation = 0;
		for(uint i = 0; i < maxDelegation; i++)
			nextAvailable.push(i);
	}

	// the action contract could assign the staff with a role

	function changeRoleState(bytes32 _role) onlyBy(actionContract) returns(bool){
		if (roles[_role])
			roles[_role] = false;
		else{
			roles[_role] = true;
			roleList.push(_role);
		}
		return roles[_role];
	}

	// Check if the staff has the permission _action

	function PermissionState(bytes32 _action) constant returns(uint){
		uint current = 0;
		uint temp = 0;
		// check if the permission is associated with roles
		for(uint i = 0; i < roleList.length; i++){
			// call admin contract to check if the role has permission _action
			temp = ad.hasThePermission(roleList[i],_action);
			if ( temp > current)
				current  = temp;
		}

		// if find a delegable permission, return
		if (temp == 2)
			return temp;

		// check if the permission has been delegated to the staff
		for(i = 0; i < numDelegation; i++){
			if (delegations[i].from != owner)
				if(delegations[i].adminPermi[_action] > temp)
					temp = delegations[i].adminPermi[_action];
		}
		// return the permission state
		return temp;
	}

	function canDelegate() returns(bool){
		return (numDelegation < maxDelegation);
	}

	//The action contract can add a delegation
	function addDelegation(address _from, address _fromContract, address _toContract, uint _toIndex, bytes32[] _deleadmin, bytes32[] _nondeleadmin) onlyBy(actionContract) returns(uint){

		if (numDelegation >= maxDelegation){
			sendEvent(_from,"To much delegation!");
			throw;
		}

		uint _tmpIndex = nextAvailable[numDelegation];
		delegations[_tmpIndex].index = _tmpIndex;
		delegations[_tmpIndex].from = _from;
		delegations[_tmpIndex].fromContract = _fromContract;
		delegations[_tmpIndex].toIndex = _toIndex;
		delegations[_tmpIndex].toContract = _toContract;

		for(uint i = 0; i < _deleadmin.length; i++)
			delegations[_tmpIndex].adminPermi[_deleadmin[i]] = 2;


		for(i = 0; i < _nondeleadmin.length; i++)
			delegations[_tmpIndex].adminPermi[_nondeleadmin[i]] = 1;

		delegations[_tmpIndex].numPermi = _deleadmin.length + _nondeleadmin.length;

		numDelegation++;
		return (_tmpIndex);
	}


	// If the staff lose a delegable permission P during a revocation of delegation
	// We need to check all other delegations made by the staff related to permission P 
	// and revoke recursively the permission P

	function revokeDelegationPrivate(uint _delegation, bytes32 _permi) internal{
		delegations[_delegation].adminPermi[_permi] = 0;
		delegations[_delegation].numPermi--;

		// if this delegation is totally revoked, clear this delegation, 
		// make this index as the next available index
		if (delegations[_delegation].numPermi == 0){
			numDelegation--;
			nextAvailable[numDelegation] = _delegation;
		}

		Staff delegatee = Staff(delegations[_delegation].toContract);
		delegatee.revokeDelegation(delegations[_delegation].toIndex, _permi);
	}


	// a delegation can be revoked by the delegator, the delegator's contract or the action contract
	function revokeDelegation(uint _delegation, bytes32 _permi) {

		if(msg.sender != delegations[_delegation].from && msg.sender != delegations[_delegation].fromContract)
			throw;

		// revoke the permission
		if (delegations[_delegation].adminPermi[_permi] == 1){
			delegations[_delegation].adminPermi[_permi] = 0;
			delegations[_delegation].numPermi--;
		}else if (delegations[_delegation].adminPermi[_permi] == 2){

			delegations[_delegation].adminPermi[_permi] = 0;
			delegations[_delegation].numPermi--;

			// if this permission is delegable, 
			// check if the staff member has delegate other staffs with this permission
			if (PermissionState(_permi) != 2){
				for(uint i = 0; i < numDelegation; i++)
					if (delegations[i].from == owner && delegations[i].adminPermi[_permi] != 0)
						revokeDelegationPrivate(delegations[i].toIndex, _permi);

			}
		}
		// if this delegation is totally revoked, clear this delegation, 
		// make this index as the next available index

		if (delegations[_delegation].numPermi == 0){
			numDelegation--;
			nextAvailable[numDelegation] = _delegation;
		}

	}

}