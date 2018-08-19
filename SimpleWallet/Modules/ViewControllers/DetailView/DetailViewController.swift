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
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet weak var choice1Button: UIButton!
    @IBOutlet weak var choice2Button: UIButton!
    @IBOutlet weak var choice3Button: UIButton!
    @IBOutlet weak var choice4Button: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var remainDateLabel: UILabel!
    
    var lockTimeString: String!

    private var post: Post!
    private var updateTimer: Timer!

    static func make(post: Post) -> DetailViewController {
        let vc = R.storyboard.detailViewController.instantiateInitialViewController()!
        vc.post = post
        return vc
    }

    @IBAction func voteAction(_ sender: Any) {
        debugLog("投票しました")

        // 運営と投票される側でマルチシグを行う
        let multisig: Address = BCHHelper().createMultisigAddress(adminPubKey: Constant.adminPubKey,
                                                                  targetPubKey: post.choices[0].pubKey) //決め打ち
        sendCoins(toAddress: multisig, amount: Constant.voteAmount, comment: commentText.text!)
    }
    
    private func sendCoins(toAddress: Address, amount: Int64, comment: String) {
        // おつり用のアドレスを決める
        let changeAddress: Address = AppController.shared.wallet!.publicKey.toCashaddr()
        
        // UTXOの取得
        let legacyAddress: String = AppController.shared.wallet!.publicKey.toLegacy().description
        APIClient().getUnspentOutputs(withAddresses: [legacyAddress], completionHandler: { [weak self] (unspentOutputs: [UnspentOutput]) in
            guard let strongSelf = self else {
                return
            }
            let utxos = unspentOutputs.map { $0.asUnspentTransaction() }
            let unsignedTx = strongSelf.createUnsignedTx(toAddress: toAddress, amount: amount, changeAddress: changeAddress, utxos: utxos, comment: comment)
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
    
    public func createUnsignedTx(toAddress: Address, amount: Int64, changeAddress: Address, utxos: [UnspentTransaction], comment: String) -> UnsignedTransaction {
        // UTXOの選択
        let (utxos, fee) = BCHHelper().selectTx(from: utxos)
        let totalAmount: Int64 = utxos.reduce(0) { $0 + $1.output.value }
        let change: Int64 = totalAmount - amount - fee
        
        let lockScriptChange = Script(address: changeAddress)!
        
        let lockScriptTo = try! Script()
            // 運営がunlockする場合
            .append(.OP_IF)
                // マルチシグでロック
                .append(.OP_2)
                .appendData(Constant.adminPubKey.raw)
                .appendData(post.choices[0].pubKey.raw) //決め打ち
                .append(.OP_2)
                .append(.OP_CHECKMULTISIG)
            // ユーザーがunlockする場合
            .append(.OP_ELSE)
                // LOCKTIMEをかける
                .appendData(BCHHelper().string2ExpiryTime(dateString: lockTimeString))
                .append(.OP_CHECKLOCKTIMEVERIFY)
                .append(.OP_DROP)
                .append(.OP_HASH160)
                // LOCKTIMEが過ぎていたら自分で開けられる
                .appendData(AppController.shared.wallet!.publicKey.toCashaddr().data)
                .append(.OP_EQUALVERIFY)
                .append(.OP_CHECKSIG)
        
        let toOutput = TransactionOutput(value: amount, lockingScript: lockScriptTo.data)
        let changeOutput = TransactionOutput(value: change, lockingScript: lockScriptChange.data)
        
        // UTXOとTransactionOutputを合わせて、UnsignedTransactionを作る
        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: [toOutput, changeOutput], lockTime: 0)
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
            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)

            let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
            guard let key = keysOfUtxo.first else {
                continue
            }

            let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BCH.ALL)
            let signature: Data = try! Crypto.sign(sighash, privateKey: key)
            let txin = inputsToSign[i]
            let pubkey = key.publicKey()

            // unlockScriptを作る
            let unlockingScript = Script.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)

            inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput,
                                               signatureScript: unlockingScript,
                                               sequence: txin.sequence)
        }
        return transactionToSign
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup(post: post)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let me = self else { return }
            me.setup(post: me.post)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        lockTimeString = "2018-08-20 18:00:00"
    }

    func setup(post: Post) {
        userNameLabel.text = post.userName

        let diff = Int(post.deadline.timeIntervalSince(Date()))
        let day = diff/24/60/60
        let hour = diff/60/60
        let min = diff/60 - hour*60
        let sec = diff - min*60 - hour*60*60

        dateLabel.text = Post.dateFormatter.string(from: post.createdAt)
        descriptionLabel.text = post.description
        remainDateLabel.text = "残り\(day)日と\(hour)時間\(min)分\(sec)秒"
        choice1Button.setTitle(post.choices.get(at: 0)?.description, for: .normal)
        choice2Button.setTitle(post.choices.get(at: 1)?.description, for: .normal)
        choice3Button.setTitle(post.choices.get(at: 2)?.description, for: .normal)
        choice4Button.setTitle(post.choices.get(at: 3)?.description, for: .normal)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer.invalidate()
    }
}
