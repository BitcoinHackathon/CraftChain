//
//  TopTableViewController.swift
//  SimpleWallet
//
//  Created by 下村一将 on 2018/08/18.
//  Copyright © 2018 Akifumi Fujita. All rights reserved.
//

import UIKit
import RxSwift

class TopTableViewController: UITableViewController {
    static func make() -> TopTableViewController {
        let vc = TopTableViewController()
        vc.tabBarItem = UITabBarItem(title: nil, image: R.image.timeline()!, selectedImage: nil)
        vc.title = "タイムライン"
        return vc
    }
    
    private var posts: [Post] = []
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        tableView.register(R.nib.topTableViewCell)

        let item = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        navigationItem.leftBarButtonItem = item
        item.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let me = self else { return }
                me.navigationController?.pushViewController(AdminViewController.make(), animated: true)
            }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        posts = PostManager.shared.all()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cell, for: indexPath)!
        let post = posts[indexPath.row]

        cell.gestureRecognizers?.removeAll()
        let longPress = UILongPressGestureRecognizer(target: nil, action: nil)
        longPress.rx.event
            .debounce(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let me = self else { return }
                me.navigationController?.pushViewController(ResultViewController.make(post: post), animated: true)
            }).disposed(by: disposeBag)
        cell.addGestureRecognizer(longPress)
        cell.set(post)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let vc = DetailViewController.make(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}
