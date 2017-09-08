var User = artifacts.require("./User.sol");
var Staff = artifacts.require("./Staff.sol");



contract('User', function(accounts){
	var user = {},
		staff1 = {},
		staff2 = {};

	before("Set up contracts", function(done){
		user.Account = accounts[0];
		staff1.Account = accounts[1];
		staff2.Account = accounts[2];

		User.new(accounts[1],accounts[2],{from:user.Account})
		.then(function(user){
			userContract = user;
			console.log("user contract address:");
			console.log(user.address);
			console.log(" ");
		}).then(done);

	})

	describe("Regular access of user's data", function(){

		it("Staff 1", function(){
			return Staff.new(accounts[1],accounts[2],{from:staff1.Account})
			.then(function(staff1){
				console.log("staff 1 contract address:");
				console.log(staff1.address);
				console.log(" ");
			})
		})

		it("Staff 2", function(){
			return Staff.new(accounts[1],accounts[2],{from:staff1.Account})
			.then(function(staff1){
				console.log("staff 2 contract address:");
				console.log(staff1.address);
				console.log(" ");
			})
		})

		it("give delegable access permission to staff 1 by the user", function(){
			return userContract.changeAccessPermissionState(staff1.Account,2, {from:user.Account})
			.then(function(response){
				assert.isOk(response, "change access permission failed");
			})
		})

		it("access user's data by staff 1", function(){
			return userContract.accessData({from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "access data failed");
				console.log("Catch access notification");
			})
		})

		it("access user's data by staff 2", function(){
			return userContract.accessData({from:staff2.Account})
			.then(function(response){
				assert.isOk(response, "access data failed");
			}).catch(function(error){
				console.log("Catch error, can not access".red);
				throw error;
			})
		})

		it("remove the access permission of staff 1", function(){
			return userContract.changeAccessPermissionState(staff1.Account, 0, {from:user.Account})
			.then(function(response){
				assert.isOk(response, "add blacklist failed");
			})
		})

		it("access the data by staff 1", function(){
			return userContract.accessData({from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "access data failed");
			}).catch(function(error){
				console.log("Catch error, can not access".red);
				throw error;
			})
		})

		it("give access permission to staff 1 called by staff 1", function(){
			return userContract.changeAccessPermissionState(staff1.Account,1,{from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "change access permission failed");
			}).catch(function(error){
				console.log("Catch error, can not change access permission".red);
				throw error;
			})
		})
	})
})