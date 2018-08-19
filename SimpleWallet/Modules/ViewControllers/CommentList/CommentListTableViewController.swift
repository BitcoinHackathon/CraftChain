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
        vc.title = "コメントリスト"
        return vc
    }

    let txs: [String] = ["05deb3f0ea74c3a81f9b4784ebfe3020d825631782a18955eaeadc16ed1effc1",
                         "dfd6c7702ae52f3b881b89776a69337cfa0d004f672742172beb96b36ab82244",
                         "2d0e8b2ee2958b6af31c2869d9ffd2adc97400486a9c4b9dc538488e86c69da5"]
    var results: [String] = []

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
                    .map { $0.scriptPubKey.hex }
                    .compactMap { Data(hex: $0) }
                    .compactMap { String.init(data: $0, encoding: .utf8) }
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
        cell.textLabel?.text =  result
        return cell
    }
}
