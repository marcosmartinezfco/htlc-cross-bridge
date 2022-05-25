from brownie import Token, accounts, network, config, htlcBridge

def main():
    dev = accounts.add(config['wallets']['from_key'])

    network.connect('ropsten-alchemy')
    print('Network -- '+network.show_active())
    print('Balance -- '+dev.balance())
    ropsten = htlcBridge.deploy({'from':dev})
    print('Contract Address -- '+ropsten.address())
    tokenRopsten = Token.deploy("Ropsten Token Bridge", "RTB", 18, 1e18, {'from':dev})
    tokenRopsten.transfer(dev, 18000, {'from':dev})
    network.disconnect()

    network.connect('rinkeby-alchemy')
    print('Network -- '+network.show_active())
    print('Balance -- '+dev.balance())
    rinkeby = htlcBridge.deploy({'from':dev})
    print('Contract Address -- '+rinkeby.address())
    tokenRinkeby = Token.deploy("Rinkeby Token Bridge", "RTB", 18, 1e18, {'from':dev})
    tokenRinkeby.transfer(dev, 18000, {'from':dev})