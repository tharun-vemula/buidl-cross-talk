const hre = require("hardhat");

const main = async() => {
    const [deployer, addr1] = await hre.ethers.getSigners();
    let accountBalance = await deployer.getBalance();
    console.log("Deploying accounts with:", deployer.address);
    console.log("Current balance:", accountBalance.toString());

    let arr = ["0x9B449D1069f84B044cF11c8b91290025111a88c5"];
    const MyContract = await hre.ethers.getContractFactory("Institute");
    const myContract = await MyContract.deploy(arr);
    await myContract.deployed();
    
    console.log("Contract deployed to address:", myContract.address);

    accountBalance = await deployer.getBalance();
    console.log("Current balance:", accountBalance.toString());

    let txn = await myContract.safeMint(deployer.address, "first NFT");
    await txn.wait();
    console.log("NFT has been minted to %s", deployer.address);

    accountBalance = await deployer.getBalance();
    console.log("Current balance:", accountBalance.toString());

    txn = await myContract.approveStudent(addr1.address);
    console.log("%s has been approved", addr1.address);

    // This following code (below) isn't made asynchronous
    // since it is dependent on the approveStudent (above)
    txn = myContract.connect(addr1).safeMint(addr1.address, "second NFT");
    console.log("NFT has been minted to %s", addr1.address);

    accountBalance = await deployer.getBalance();
    console.log("Current balance:", accountBalance.toString());
}

const runMain = async() => {
    try {
        await main();
        process.exit(0);
    } catch(error) {
        console.log(error);
        process.exit(1);
    }
}

runMain();