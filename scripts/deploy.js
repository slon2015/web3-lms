async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const assignment = await ethers.getContractFactory("Assignment"); //Replace with name of smart contract
  const Assignment = await assignment.deploy();

  console.log("Assignment:", Assignment.address);
}
// 
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

  //npx hardhat run --network bnbtestnet scripts/deploy.js

  //https://github.com/slon2015/web3-lms.git

  //#1 add a particular files to github
  //git init
  //git add contracts/*
  //git commit -m "Added raw contracts"
  // git remote add origin https://github.com/txorigiononame/5555555.git
  // git branch -M main
  // git push -u origin main


  //#2 To push the contents of the root folder 
  //of your project to a separate folder in a GitHub repository
  //git init
  //git add .
  //git commit -m "initial commit"
  //git remote add origin https://github.com/slon2015/web3-lms.git
  //git push origin master:contracts

  //rm -rf .git
  //ls -a




