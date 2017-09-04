var User = artifacts.require("./User.sol");

contract('User', function(accounts){
	var userAdd,
		userContract;

	before("Deploy the user contract", function(done){
		userAdd = accounts[0];
		User.new(accounts[1],accounts[2],{from:userAdd})
		.then(function(user){
			userContract = user;
			console.log(user.address);
		}).then(done);
	});

	describe("Unit test of user contract",function(){
		it("add account 1 as blacklist", function(){
			return userContract.changeBlackList(accounts[1],{from:userAdd})
			.then(function(response){
				assert.isOk(response, "add blacklist failed");
			})
		})


		it("give delegable access permission to account 2", function(){
			return userContract.changeAccessPermissionState(accounts[2],2, {from:userAdd})
			.then(function(response){
				assert.isOk(response, "change access permission failed");
			})
		})

		it("access the data by owner", function(){
			return userContract.accessData({from:userAdd})
			.then(function(response){
				//console.log(response.value);
				assert.isOk(response, "access data failed");
			})
		})

		it("access the data by account 2", function(){
			return userContract.accessData({from:accounts[2]})
			.then(function(response){
				assert.isOk(response, "access data failed");
			})
		})

		it("access the data by account 1", function(){
			return userContract.accessData({from:accounts[1]})
			.then(function(response){
				assert.isOk(response, "access data failed");
			})
		})

		it("remove access permission of account 2", function(){
			return userContract.changeAccessPermissionState(accounts[2],0, {from:userAdd})
			.then(function(response){
				assert.isOk(response, "change access permission failed");
			})
		})

		it("access the data by account 2", function(){
			return userContract.accessData({from:accounts[2]})
			.then(function(response){
				assert.isOk(response, "access data failed");
			})
		})

		it("change action contract to account 2 by action contract", function(){
			return userContract.changeActionContract(accounts[2],{from:accounts[1]})
			.then(function(response){
				assert.isOk(response, "change action contract address failed");
			})
		})

		it("change action contract to account 2 by account 1", function(){
			return userContract.changeActionContract(accounts[2],{from:accounts[1]})
			.then(function(response){
				assert.isOk(response, "change action contract address failed");
			})
		})

		it("change admin contract to account 2 by admin contract", function(){
			return userContract.changeAdminContract(accounts[2],{from:accounts[2]})
			.then(function(response){
				assert.isOk(response, "change action contract address failed");
			})
		})

		it("change action contract to account 2 by account 1", function(){
			return userContract.changeAdminContract(accounts[2],{from:accounts[1]})
			.then(function(response){
				assert.isOk(response, "change action contract address failed");
			})
		})

	})
})
