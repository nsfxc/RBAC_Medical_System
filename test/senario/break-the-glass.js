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
		ret = {},
		foo,r,s,v;

	before("Set up accounts", function(){
		user.Account = accounts[0];
		staff1.Account = accounts[1];
		staff2.Account = accounts[2];
		action.Account = accounts[2];
		admin.Account = accounts[1];
		role = "role1";

		var message = web3.sha3('Woman on the street with trouble breathing');
		foo = web3.eth.sign(staff1.Account,message);
 		r = '0x' + foo.slice(0, 64)
 		s = '0x' + foo.slice(64, 128)
		v = '0x' + foo.slice(128, 130)
		v = web3.toDecimal(v)
		console.log("Signature: value of r " + r);
		console.log("value of v " + v);
		console.log("value of s " + s);
		console.log("Signed message: Woman on the street with trouble breathing")

		//console.log(r+" "+s+' '+v);
		console.log(" ");

		return user, staff1, staff2, action, admin, role;

	})

	describe("Access by break-the-glass", function(){

		it("Action",function(){
			return Action.new({from:action.Account})
			.then(function(data){
				action.address = data.address;
				console.log("action contract address: " + data.address);
			})
		})

		it("Admin",function(){
			return Admin.new(action.address,{from:admin.Account})
			.then(function(adminn){
				admin.address = adminn.address;
				adminContract = adminn;
				console.log("admin contract address: " + adminn.address);
			})
		})


		it("user",function(){
			return User.new(action.address,admin.address,{from:user.Account})
			.then(function(userr){
				userContract = userr;
				console.log("user contract address: " + userr.address);
				user.address = userr.address;
			}).then(function(sdf){
				Action.at(action.address).addUser(user.Account,user.address,{from:action.Account})
				.then(function(response){
					assert.isOk(response, "add user failed");
				});
			})
		})

		it("Staff 1", function(){
			return Staff.new(action.address,admin.address,{from:staff1.Account})
			.then(function(staff11){
				console.log("staff 1 contract address: " + staff11.address);
				staff1.address = staff11.address;
			}).then(function(responsse){
				Action.at(action.address).addStaff(staff1.Account,staff1.address,{from:action.Account})
					.then(function(response){
					assert.isOk(response, "add staff 1 failed");
			})
			})
		})

		it("assign role 1 break-the-glass permission by admin contract", function(){
			return Admin.at(admin.address).changeRolePermission(role,"breakTheGlass",2,{from:admin.Account})
			.then(function(response){
				assert.isOk(response, "give role1 delegation permission failed");
			})
		})

		it("break-the-glass by staff 1",function(){
			return Action.at(action.address).breakTheGlass(user.Account/*,foo,v,r,s,*/,{from:staff1.Account})
			.then(function(response){
				assert.isOk(response, "break the glass failed");
			}).catch(function(error){
				assert.equal(error,"Error: VM Exception while processing transaction: invalid opcode");
				console.log("Catch error, break-the-glass requirements not satisfied".red);
				throw(error);
			})
		})


		it("assign role 1 to staff 1 by action contract", function(){
			return Action.at(action.address).roleAssign(staff1.Account,role,{from:action.Account})
			.then(function(response){
				assert.isOk(response, "give role1 delegation permission failed");
			})
		})

		it("break-the-glass by staff 1",function(){
			return Action.at(action.address).breakTheGlass(user.Account,foo,v,r,s,{from:user.Account})
			.then(function(response){
				assert.isOk(response, "break the glass failed");
			}).catch(function(error){
				assert.equal(error,"Error: VM Exception while processing transaction: invalid opcode");
				console.log("Catch error, signature not right".red);
				throw(error);
			})
		})

	})
})