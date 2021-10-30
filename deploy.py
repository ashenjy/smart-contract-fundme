from eth_utils import address
from solcx import compile_standard, install_solc
import json
from web3 import Web3
import os
from dotenv import load_dotenv

load_dotenv()

install_solc("0.6.0")

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
    # print(simple_storage_file)

# Compile Solidity

compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.6.0",
)

# print(compiled_sol)

with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# deploy the contract

# get bytecode
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]
# print(f"bytecode: {bytecode}")

# get abi
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]
# print(f"abi: {abi}")

# connect to ganache simulated /mock blockchain
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545"))
chain_id = 1337
my_address = "0xcAcd33e6B526Cc7906985B52222C527204C23ACC"
# add 0x in python for private keys
private_key = os.getenv("PRIVATE_KEY")

# create the contract in python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# print(SimpleStorage)

# send the transaction

# get the latest transaction count
nonce = w3.eth.getTransactionCount(my_address)
print(f"nonce: {nonce}")
# build the transaction
transaction = SimpleStorage.constructor().buildTransaction(
    {"chainId": chain_id, "from": my_address, "nonce": nonce}
)
# print(transaction)
print("Deploying Contract...")
# sign the transaction
signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)

# send the transaction
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)

# after sending transaction, code to wait for tx receipt
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

print("Deployed")


# Working with the contract
# 1. Contract Address
# 2. Contract ABI
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
# in a blockchain there's two ways to interact with a transaction
# 1. Call -> simulate making the call and getting a return value.
# 2. Transact -> actually make a state change, need to build and send the tx
# below retrieve, no need to make a state change so call func is used
# calling is just simulation
print(simple_storage.functions.retrieve().call())

# STORE VALUE IN TX
store_tx = simple_storage.functions.store(15).buildTransaction(
    {
        "chainId": chain_id,
        "from": my_address,
        # nonce can only be used once for each transaction, therefore
        # 1 is added since we used nonce previously when building the transaction.
        "nonce": nonce + 1,
    }
)
print("Updating Contract...")

signed_store_tx = w3.eth.account.sign_transaction(store_tx, private_key=private_key)
send_store_tx = w3.eth.send_raw_transaction(signed_store_tx.rawTransaction)
store_tx_receipt = w3.eth.wait_for_transaction_receipt(send_store_tx)

print("Updated")

print(f"retrieve() -> {simple_storage.functions.retrieve().call()}")
