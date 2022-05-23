from hmac import digest
from lib2to3.pgen2 import token
import pytest
import hashlib
from brownie import htlcBridge, accounts

@pytest.fixture(scope='module')
def deployedContract():
    return htlcBridge.deploy({'from':accounts[0]})

class TestHashing:
    @pytest.mark.parametrize("sender,receiver,tokenContract,amount", [
        ('0xF9aa31e735E50Ef92d332905aB1f00E12e0e16D9','0xF9aa31e735E50Ef92d332905aB1f00E12e0e16D9','0x7Ae6c1FC4A79129F868f9595fec1A54Ff89FF1D2','5')
    ])
    def test_commitment(self, sender,receiver,tokenContract,amount, deployedContract):
        node1 = hashlib.sha256()
        node1.update(hashlib.sha256(sender.encode()).hexdigest().encode())
        node1.update(hashlib.sha256(receiver.encode()).hexdigest().encode())
        node2 = hashlib.sha256()
        node2.update(hashlib.sha256(tokenContract.encode()).hexdigest().encode())
        node2.update(hashlib.sha256(amount.encode()).hexdigest().encode())
        hash = hashlib.sha256()
        hash.update(node1.hexdigest().encode())
        hash.update(node2.hexdigest().encode())
        assert deployedContract.getCommitment(sender, receiver, tokenContract, int(amount)) == '0x'+hash.hexdigest()

    def test_hash_function(self, deployedContract):
        assert deployedContract.hashThis(b'prueba') == '0x'+hashlib.sha256(b'prueba').hexdigest()