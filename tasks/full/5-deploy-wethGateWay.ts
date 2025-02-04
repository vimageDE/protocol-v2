import { task } from 'hardhat/config';
import {
  loadPoolConfig,
  ConfigNames,
  getWrappedNativeTokenAddress,
} from '../../helpers/configuration';
import { deployWETHGateway } from '../../helpers/contracts-deployments';
import { getFeeContract } from '../../helpers/contracts-getters';

const CONTRACT_NAME = 'WETHGateway';

task(`full-deploy-weth-gateway`, `Deploys the ${CONTRACT_NAME} contract`)
  .addParam('pool', `Pool name to retrieve configuration, supported: ${Object.values(ConfigNames)}`)
  .addFlag('verify', `Verify ${CONTRACT_NAME} contract via Etherscan API.`)
  .setAction(async ({ verify, pool }, localBRE) => {
    await localBRE.run('set-DRE');
    const poolConfig = loadPoolConfig(pool);
    const Weth = await getWrappedNativeTokenAddress(poolConfig);
    const feeContract = await getFeeContract();

    if (!localBRE.network.config.chainId) {
      throw new Error('INVALID_CHAIN_ID');
    }
    const wethGateWay = await deployWETHGateway([Weth, feeContract.address], verify);
    console.log(`${CONTRACT_NAME}.address`, wethGateWay.address);
    console.log(`\tFinished ${CONTRACT_NAME} deployment`);
  });
