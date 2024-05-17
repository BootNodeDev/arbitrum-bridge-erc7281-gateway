# Arbitrum bridge XERC20

This repo contains a set of smart contracts meant for enabling XERC20 token bridging through Arbitrum canonical bridge,
using two different approach:

## An ERC20 token on Ethereum with a XERC20 counterpart token on Arbitrum

An example use case for this approach would be ezETH.

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

This approach uses an Adapter contract which is used for being able permissionless register a non Arbitrum compatible
token on the Arbitrum Router to be used with a Custom Gateway

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
