var User = artifacts.require("./User.sol");
var Staff = artifacts.require("./Staff.sol");
var Action = artifacts.require("./Action.sol");
var Admin = artifacts.require("./Admin.sol");

contract('Delegation', function(accounts){
	var user = {},
		staff1 = {},
		staff2 = {},
		action = {},
		admin = {},
		userContract,
		adminContract,
		actionContract,
		role,
		sig,
		ret = {};

	before("Set up accounts", function(){
		user.Account = accounts[0];
		staff1.Account = accounts[1];
		staff2.Account = accounts[2];
		action.Account = accounts[2];
		admin.Account = accounts[1];
		role = "role1";

		sig = secp256k1.sign("msgHash", privateKey)
 		ret.r = sig.signature.slice(0, 32)
  		ret.s = sig.signature.slice(32, 64)
  		ret.v = sig.recovery + 27

		return user, staff1, staff2, action, admin, role;

	})

	describe("Access by delegation", function(){

		it("Action",function(){
			return Action.new({from:action.Account})
			.then(function(data){
				action.address = data.address;
				console.log("action contract address:");
				console.log(data.address);
			})
		})

		it("Admin",function(){
			return Admin.new(action.address,{from:admin.Account})
			.then(function(adminn){
				admin.address = adminn.address;
				adminContract = adminn;
				console.log("admin contract address:");
				console.log(adminn.address);
			})
		})


		it("user",function(){
			return User.new(action.address,admin.address,{from:user.Account})
			.then(function(userr){
				userContract = userr;
				console.log("user contract address:");
				console.log(userr.address);
				user.address = userr.address;
			})
		})

		it("Staff 1", function(){
			return Staff.new(action.address,admin.address,{from:staff1.Account})
			.then(function(staff11){
				console.log("staff 1 contract address:");
				console.log(staff11.address);
				staff1.address = staff11.address;
			})
		})

		it("connect Staff 1 to action contract", function(){
			return Action.at(action.address).addStaff(staff1.Account,staff1.address,{from:action.Account})
			.then(function(response){
					assert.isOk(response, "add staff 1 failed");
			})
		})

		it("assign role 1 break-the-glass permission by admin contract", function(){
			return Admin.at(admin.address).changeRolePermission(role,"breakTheGlass",2,{from:admin.Account})
			.then(function(response){
				assert.isOk(response, "give role1 delegation permission failed");
			})
		})


		it("assign role 1 to staff 1 by action contract", function(){
			return Action.at(action.address).roleAssign(staff1.Account,role,{from:action.Account})
			.then(function(response){
				assert.isOk(response, "give role1 delegation permission failed");
			})
		})

		it("break-the-glass by staff 1",function(){
			return Action.at(action.address).breakTheGlass(user.Account,{from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "break the glass failed");
			})
		})


		it("add user to action contract", function(){
			return Action.at(action.address).addUser(user.Account,user.address,{from:action.Account})
			.then(function(response){
					assert.isOk(response, "add user failed");
			})
		})

		it("break-the-glass by staff 1",function(){
			return Action.at(action.address).breakTheGlass(user.Account,{from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "break the glass failed");
			})
		})
	})
})