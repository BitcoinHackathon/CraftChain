//
//  CommentListTableViewController.swift
//  SimpleWallet
//
//  Created by 下村一将 on 2018/08/19.
//  Copyright © 2018 Akifumi Fujita. All rights reserved.
//

import UIKit

class CommentListTableViewController: UITableViewController {
    static func make() -> CommentListTableViewController {
        let vc = CommentListTableViewController()
        vc.tabBarItem = UITabBarItem(title: nil, image: R.image.chat()!, selectedImage: nil)
        vc.title = "コメントリスト"
        return vc
    }

    let txs: [String] = ["3cddeffbc70b164e4aae075c9c2fb6123185ad03d76e83782524d275f82c3c07",
                         "c59360e651cf4fc383eba9c407e0f5dbf5c0ca6b92db4f25874b1410f9049fc9",
                         "3f80c136c0744282ab82d1d282abe42747730462c65e0d07ac44c1823db6cc40"]
    var results: [Vote] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        results = []
        tableView.reloadData()
        txs.forEach {
            APIClient().getTxDetail(withTxID: $0) { [weak self] in
                guard let me = self else { return }
                debugLog("Got tx detail", $0)
                let message = $0.outputs
                    .map { (o: Output) -> String in
                        let hex = o.scriptPubKey.hex
                        return String(hex.suffix(hex.count-4)) // 先頭４文字を削る
                    }
                    .compactMap {
                        guard let data = Data(hex: $0) else { return nil }
                        return data
                    }
                    .compactMap { (data: Data) in Vote(from: data) }
                me.results += message
                DispatchQueue.main.async {
                    me.tableView.reloadData()
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let result = results[indexPath.row]
        cell.textLabel?.text =  result.message
        return cell
    }
}
