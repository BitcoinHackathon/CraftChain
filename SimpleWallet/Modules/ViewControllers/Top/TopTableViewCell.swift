//
//  TopTableViewCell.swift
//  SimpleWallet
//
//  Created by 下村一将 on 2018/08/18.
//  Copyright © 2018 Akifumi Fujita. All rights reserved.
//

import UIKit

class TopTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var choicesStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(_ post: Post) {
        userNameLabel.text = post.userName
        dateLabel.text = post.createdAt.description
        descriptionLabel.text = post.description
        voteCountLabel.text = "\(post.voteCount)票"
        remainTimeLabel.text = "残り\(post.deadline)"

        post.choices.forEach {
            let label = UILabel()
            label.text = $0.description
            choicesStackView.addArrangedSubview(label)
        }
    }
}
