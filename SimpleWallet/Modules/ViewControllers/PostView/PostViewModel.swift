//
//  PostViewModel.swift
//  SimpleWallet
//
//  Created by 宇野凌平 on 2018/08/18.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import RxSwift
import RxCocoa

final class PostViewModel {
    let choices = BehaviorRelay(value: [Post.Choice]())

    struct Input {
        let contentsTextFieldInput: Driver<String>
        let datePicker: Driver<Date>
        let addChoiceButtonDidTap: Driver<Void>
        let postButtonDidTap: Driver<Void>
    }

    struct Output {
        let presentAddChoiceView: Driver<Void>
        let registerVoteContents: Driver<Void>
    }

    func build(input: Input) -> Output {
        return Output(
            presentAddChoiceView: input.addChoiceButtonDidTap,
            registerVoteContents: input.postButtonDidTap
        )
    }
}
