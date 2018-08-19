//
//  WalletViewController.swift
//  SimpleWallet
//
//  Created by 下村一将 on 2018/08/18.
//  Copyright © 2018 Akifumi Fujita. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController {
    static func make() -> WalletViewController {
        let vc = R.storyboard.walletViewController.instantiateInitialViewController()!
        vc.tabBarItem = UITabBarItem(title: nil, image: R.image.wallet()!, selectedImage: nil)
        vc.title = "Wallet"
        return vc
    }

    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var qrImageView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    private func updateUI() {
        let pubkey = AppController.shared.wallet!.publicKey
        let cashAddr = pubkey.toCashaddr().cashaddr
        print("cashAddr: \(cashAddr)")
        addressLabel.text = cashAddr
        qrImageView.image = QRCoder(delegate: nil).generate(from: cashAddr)

        //残高
        APIClient().getUnspentOutputs(withAddresses: [AppController.shared.wallet!.publicKey.toLegacy().description]) { [weak self] (utxos: [UnspentOutput]) in
            let balance = utxos.reduce(0) { $0 + $1.amount }
            DispatchQueue.main.async { self?.balanceLabel.text = "\(balance) tBCH" }
        }
    }
}
