var Action = artifacts.require("./Action.sol");
var User = artifacts.require("./User.sol");
var UserContract = {},
	ActionContract = {};

contract('Action', function(accounts){
	var adduserPermission,
		registry;


	before("Setup the contract",function(done){
		ActionContract.owner = accounts[1];
		UserContract.owner = accounts[0];
		adduserPermission = '0xca02b2202ffaacbd499438ef6d594a48f7a7631b60405ec8f30a0d7c096d54d5';

		Action.new({from:ActionContract.owner})
		.then(function(data){
			ActionContract.address = data.address;
			registry = data;
			done();
		});

		return registry,ActionContract,UserContract;
		//return ActionContractOwner, adduserPermission,registry;
	});

	describe("Action Contract test", function(){

		it("add permission",function(){
			return registry.assignPermissionRequire("addUser",adduserPermission,{from: ActionContract.owner})
			.then(function(response){
				assert.isOk(response,"add permission failed");
			});
		});

		it("new user",function(){
			return User.new(ActionContract.address,accounts[0],{from:UserContract.owner})
			.then(function(data){
				UserContract.address = data.address;
				assert.isOk(data,"new user failed");
			})
		});
			

		it("add user",function(){
			return registry.addUser(UserContract.owner,UserContract.address,{from:ActionContract.owner})
			.then(function(response){
				assert.isOk(response,"add User failed");
			});
		});

	});

});

/*contract('User',function(accounts){
	before("Setup",function(){
		UserContract.owner = accounts[0];
		return UserContract;
	});

	describe("User contract",function(){
		it("new user",function(){
			return User.new(ActionContract.address,accounts[0],{from:UserContract.owner})
			.then(function(data){
				UserContract.address = data.address;
				assert.isOk(data,"new user failed");
			})
		});
	});
})*/

