var medicalRecord = artifacts.require("./medicalRecord.sol");

contract('medicalRecord', function(accounts){
	var contractOwner,
		staff1,
		permission1hash,
		registry;


	before("Setup the contract",function(done){
		contractOwner = accounts[0];
		staff1 = accounts[1];
		permission1hash = '0xca02b2202ffaacbd499438ef6d594a48f7a7631b60405ec8f30a0d7c096d54d5';

		medicalRecord.new({from:contractOwner})
		.then(function(data){
			registry = data;
			done();
		});

		return staff1, contractOwner, permission1hash,registry;
	});

	describe("medicalRecord Contract test", function(){

		it("add permission",function(){
			return registry.addPermission(permission1hash,{from: contractOwner})
			.then(function(response){
				assert.isOk(response,"add permission failed");
			});
		});

		it("modify add staff requirement",function(){
			return registry.modify_add_staff_req(true, 10, permission1hash, {from: contractOwner})
			.then(function(response){
				assert.isOk(response, "modify add staff permission failed");
			})
		});

		it("add a new staff",function(){
			return registry.add_staff(staff1, {from: contractOwner})
			.then(function(response){
				assert.isOk(response,"add new staff succeed");
			})
		});

		it("change staff1's admin level, give he the permission and revoke the permission",function(){
			return registry.change_admin_level(staff1,11,{from: contractOwner})
			.then(function(changeAdmin){
				assert.isOk(changeAdmin,"chenge staff1's admin level failed");
				return registry.delegate(staff1,permission1hash,{from: contractOwner})
			.then(function(givePermission){
				assert.isOk(givePermission,"give staff1 the permission of add staff failed");
				return registry.revoke_permission(staff1,permission1hash,{from:contractOwner})
			.then(function(revokePermission){
				assert.isOk(revokePermission,"revoke permission succeed");
					})
				})
			})
		});

	});


});