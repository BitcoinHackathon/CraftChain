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
    static func make() -> AdminViewController {
        return R.storyboard.adminViewController.instantiateInitialViewController()!
    }

    @IBAction func executeButton(_ sender: Any) {
        // 受け取った運営の使い方
        // UTXO集める→識別子を見て適切なものだけを送金
        let multisig: Address = BCHHelper().createMultisigAddress(adminPubKey: Constant.adminPubKey,
                                                                  targetPubKey: Constant.targetPubKey)
        sendCoins(toAddress: multisig, amount: Constant.voteAmount)
    }
    
    private var targetAddress: Address!
    
    private func sendCoins(toAddress: Address, amount: Int64) {
        // おつり用のアドレスを決める
        let changeAddress: Address = AppController.shared.wallet!.publicKey.toCashaddr()
        
        // UTXOの取得
        // 立候補者の公開鍵
        let legacyAddress: String = BCHHelper().createMultisigAddress(adminPubKey: Constant.adminPubKey,
                                                                      targetPubKey: Constant.targetPubKey).base58
        APIClient().getUnspentOutputs(withAddresses: [legacyAddress], completionHandler: { [weak self] (unspentOutputs: [UnspentOutput]) in
            guard let strongSelf = self else {
                return
            }
            
            let utxos = unspentOutputs.map { $0.asUnspentTransaction() }
            let unsignedTx = strongSelf.createUnsignedTx(toAddress: toAddress, changeAddress: changeAddress, utxos: utxos)
            let signedTx = strongSelf.signTx(unsignedTx: unsignedTx, keys: [AppController.shared.wallet!.privateKey])
            let rawTx = signedTx.serialized().hex
            
            // broadcast
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
    
    public func createUnsignedTx(toAddress: Address, changeAddress: Address, utxos: [UnspentTransaction]) -> UnsignedTransaction {
        // UTXOの選択
        let (utxos, fee) = BCHHelper().selectTx(from: utxos)
        let totalAmount: Int64 = utxos.reduce(0) { $0 + $1.output.value }
        let amount: Int64 = totalAmount - fee
        
        let lockScriptTo = Script(address: toAddress)!
        
        let toOutput = TransactionOutput(value: amount, lockingScript: lockScriptTo.data)
        
        // UTXOとTransactionOutputを合わせて、UnsignedTransactionを作る
        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: [toOutput], lockTime: 0)
        
        return UnsignedTransaction(tx: tx, utxos: utxos)
    }
    
    public func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) -> Transaction {
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
        }
        
        // Signing
        let hashType = SighashType.BCH.ALL
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            // 本来であれば target(投票される側) が署名する前のトランザクションをブロードキャストする
            // 今回、ライブラリがまだ対応していないとのことだったので、強制的に署名させるようにした
            let targetWallet = try! Wallet(wif: "cP1uBo6EsiBayFLu3E5mst5eDg7KNGRJbndbckRfV14votPZu4oU") //とりあえず
            
            let adminPubKey = Constant.adminPubKey
            let targetPubKey = Constant.targetPubKey
            
            let redeemScript = Script(publicKeys: [adminPubKey, targetPubKey], signaturesRequired: 2)!
            
            // outputを作り直す
            let output = TransactionOutput(value: utxo.output.value, lockingScript: redeemScript.data)
            
            // 作り直したoutputをsighashを作るときに入れる
            let sighash: Data = transactionToSign.signatureHash(for: output, inputIndex: i, hashType: SighashType.BCH.ALL)
            let adminSig: Data = try! Crypto.sign(sighash, privateKey: AppController.shared.wallet!.privateKey)
            let targetSig: Data = try! Crypto.sign(sighash, privateKey: targetWallet.privateKey)
            let txin = inputsToSign[i]
            
            let unlockingScript = try! Script()
                // マルチシグの解除
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
