//
//  ResultViewController.swift
//  SimpleWallet
//
//  Created by 下村一将 on 2018/08/19.
//  Copyright © 2018 Akifumi Fujita. All rights reserved.
//

import UIKit
import BitcoinKit

class ResultViewController: UIViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var choice1Button: UIButton!
    @IBOutlet weak var choice2Button: UIButton!
    @IBOutlet weak var choice3Button: UIButton!
    @IBOutlet weak var choice4Button: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!

    var lockTimeString: String!

    private var post: Post!
    private var updateTimer: Timer!

    static func make(post: Post) -> ResultViewController {
        let vc = R.storyboard.resultViewController.instantiateInitialViewController()!
        vc.post = post
        return vc
    }

    @IBAction func voteAction(_ sender: Any) {
        debugLog("投票しました")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup(post: post)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let me = self else { return }
            me.setup(post: me.post)
        }

        let btns = [choice1Button, choice2Button, choice3Button, choice4Button]
        btns.forEach {
            $0?.layer.masksToBounds = true
            $0?.layer.cornerRadius = 2.00
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }

    func setup(post: Post) {
        userNameLabel.text = post.userName

        dateLabel.text = Post.dateFormatter.string(from: post.createdAt)
        descriptionLabel.text = post.description
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
