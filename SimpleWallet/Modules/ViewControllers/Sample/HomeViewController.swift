//
//  ViewController.swift
//  SampleWallet
//
//  Created by Akifumi Fujita on 2018/08/17.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import UIKit
import BitcoinKit

class HomeViewController: UITableViewController {
    static func make() -> UIViewController {
        let vc = R.storyboard.main.instantiateInitialViewController()!
        vc.tabBarItem = UITabBarItem(title: nil, image: R.image.analyze()!, selectedImage: nil)
        vc.title = "Example"
        return vc
    }
    
    var wallet: Wallet?
    var transactions = [CodableTx]()
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let sendViewController = storyboard?.instantiateViewController(withIdentifier: "SendViewController") as! SendViewController
        navigationController?.pushViewController(sendViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = AppController.shared.wallet else {
            createWallet()
            return
        }
        
        //print("Mock result:", MockPlayGround().verifyScript())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    private func updateUI() {
        getAddress()
        getBalance()
        getTxHistory()
    }
    
    // walletの作成
    private func createWallet() {
        
        
        //AppController.shared.importWallet(wif: wif)
    }
    
    // Addressの表示
    private func getAddress() {
        
    }
    
    // 残高を確認する
    private func getBalance() {
        APIClient().getUnspentOutputs(withAddresses: [AppController.shared.wallet!.publicKey.toLegacy().description], completionHandler: { [weak self] (utxos: [UnspentOutput]) in
            let balance = utxos.reduce(0) { $0 + $1.amount }
            DispatchQueue.main.async { self?.balanceLabel.text = "\(balance) tBCH" }
        })
    }
    
    // 過去のトランザクションの履歴の取得
    private func getTxHistory() {
        APIClient().getTransaction(withAddresses: AppController.shared.wallet!.publicKey.toLegacy().description, completionHandler: { [weak self] (transactrions:[CodableTx]) in
            self?.transactions = transactrions
            DispatchQueue.main.async { self?.tableView.reloadData() }
        })
    }
    
    private func updateBalance2() {
        let cashaddr = AppController.shared.wallet!.publicKey.toCashaddr().cashaddr
        let address = cashaddr.components(separatedBy: ":")[1]
        let addition = transactions.filter { $0.direction(addresses: [address]) == .received }.reduce(0) { $0 + $1.amount(addresses: [address]) }
        let subtraction = transactions.filter { $0.direction(addresses: [address]) == .sent }.reduce(0) { $0 + $1.amount(addresses: [address]) }
        let balance = addition - subtraction
        balanceLabel.text = "\(balance) tBCH"
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactions"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        
        let transaction = transactions[indexPath.row]
        
        let cashaddr = AppController.shared.wallet!.publicKey.toCashaddr().cashaddr
        let address = cashaddr.components(separatedBy: ":")[1]
        
        let value = transaction.amount(addresses: [address])
        let direction = transaction.direction(addresses: [address])
        let messages = transaction.messages().joined(separator: ",")
        
        switch direction {
        case .sent:
            cell.textLabel?.text = "- \(value): \(messages)"
        case .received:
            cell.textLabel?.text = "+ \(value): \(messages)"
        }
        
        cell.textLabel?.textColor = direction == .sent ? #colorLiteral(red: 0.7529411765, green: 0.09803921569, blue: 0.09803921569, alpha: 1) : #colorLiteral(red: 0.3882352941, green: 0.7843137255, blue: 0.07843137255, alpha: 1)
        
        return cell
    }
    
    private func generateVisualCode(address: String) -> UIImage? {
        let parameters: [String : Any] = [
            "inputMessage": address.data(using: .utf8)!,
            "inputCorrectionLevel": "L"
        ]
        let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: parameters)
        
        guard let outputImage = filter?.outputImage else {
            return nil
        }
        
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        guard let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
