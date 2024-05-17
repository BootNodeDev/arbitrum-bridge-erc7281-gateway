# Arbitrum bridge XERC20

This repo contains a set of smart contracts meant for enabling XERC20 token bridging through the Arbitrum canonical bridge,
using two different approaches:

## An ERC20 token on Ethereum with an XERC20 counterpart token on Arbitrum

An example use case for this approach would be ezETH. ezETH is an
[ERC20](https://etherscan.io/token/0xbf5495Efe5DB9ce00f80364C8B423567e58d2110) on L1 with an
[XERC20](https://etherscan.io/address/0x2416092f143378750bb29b79ed961ab195cceea5) representation on both L1 and L2. In
order for Renzo to enable bridging the ezETH token it would need to:

1. Deploy both `L1LockboxGateway` and `L1LockboxGateway`
2. Set the previously deployed `L1LockboxGateway` as a `bridge` on the
   [XERC20 ezETH](https://etherscan.io/address/0x2416092f143378750bb29b79ed961ab195cceea5)
3. Make a proposal to Arbitrum DAO for registering the
   [ezETH](https://etherscan.io/token/0xbf5495Efe5DB9ce00f80364C8B423567e58d2110) on Arbitrum's router to be used with
   the `L1LockboxGateway`, which should include:
   - Registering the [ezETH](https://etherscan.io/token/0xbf5495Efe5DB9ce00f80364C8B423567e58d2110) on the router
   - Remove from UI block-list
   - Add [L2 ezETH](https://arbiscan.io/address/0x2416092f143378750bb29b79ed961ab195cceea5) to
     [L2ApprovalUtils](https://github.com/OffchainLabs/arbitrum-token-bridge/blob/master/packages/arb-token-bridge-ui/src/util/L2ApprovalUtils.ts)

![ERC20<>XERC20](/docs/Arbitrum2.png)

## An XERC20 token on Ethereum with a XERC20 counterpart token on Arbitrum

There are a few prerequisites to keep in mind for registering a token in the router associating it to a specific
gateway.

First of all, the L1 counterpart of the token must conform to the ICustomToken interface. This means that:

- It must have a isArbitrumEnabled method that returns 0xb1
- It must have a method that makes an external call to L1CustomGateway.registerCustomL2Token specifying the address of
  the L2 contract, and to L1GatewayRouter.setGateway specifying the address of the custom gateway. These calls should be
  made only once to configure the gateway.

These methods are needed to register the token via the gateway contract. If the L1 contract does not include these
methods and it is not upgradeable, registration could alternatively be performed in one of these ways:

- As a chain-owner registration via an Arbitrum DAO proposal.
- By wrapping your L1 token and registering the wrapped version of your token.

This approach uses an Adapter contract which is used for being able to permissionlessly register a non Arbitrum compatible
token on the Arbitrum Router to be used with a Custom Gateway

In order to be able to use this approach it would be required to:

**UI**

- BootNode's UI PR to be merged (TODO add PR link)

**Anyone**

- Deploy both `L1XERC20Gateway` and `L1XERC20Gateway`

**XERC20 Token Issuer**

1. Deploy an `L1XERC20Adapter` if the XERC20 token
2. Call the `registerTokenOnL2` function on the deployed `L1XERC20Adapter`
3. Set the deployed `L1XERC20Adapter` as a `bridge` on the XERC20 token
4. Make a PR to [Arbitrum's UI repository](https://github.com/OffchainLabs/arbitrum-token-bridge) adding the L2 XERC20
   token to
   [L2ApprovalUtils](https://github.com/OffchainLabs/arbitrum-token-bridge/blob/master/packages/arb-token-bridge-ui/src/util/L2ApprovalUtils.ts)

![XERC20<>XERC20](/docs/Arbitrum1.png)

## Installing Dependencies

Foundry typically uses git submodules to manage dependencies, but this template uses Node.js packages because
[submodules don't scale](https://twitter.com/PaulRBerg/status/1736695487057531328).

This is how to install dependencies:

1. Install the dependency using your preferred package manager, e.g. `bun install dependency-name`
   - Use this syntax to install from GitHub: `bun install github:username/repo-name`
2. Add a remapping for the dependency in [remappings.txt](./remappings.txt), e.g.
   `dependency-name=node_modules/dependency-name`

Note that OpenZeppelin Contracts is pre-installed, so you can follow that as an example.

## Deployment Scripts

Deployment script documentation can be found [here](./docs/deployment.md).

## Usage

This is a list of the most frequently needed commands.

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Coverage

Get a test coverage report:

```sh
$ forge coverage
```

### Format

Format the contracts:

```sh
$ forge fmt
```

### Gas Usage

Get a gas report:

```sh
$ forge test --gas-report
```

### Lint

Lint the contracts:

```sh
$ bun run lint
```

### Test

Run the tests:

```sh
$ forge test
```

Generate test coverage and output result to the terminal:

```sh
$ bun run test:coverage
```

Generate test coverage with lcov report (you'll have to open the `./coverage/index.html` file in your browser, to do so
simply copy paste the path):

```sh
$ bun run test:coverage:report
```

## License

This project is licensed under MIT.
