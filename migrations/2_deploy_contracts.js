var Admin = artifacts.require("./Admin.sol");
var Action = artifacts.require("./Action.sol");
var User = artifacts.require("./User.sol");
var Staff = artifacts.require("./Staff.sol");

module.exports = function(deployer) {
  deployer.deploy(Admin);
  deployer.deploy(User);
  deployer.link(User, Staff);
  deployer.deploy(Staff);
  deployer.link(Staff,Action);
  deploy.deploy(Action);
};
