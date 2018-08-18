//
//  DetailViewController.swift
//  SimpleWallet
//
//  Created by Daiki Sekiguchi on 2018/08/18.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import UIKit
import BitcoinKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var commentText: UITextField!
    
    static func make() -> DetailViewController {
        return R.storyboard.detailViewController.instantiateInitialViewController()!
    }

    @IBAction func voteAction(_ sender: Any) {
        print("投票しました")
        
        // LOCKTIME付きで運営に送金
        // OP_1など、投票先によって識別子をつける（UTXO回収時にどの投票だったのかを判別するため）
        
        
        // OP_RETURNもつける
        // メッセージも送信する
        
        
        
        
        // 受け取った運営の使い方
        // UTXO集める→識別子を見て適切なものだけを送金
        
        
        
        // OP_RETURNを見れる場所
        // 送金された後にメッセージを見れるようにする
        // 送金されたトランザクションをなめて、メッセージ入りのOUTPUTを配列で全部表示する
        
        
        
        
    }
    
    private func sendCoins(toAddress: Address, amount: Int64) {
        // 1. おつり用のアドレスを決める
        let changeAddress: Address = AppController.shared.wallet!.publicKey.toCashaddr()
        
        // 2. UTXOの取得
        let legacyAddress: String = AppController.shared.wallet!.publicKey.toLegacy().description
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
    
    public func selectTx(from utxos: [UnspentTransaction], amount: Int64) -> (utxos: [UnspentTransaction], fee: Int64) {
        return (utxos, 500)
    }
    
    public func createUnsignedTx(toAddress: Address, amount: Int64, changeAddress: Address, utxos: [UnspentTransaction]) -> UnsignedTransaction {
        // 3. 送金に必要なUTXOの選択
        let (utxos, fee) = selectTx(from: utxos, amount: amount)
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
            // TODO: 運営の
            let walletA = try! Wallet(wif: "")
            
            let publicKeyA = AppController.shared.wallet!.publicKey
            let publicKeyB = walletA.publicKey
            
            let redeemScript = Script(publicKeys: [publicKeyA, publicKeyB], signaturesRequired: 2)!
            
            // outputを作り直す
            let output = TransactionOutput(value: utxo.output.value, lockingScript: redeemScript.data)
            
            // 作り直したoutputをsighashを作るときに入れる
            let sighash: Data = transactionToSign.signatureHash(for: output, inputIndex: i, hashType: SighashType.BCH.ALL)
            let signatureA: Data = try! Crypto.sign(sighash, privateKey: walletA.privateKey)
            let txin = inputsToSign[i]
            
            let unlockingScript = try! Script()
                .append(.OP_0)
                .appendData(signatureA + UInt8(hashType))
                .appendData(redeemScript.data)
            
            inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript.data, sequence: txin.sequence)
        }
        
        return transactionToSign
    }
    
    private func createMultisigAddress() -> Address {
        let publicKeyA = AppController.shared.wallet!.publicKey
        let publickeyB = try! Wallet(wif: "").publicKey
        
        let multisig = Script(publicKeys: [publicKeyA, publickeyB], signaturesRequired: 2)!
        
        return multisig.toP2SH().standardAddress(network: .testnet)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
