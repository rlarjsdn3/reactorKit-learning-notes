//
//  InputViewController.swift
//  HelloWorld
//
//  Created by 김건우 on 11/28/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class InputViewController: UIViewController, StoryboardView {
    // MARK: - Views
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    var inputViewReactor: InputViewReactor!
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Helpers
    func bind(reactor: InputViewReactor) {
        // Action
        okButton.rx.tap
            .withUnretained(self)
            .map { Reactor.Action.okBtnTapped($0.0.inputField.text ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state
            .map { $0.username }
            .distinctUntilChanged()
            .bind(to: inputField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.shoudDismissed }
            .filter { $0 }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { $0.0.navigationController?.popViewController(animated: true) }
            .disposed(by: disposeBag)
    }
}
