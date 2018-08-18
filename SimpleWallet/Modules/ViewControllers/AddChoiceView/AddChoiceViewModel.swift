//
//  AddChoiceViewModel.swift
//  SimpleWallet
//
//  Created by 宇野凌平 on 2018/08/18.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import RxSwift
import RxCocoa

final class AddChoiceViewModel {
    struct Input {
        let addButton: Driver<Void>
    }
    
    struct Output {
        let registerChoice: Driver<Void>
    }
    
    func build(input: Input) -> Output {
        return Output(
            registerChoice: input.addButton
        )
    }
}
