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
        viewController.tabBarItem = UITabBarItem(title: nil, image: R.image.create()!, selectedImage: nil)
        viewController.title = "投票の作成"
        return viewController
    }

    @IBOutlet weak var contentsTextField: UITextField!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var addChoice: UIButton!
    @IBOutlet private weak var postButton: UIButton!
    @IBOutlet private weak var choiceLabel1: UILabel!
    @IBOutlet private weak var choiceLabel2: UILabel!
    @IBOutlet private weak var choiceLabel3: UILabel!
    @IBOutlet private weak var choiceLabel4: UILabel!
    
    private let disposeBag = DisposeBag()
    private let viewModel = PostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choiceLabel1.isHidden = true
        choiceLabel2.isHidden = true
        choiceLabel3.isHidden = true
        choiceLabel4.isHidden = true
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }
    
    private func configure() {
        //TODO:TextFieldのdelegate処理を行う
        hiddenLabel()
    }
    
    private func hiddenLabel() {
        let value = viewModel.choices.value
        
        switch value.count {
        case 0:
            return
        case 1:
            choiceLabel1.isHidden = false
            choiceLabel1.text = value[0].description
        case 2:
            choiceLabel2.isHidden = false
            choiceLabel2.text = value[1].description
        case 3:
            choiceLabel3.isHidden = false
            choiceLabel3.text = value[2].description
        case 4:
            choiceLabel4.isHidden = false
            choiceLabel4.text = value[3].description
        default:
            break
        }
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
                guard let wself = self else { return }
                wself.presentAddChoiceView()
            })
            .disposed(by: disposeBag)
        
        output
            .registerVoteContents
            .withLatestFrom(viewModel.choices.asDriver(onErrorDriveWith: Driver.empty()))
            .drive(onNext: { [weak self] in
                guard let wself = self, let description = wself.contentsTextField.text else { return }
                PostManager.shared.append(
                    Post(choices: $0, userName: "田中", createdAt: Date(), description: description, deadline: wself.datePicker.date, voteCount: 0))
            })
            .disposed(by: disposeBag)
    }
}

extension PostViewController {
    private func presentAddChoiceView() {
        let viewController = AddChoiceViewController.make(choices: viewModel.choices)
        present(viewController, animated: true)
    }
}
