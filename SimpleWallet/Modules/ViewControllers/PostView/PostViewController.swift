//
//  PostViewController.swift
//  SimpleWallet
//
//  Created by 宇野凌平 on 2018/08/18.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostViewController: UIViewController {
    static func make() -> UIViewController {
        let viewController = R.storyboard.postViewController().instantiateInitialViewController()!
        return viewController
    }
    
    @IBOutlet weak var contentsTextField: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addChoice: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let viewModel = PostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bindViewModel()
    }
    private func configure() {
        title = "投票の作成"
    }
    
    private func bindViewModel() {
        let input = PostViewModel.Input(
            contentsTextFieldInput: contentsTextField.rx.text.orEmpty.asDriver(),
            datePicker: datePicker.rx.date.asDriver(),
            addChoiceButtonDidTap: addChoice.rx.tap.asDriver(),
            postButtonDidTap: postButton.rx.tap.asDriver())
        
        let output = viewModel.build(input: input)
        
        output
            .presentAddChoiceView
            .drive(onNext: { [weak self] in
                self?.presentAddChoiceView()
            })
            .disposed(by: disposeBag)
    }
}

extension PostViewController {
    private func presentAddChoiceView() {
        let viewController = AddChoiceViewController.make()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
