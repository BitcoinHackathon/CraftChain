//
//  AdminViewController.swift
//  SimpleWallet
//
//  Created by Daiki Sekiguchi on 2018/08/19.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import UIKit
import BitcoinKit

class AdminViewController: UIViewController {

    static func make() -> DetailViewController {
        return R.storyboard.detailViewController.instantiateInitialViewController()!
    }

    @IBAction func executeButton(_ sender: Any) {
        // 受け取った運営の使い方
        // UTXO集める→識別子を見て適切なものだけを送金
        // TODO: targetPubKey をちゃんとハメる
        let multisig: Address = BCHHelper().createMultisigAddress(adminPubKey: Constant.adminPubKey, targetPubKey: Constant.adminPubKey)
        sendCoins(toAddress: multisig, amount: Constant.voteAmount)
    }
    
    private var targetAddress: Address!
    
    private func sendCoins(toAddress: Address, amount: Int64) {
        // 1. おつり用のアドレスを決める
        let changeAddress: Address = AppController.shared.wallet!.publicKey.toCashaddr()
        
        // 2. UTXOの取得
        // TODO: 値の入れ替え
        // 立候補者の公開鍵
        let targetPubKey = try! Wallet(wif: "立候補者").publicKey
        let legacyAddress: String = BCHHelper().createMultisigAddress(adminPubKey: Constant.adminPubKey, targetPubKey: targetPubKey) as! String
        APIClient().getUnspentOutputs(withAddresses: [legacyAddress], completionHandler: { [weak self] (unspentOutputs: [UnspentOutput]) in
            guard let strongSelf = self else {
                return
            }
            
            let utxos = unspentOutputs.map { $0.asUnspentTransaction() }
            let unsignedTx = strongSelf.createUnsignedTx(toAddress: toAddress, amount: amount, changeAddress: changeAddress, utxos: utxos)
            let signedTx = strongSelf.signTx(unsignedTx: unsignedTx, keys: [AppController.shared.wallet!.privateKey])
            let rawTx = signedTx.serialized().hex
            
            // 7. 署名されたtxをbroadcastする
            APIClient().postTx(withRawTx: rawTx, completionHandler: { (txid, error) in
                if let txid = txid {
                    print("txid = \(txid)")
                    print("txhash: https://test-bch-insight.bitpay.com/tx/\(txid)")
                } else {
                    print("error post \(error ?? "error = nil")")
                }
            })
        })
    }
    
    public func createUnsignedTx(toAddress: Address, amount: Int64, changeAddress: Address, utxos: [UnspentTransaction]) -> UnsignedTransaction {
        // 3. 送金に必要なUTXOの選択
        let (utxos, fee) = BCHHelper().selectTx(from: utxos, amount: amount)
        let totalAmount: Int64 = utxos.reduce(0) { $0 + $1.output.value }
        let change: Int64 = totalAmount - amount - fee
        
        let lockScriptTo = Script(address: toAddress)!
        let lockScriptChange = Script(address: changeAddress)!
        
        let toOutput = TransactionOutput(value: amount, lockingScript: lockScriptTo.data)
        let changeOutput = TransactionOutput(value: change, lockingScript: lockScriptChange.data)
        
        // 5. UTXOとTransactionOutputを合わせて、UnsignedTransactionを作る
        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: [toOutput, changeOutput], lockTime: 0)
        
        return UnsignedTransaction(tx: tx, utxos: utxos)
    }
    
    // 6. 署名する
    public func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) -> Transaction {
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
        }
        
        // Signing
        let hashType = SighashType.BCH.ALL
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            let targetWallet = try! Wallet(wif: "cP1uBo6EsiBayFLu3E5mst5eDg7KNGRJbndbckRfV14votPZu4oU")
            
            let adminPubKey = Constant.adminPubKey
            // TODO: SingしたときのPubKeyを使わないと開かない
            // TODO: 値を変更する必要がある
            let targetPubKey = targetWallet.publicKey
            
            let redeemScript = Script(publicKeys: [adminPubKey, targetPubKey], signaturesRequired: 2)!
            
            // outputを作り直す
            let output = TransactionOutput(value: utxo.output.value, lockingScript: redeemScript.data)
            
            // 作り直したoutputをsighashを作るときに入れる
            let sighash: Data = transactionToSign.signatureHash(for: output, inputIndex: i, hashType: SighashType.BCH.ALL)
            let adminSig: Data = try! Crypto.sign(sighash, privateKey: AppController.shared.wallet!.privateKey)
            let targetSig: Data = try! Crypto.sign(sighash, privateKey: targetWallet.privateKey)
            let txin = inputsToSign[i]
            
            let unlockingScript = try! Script()
                .append(.OP_0)
                .appendData(adminSig + UInt8(hashType))
                .appendData(targetSig + UInt8(hashType))
                .appendData(redeemScript.data)
                // 運営側が解除するときはTRUE
                .append(.OP_TRUE)
            
            inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript.data, sequence: txin.sequence)
        }
        
        return transactionToSign
    }
    
    private func createMultisigAddress(adminPubKey: PublicKey, targetPubKey: PublicKey) -> Address {
        let multisig = Script(publicKeys: [adminPubKey, targetPubKey], signaturesRequired: 2)!
        return multisig.toP2SH().standardAddress(network: .testnet)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
