//
//  AddChoiceViewController.swift
//  SimpleWallet
//
//  Created by 宇野凌平 on 2018/08/18.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import BitcoinKit

class AddChoiceViewController: UIViewController {
    static func make(choices: BehaviorRelay<[Post.Choice]>) -> UIViewController {
        let viewController = R.storyboard.addChoiceViewController.instantiateInitialViewController()!
        viewController.title = "選択肢の作成"
        viewController.choices = choices
        return viewController
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel = AddChoiceViewModel()
    private var choices: BehaviorRelay<[Post.Choice]>!
    
    @IBOutlet private weak var choiceTextField: UITextField!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var BCHurlText: UITextField!
    @IBOutlet private weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        configureUI()
    }
    
    private func bindViewModel() {
        let input = AddChoiceViewModel.Input(
            addButton: addButton.rx.tap.asDriver()
        )
        
        let output = viewModel.build(input: input)
        
        output
            .registerChoice
            .drive(onNext: { [weak self] _ in
                guard
                    let wself = self,
                    let description = wself.choiceTextField.text,
                    let address = wself.BCHurlText.text else { return }
                var arr = wself.choices.value
                arr.append(Post.Choice(description: description, address: address, pubKey: PrivateKey().publicKey()))
                wself.choices.accept(arr)
                wself.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        numberLabel.text = String(choices.value.count + 1)
    }
}
