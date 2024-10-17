/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

 const HDWalletProvider = require('@truffle/hdwallet-provider');
 //
 // const fs = require('fs');
 const { privateKeyTestnet, privateKeyMainnet, BSCSCANAPIKEY} = require('./env.json');

 
 module.exports = {
   plugins: [
     'truffle-plugin-verify'
   ],
   api_keys: {
     arbiscan: BSCSCANAPIKEY
   },
   networks: {
     bscTestnet: {
       provider: () => new HDWalletProvider(privateKeyTestnet, `https://goerli-rollup.arbitrum.io/rpc`),
       network_id: 421613,
       confirmations: 2,
     },
     bsc: {
       provider: () => new HDWalletProvider(privateKeyMainnet, `https://bsc-dataseed1.binance.org/`),
       network_id: 56,
       confirmations: 10,
       timeoutBlocks: 20000,
       skipDryRun: true,
       networkCheckTimeout: 1000000
     },
   },
   mocha: {
     timeout: 1000000
   },
   compilers: {
     solc: {
       version: "0.8.7",
       settings: {          // See the solidity docs for advice about optimization and evmVersion
         optimizer: {
           enabled: true,
           runs: 200
         },
         //evmVersion: "byzantium"
        }
     }
   }
 };
 