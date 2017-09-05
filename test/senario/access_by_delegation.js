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
		role;

	before("Set up accounts", function(){
		user.Account = accounts[0];
		staff1.Account = accounts[1];
		staff2.Account = accounts[2];
		action.Account = accounts[2];
		admin.Account = accounts[1];
		role = "role1";

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

		it("Staff 2", function(){
			return Staff.new(action.address,admin.address,{from:staff1.Account})
			.then(function(staff22){
				console.log("staff 2 contract address:");
				console.log(staff22.address);
				staff2.address = staff22.address;
			})
		})


		it("connect Staff 1 to action contract", function(){
			return Action.at(action.address).addStaff(staff1.Account,staff1.address,{from:action.Account})
			.then(function(response){
					assert.isOk(response, "add staff 1 failed");
			})
		})

		it("connect Staff 2 to action contract", function(){
			return Action.at(action.address).addStaff(staff2.Account,staff2.address,{from:action.Account})
			.then(function(response){
					assert.isOk(response, "add staff 2 failed");
			})
		})

		it("assign role 1 delegation permission by admin contract", function(){
			return Admin.at(admin.address).changeRolePermission(role,"delegation",2,{from:admin.Account})
			.then(function(response){
				assert.isOk(response, "give role1 delegation permission failed");
			})
		})

		it("give delegable access permission to staff 1 by user", function(){
			return userContract.changeAccessPermissionState(staff1.Account, 2, {from:user.Account})
			.then(function(response){
				assert.isOk(response, "change access permission failed");
			})
		})

		it("access the data by staff 1", function(){
			return userContract.accessData({from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "access data failed");
			})
		})

		it("delegate staff 2 with user's access permission by staff 1",function(){
			return Action.at(action.address).delegate_access(user.Account,staff2.Account,{from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "delegate staff 2 with user's access permission failed");
			}).catch(function(error){
				assert.equal(error,"Error: VM Exception while processing transaction: invalid opcode");
				console.log('Catch error, delegation requirement not satisfied'.red);
			})
		})

		it("assign role 1 to staff 1 by action contract", function(){
			return Action.at(action.address).roleAssign(staff1.Account,role,{from:action.Account})
			.then(function(response){
				assert.isOk(response, "give role1 delegation permission failed");
			})
		})

		it("delegate staff 2 with user's access permission by staff 1",function(){
			return Action.at(action.address).delegate_access(user.Account,staff2.Account,{from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "delegate staff 2 with user's access permission failed");
			}).catch(function(error){
				assert.equal(error,"Error: VM Exception while processing transaction: invalid opcode");
				console.log("Catch error, delegation requirement not satisfied".red);
			})
		})

		it("add user to action contract", function(){
			return Action.at(action.address).addUser(user.Account,user.address,{from:action.Account})
			.then(function(response){
					assert.isOk(response, "add user failed");
			})
		})

		it("access the data by staff 2", function(){
			return userContract.accessData({from:staff2.Account})
			.then(function(response){
				assert.isOk(response, "access data failed");
			}).catch(function(error){
				assert.equal(error,"AssertionError: access data failed: expected false to be truthy");
				console.log("Catch error, can not access".red);
			})
		})

		it("delegate staff 2 with user's access permission by staff1",function(){
			return Action.at(action.address).delegate_access(user.Account,staff2.Account,{from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "delegate staff 2 with user's access permission failed");
			})
		})

		it("access the data by staff 2", function(){
			return userContract.accessData({from:staff2.Account})
			.then(function(response){
				assert.isOk(response, "access data failed");
			})
		})

		it("revoke access permission of staff 2 by staff 1",function(){
			return userContract.revokeDelegation(staff2.Account,{from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "revoke access permission failed");
			})
		})

		it("access the data by staff 2", function(){
			return userContract.accessData({from:staff2.Account})
			.then(function(response){
				assert.isOk(response, "access data failed");
			}).catch(function(error){
				assert.equal(error,"AssertionError: access data failed: expected false to be truthy");
				console.log("Catch error, can not access".red);
			})
		})

	})
})