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

class AddChoiceViewController: UIViewController {
    static func make() -> UIViewController {
        let viewController = R.storyboard.addChoiceViewController.instantiateInitialViewController()!
        return viewController
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel = AddChoiceViewModel()
    
    @IBOutlet private weak var choiceTextField: UITextField!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var BCHurlText: UITextField!
    @IBOutlet private weak var addButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let input = AddChoiceViewModel.Input(
            choiceTextFieldInput: choiceTextField.rx.text.orEmpty.asDriver(),
            BCHurlTextInput: BCHurlText.rx.text.orEmpty.asDriver(),
            addButton: addButton.rx.tap.asDriver()
        )
        
        let output = viewModel.build(input: input)
        
        output
            .registerChoice
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
