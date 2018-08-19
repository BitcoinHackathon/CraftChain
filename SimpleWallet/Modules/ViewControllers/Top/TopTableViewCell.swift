//
//  TopTableViewCell.swift
//  SimpleWallet
//
//  Created by 下村一将 on 2018/08/18.
//  Copyright © 2018 Akifumi Fujita. All rights reserved.
//

import UIKit

class TopTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var choicesStackView: UIStackView!

    var updateTimer: Timer?

    override func prepareForReuse() {
        updateTimer?.invalidate()
        updateTimer = nil
        choicesStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(_ post: Post) {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let me = self else { return }
            me.updateRemainTimeLabel(post.remainTime)
        })
        profileImageView.image = R.image._r()
        userNameLabel.text = post.userName
        dateLabel.text = Post.dateFormatter.string(from: post.createdAt)
        descriptionLabel.text = post.description
        voteCountLabel.text = "\(post.voteCount)票"
        let remain = post.remainTime
        updateRemainTimeLabel(remain)

        post.choices.forEach {
            let label = UILabel()
            label.text = $0.description
            choicesStackView.addArrangedSubview(label)
        }
    }

    private func updateRemainTimeLabel(_ remain: Post.RemainTime) {
        remainTimeLabel.text = "残り\(remain.day)日と\(remain.hour)時間\(remain.min)分"
    }
}
