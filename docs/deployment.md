# Deployment Guide

- Run `bun install` to install all the dependencies
- Create a `.env` file base on the [.env.example file](../.env.example) file, and set the required variables depending which script you are going to run.

Set the following environment variables required for running all the scripts, on each network.

- `ETH_RPC_URL`
- `ARBITRUM_RPC_URL`
- `SEPOLIA_RPC_URL`
- `ARBITRUM_SEPOLIA_RPC_URL`
- `ETHERSCAN_API_KEY`
- `ARBISCAN_API_KEY`

Make sure everything is setup properly by running the following scripts removing the  `--broadcast --verify`. This will only simulate the deployment.

### Gateways

Both gateways are deployed using a `CREATE3Factory` in order to make their addresses equal in both L1 and L2 networks. Make sure to use the same `CREATE3_FACTORY`, `GATEWAY_SALT` and `DEPLOYER_PK` values for running both scripts.

Notice that the values used for `GATEWAY_SALT` can be used only once on each network.

**L1XER20Gateway**
Required environment variables:

- `GATEWAY_SALT`: Salt used for deploying the contract through `CREATE3Factory`. **IMPORTANT:** make sure to use the same address for `L2EXERC20Gateway`
- `DEPLOYER_PK`: Your deployer address private key. **IMPORTANT:** make sure to use the same address for `L2EXERC20Gateway`
- `CREATE3_FACTORY`: Address of the `CREATE3Factory`. **IMPORTANT:** make sure to use the same address for `L2EXERC20Gateway`
- `L1_GATEWAY_OWNER`: Gateway's owner address
- `L1_ARBITRUM_ROUTER`: Use `0xcE18836b233C83325Cc8848CA4487e94C6288264` for deploying on Sepolia
- `L1_ARBITRUM_INBOX`: Use `0xaAe29B0366299461418F5324a79Afc425BE5ae21` for deploying on Sepolia
-

Sepolia
```sh
$ yarn deploy:gateway:sepolia
```

Ethereum Mainnet
```sh
$ yarn deploy:gateway
```

**L2XER20Gateway**
Required environment variables:

- `GATEWAY_SALT`: Salt used for deploying the contract through `CREATE3Factory`. **IMPORTANT:** make sure to use the same address for `L1EXERC20Gateway`
- `DEPLOYER_PK`: Your deployer address private key. **IMPORTANT:** make sure to use the same address for `L1EXERC20Gateway`
- `CREATE3_FACTORY`: Address of the `CREATE3Factory`. **IMPORTANT:** make sure to use the same address for `L1EXERC20Gateway`
- `L1_GATEWAY`: Address resulting from running `deploy:gateway:sepolia`
- `L2_ARBITRUM_ROUTER`: Use `0xcE18836b233C83325Cc8848CA4487e94C6288264` for deploying on Arbitrum Sepolia

Arbitrum Sepolia
```sh
$ yarn deploy:gateway:arb:sepolia
```

Arbitrum One
```sh
$ yarn deploy:gateway:arb
```

### XERC20 and Adapter

**XERC20**

The XER20 token is deployed using a `XERC20Factory` contract. In order to have the token deployed on the same address on both networks you must to use the same `DEPLOYER_PK`, `XERC20_FACTORY`, `XERC20_NAME` and `XERC20_SYMBOL` values for running bot scripts.

Required environment variables:

- `DEPLOYER_PK`: Your deployer address private key. **IMPORTANT:** make sure to use the same address for `XERC20 L2`
- `XERC20_FACTORY`: The address of the `XERC20Factory`. **IMPORTANT:** make sure to use the same address for `XERC20 L2`
- `XERC20_NAME`: The token name
- `XERC20_SYMBOL`: The token symbol
- `XERC20_BURN_MINT_LIMITS`: **OPTIONAL** Burn and mint limits separated by `,` to use for each bridge
- `XERC20_BRIDGES`: **OPTIONAL** Address of bridges separated by `,`

Sepolia
```sh
$ yarn deploy:token:sepolia
```

Arbitrum Sepolia
```sh
$ yarn deploy:token:arb:sepolia
```

Ethereum Mainnet
```sh
$ yarn deploy:token:sepolia
```

Arbitrum One
```sh
$ yarn deploy:token:arb:sepolia
```

**Adapters**

Both adapters are deployed using a `CREATE3Factory` in order to make their addresses equal in both L1 and L2 networks. Make sure to use the same `CREATE3_FACTORY`, `ADAPTER_SALT` and `DEPLOYER_PK` values for running both scripts.

Notice that the values used for `ADAPTER_SALT` can be used only once on each network.

**L1XER20Adapter**

Required environment variables:

- `ADAPTER_SALT`: Salt used for deploying the contract through `CREATE3Factory`. **IMPORTANT:** make sure to use the same address for `L2EXERC20Adapter`
- `DEPLOYER_PK`: Your deployer address private key. **IMPORTANT:** make sure to use the same address for `L2EXERC20Adapter`
- `CREATE3_FACTORY`: Address of the `CREATE3Factory`. **IMPORTANT:** make sure to use the same address for `L2EXERC20Adapter`
- `L1_ADAPTER_OWNER`: Adapter's owner address
- `L1_XERC20`: The XERC20 address this adapter is being deployed for
- `L1_GATEWAY`: Address resulting from running `deploy:gateway:sepolia`

Sepolia
```sh
$ yarn deploy:adapter:sepolia
```

Ethereum Mainnet
```sh
$ yarn deploy:adapter
```

**L2XER20Adapter**

Required environment variables:

- `ADAPTER_SALT`: Salt used for deploying the contract through `CREATE3Factory`. **IMPORTANT:** make sure to use the same address for `L1EXERC20Adapter`
- `DEPLOYER_PK`: Your deployer address private key. **IMPORTANT:** make sure to use the same address for `L1EXERC20Adapter`
- `CREATE3_FACTORY`: Address of the `CREATE3Factory`. **IMPORTANT:** make sure to use the same address for `L1EXERC20Adapter`
- `L2_ADAPTER_OWNER`: Adapter's owner address
- `L2_XERC20`: The XERC20 address this adapter is being deployed for
- `L2_GATEWAY`: Address resulting from running `deploy:gateway:arb:sepolia`

Arbitrum Sepolia
```sh
$ yarn deploy:adapter:arb:sepolia
```

Arbitrum One
```sh
$ yarn deploy:adapter:arb
```

### Register the XERC20/Adapter on the Arbitrum Router and on L2

This step is required in order to:
- Set the relation between the adapter and gateway within the router
- Register the token on L2 gateway

Required environment variables:

- `L1_ADAPTER_OWNER_PK`: Owner of `L1XERC20Adapter` address private key
- `SEND_VALUE`: Total amount of ETH to send for payment
- `L1_ADAPTER`: Address `L1XERC20Adapter`
- `L2_ADAPTER`: Address `L2XERC20Adapter`
- `MAX_SUBMISSION_COST_FOR_GATEWAY`: Base submission cost L2 retryable tick3et for gateway
- `MAX_SUBMISSION_COST_FOR_ROUTER`: Base submission cost L2 retryable tick3et for router
- `MAX_GAS_FOR_GATEWAY`: Max gas for L2 retryable exrecution for gateway message
- `MAX_GAS_FOR_ROUTER`: Max gas for L2 retryable exrecution for router message
- `GAS_PRICE_BID`: Gas price for L2 retryable ticket
- `VALUE_FOR_GATEWAY`: ETH value to transfer to the gateway
- `VALUE_FOR_ROUTER`: ETH value to transfer to the gateway

Sepolia
```sh
$ yarn run:register:sepolia
```

Ethereum Mainnet
```sh
$ yarn run:register
```
