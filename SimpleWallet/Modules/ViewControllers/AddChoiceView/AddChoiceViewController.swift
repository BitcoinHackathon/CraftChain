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

    @IBOutlet weak var choiceTextField: UITextField!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var BCHurlText: UITextField!
    @IBOutlet weak var addButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
