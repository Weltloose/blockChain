#!/usr/bin/python3.6

import argparse
import sys
import glob
from client.stattool import StatTool
from client_config import client_config
from eth_account.account import (
    Account
)
from eth_utils.hexadecimal import encode_hex
from client.contractnote import ContractNote
import json
import os
from client.datatype_parser import DatatypeParser
from eth_utils import to_checksum_address
from console_utils.precompile import Precompile
from console_utils.rpc_console import RPCConsole
from client.common import transaction_common
from client.common import common
from client.bcoserror import BcosError, CompileError, PrecompileError, ArgumentsError, BcosException
from client.common.transaction_exception import TransactionException
import argcomplete

# get supported command
contracts_dir = "model/python_sdk/contracts"

def generateAccount(name, password):
    try:
        ac = Account.create(password)
        stat = StatTool.begin()
        kf = Account.encrypt(ac.privateKey, password)
        stat.done()
        keyfile = "{}/{}.keystore".format(client_config.account_keyfile_path, name)
        if os.access(keyfile, os.F_OK):
            print("error")
            return
        with open(keyfile, "w") as dump_f:
            json.dump(kf, dump_f)
            dump_f.close()
        print("success")
    except:
        print("error")

def getContractAddr(contractName):
    return ContractNote.get_contract_addresses(contractName)[0]

def fill_params(params, paramsname):
    index = 0
    result = dict()
    for name in paramsname:
        result[name] = params[index]
        index += 1
    return result

def default_abi_file(contractname):
    abi_file = contractname
    if not abi_file.endswith(".abi"):  # default from contracts/xxxx.abi,if only input a name
        abi_file = contracts_dir + "/" + contractname + ".abi"
    return abi_file

def print_parse_transaction(tx, contractname, parser=None):
    if parser is None:
        parser = DatatypeParser(default_abi_file(contractname))
    inputdata = tx["input"]
    inputdetail = parser.parse_transaction_input(inputdata)
    return (inputdetail)

def print_receipt_logs_and_txoutput(client, receipt, contractname, parser=None):
    if parser is None and len(contractname) > 0:
        parser = DatatypeParser(default_abi_file(contractname))
    logresult = parser.parse_event_logs(receipt["logs"])
    txhash = receipt["transactionHash"]
    txresponse = client.getTransactionByHash(txhash)
    inputdetail = print_parse_transaction(txresponse, "", parser)
    # 解析该交易在receipt里输出的output,即交易调用的方法的return值
    outputresult = parser.parse_receipt_output(inputdetail['name'], receipt['output'])
    return outputresult

def sendTx(contractname, contractAddr, funcName, params):
    try:
        tx_client = transaction_common.TransactionCommon(
                    contractAddr, contracts_dir, contractname)
        receipt = tx_client.send_transaction_getReceipt(funcName, params)[0]
        data_parser = DatatypeParser(default_abi_file(contractname))
        # 解析receipt里的log 和 相关的tx ,output
        return print_receipt_logs_and_txoutput(tx_client, receipt, "", data_parser)
        # return result
    except Exception as e:
        print(e)
        return "error"

def inDebt(contractname, contractAddr):
    print(sendTx(contractname, contractAddr, "inDebt", [])[0])

def AddDownStreamCompany(contractname, contractAddr, name):
    print(sendTx(contractname, contractAddr, "AddDownStreamCompany", [name])[0])

def SignAndIssue(contractname, contractAddr, to, amount, debtTime):
    sendTx(contractname, contractAddr, "SignAndIssue", [to, amount, debtTime])
    print(0)

def GetRight(contractname, contractAddr, owner, debtTime):
    print(sendTx(contractname, contractAddr, "GetRight", [owner, debtTime])[0])

def TransferRight(contractname, contractAddr, fromm, to, amount, debtTime):
    print(sendTx(contractname, contractAddr, "TransferRight", [fromm, to, amount, debtTime])[0])

def GetFinance(contractname, contractAddr, fromm):
    print(sendTx(contractname, contractAddr, "GetFinance", [fromm])[0])

def BankCheckFinance(contractname, contractAddr, fromm):
    sendTx(contractname, contractAddr, "BankCheckFinance", [fromm])
    print(0)

def CompanyAddFinance(contractname, contractAddr, fromm, amount):
    sendTx(contractname, contractAddr, "CompanyAddFinance", [fromm, amount])
    print(0)

def CompanyPayFinance(contractname, contractAddr, fromm, amount):
    sendTx(contractname, contractAddr, "CompanyPayFinance", [fromm, amount])
    print(0)

def ConfirmPaied(contractname, contractAddr, to):
    sendTx(contractname, contractAddr, "ConfirmPaied", [to])
    print(0)

def CheckUnpaied(contractname, contractAddr):
    sendTx(contractname, contractAddr, "CheckUnpaied", [])

def unpaied(contractname, contractAddr, id):
    return sendTx(contractname, contractAddr, "unpaied", [id])[0]

def GetCompanyName(contractname, contractAddr, id):
    return sendTx(contractname, contractAddr, "GetCompanyName", [id])[0]

def GetUnpaied(contractname, contractAddr):
    try:
        CheckUnpaied(contractname, contractAddr)
        for i in range(1, 10):
            if (unpaied(contractname, contractAddr, i) == 1):
                print(GetCompanyName(contractname, contractAddr, i), end=",")
    except:
        print("error")

def main():
    try:
        if(sys.argv[1] == "generateAccount"):
            generateAccount(sys.argv[2], sys.argv[3])
            return
        contractName = client_config.contractName
        contractAddr = getContractAddr(contractName)
        username = sys.argv[1]
        password = sys.argv[2]
        client_config.account_keyfile = username + ".keystore"
        client_config.account_password = password
        if(sys.argv[3] == "inDebt"):
            inDebt(contractName, contractAddr)
        if(sys.argv[3] == "AddDownStreamCompany"):
            AddDownStreamCompany(contractName, contractAddr, sys.argv[4])
        if(sys.argv[3] == "SignAndIssue"):
            SignAndIssue(contractName, contractAddr, sys.argv[4], sys.argv[5], sys.argv[6])
        if(sys.argv[3] == "GetRight"):
            GetRight(contractName, contractAddr, sys.argv[4], sys.argv[5])
        if(sys.argv[3] == "TransferRight"):
            TransferRight(contractName, contractAddr, sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7])
        if(sys.argv[3] == "GetFinance"):
            GetFinance(contractName, contractAddr, sys.argv[4])
        if(sys.argv[3] == "BankCheckFinance"):
            BankCheckFinance(contractName, contractAddr, sys.argv[4])
        if(sys.argv[3] == "CompanyAddFinance"):
            CompanyAddFinance(contractName, contractAddr, sys.argv[4], sys.argv[5])
        if(sys.argv[3] == "CompanyPayFinance"):
            CompanyPayFinance(contractName, contractAddr, sys.argv[4], sys.argv[5])
        if(sys.argv[3] == "ConfirmPaied"):
            ConfirmPaied(contractName, contractAddr, sys.argv[4])
        if(sys.argv[3] == "GetUnpaied"):
            GetUnpaied(contractName, contractAddr)
    except Exception as e:
        print("error")


if __name__ == "__main__":
    main()
