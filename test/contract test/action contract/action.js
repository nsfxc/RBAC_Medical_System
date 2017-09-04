var Action = artifacts.require("./Action.sol");
var User = artifacts.require("./User.sol");
var Staff = artifacts.require("./Staff.sol");
var UserContract = {},
	StaffContract = {},
	ActionContract = {};

contract('Action', function(accounts){
	var adduserPermission,
		roleAssignPermission,
		role,
		registry;


	before("Setup the contract",function(done){
		UserContract.owner = accounts[0];
		StaffContract.owner = accounts[1]
		ActionContract.owner = accounts[2];
		adduserPermission = '0xca02b2202ffaacbd499438ef6d594a48f7a7631b60405ec8f30a0d7c096d54d5';
		role = '0xca02b2202ffaacbd4923438ef6d594a48f7a7631b60405ec8f30a0d7c096d54d5';
		roleAssignPermission = 'sdfsf342';

		Action.new({from:ActionContract.owner})
		.then(function(data){
			ActionContract.address = data.address;
			registry = data;
		})
		.then(function(aa){
			User.new(ActionContract.address,accounts[0],{from:UserContract.owner})
			.then(function(user){
				UserContract.address = user.address;
				assert.isOk(user,"new user failed");
			})
		})
		.then(function(bb){

			Staff.new(ActionContract.address,accounts[0],{from:StaffContract.owner})
			.then(function(staff){
				StaffContract.address = staff.address;
				assert.isOk(staff,"new staff failed");
			})
		}).then(done).catch(done);

		return registry,adduserPermission,role, roleAssignPermission;
		//return ActionContractOwner, adduserPermission,registry;
	});

	describe("Action Contract test", function(){

		//assert.isEqual(staff.actionContract,ActionContract.address)

		it("add permission",function(){
			return registry.assignPermissionRequire("addUser",adduserPermission,{from: ActionContract.owner})
			.then(function(response){
				assert.isOk(response,"add permission failed");
			});
		});
			

		it("add user",function(){
			return registry.addUser(UserContract.owner,UserContract.address,{from:ActionContract.owner})
			.then(function(response){
				assert.isOk(response,"add User failed");
			});
		});

		it("add staff",function(){
			return registry.addStaff(StaffContract.owner,StaffContract.address,{from:ActionContract.owner})
			.then(function(response){
				assert.isOk(response,"add staff failed");
			})
		})


		it ("break the glass", function(){
			return Action.at(ActionContract.address).breakTheGlass(UserContract.owner,{from:ActionContract.owner})
			.then(function(response){

			})
		})

		it ("roleAssign", function(){
			return registry.roleAssign(StaffContract.owner,role,{from:ActionContract.owner})
			.then(function(response){
				//System.out.println(response);
				//assert.equal(response.valueOf(),ActionContract.address,"role assignment failed");
			})
		})

	});

});


