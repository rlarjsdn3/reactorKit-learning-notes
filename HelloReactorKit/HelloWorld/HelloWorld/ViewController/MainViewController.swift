//
//  ViewController.swift
//  HelloWorld
//
//  Created by 김건우 on 11/28/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class MainViewController: UIViewController, StoryboardView {
    // MARK: - Views
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var changeNameButton: UIButton!
    @IBOutlet weak var resetNameButton: UIButton!
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    var mainViewReactor: MainViewReactor = MainViewReactor()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(reactor: mainViewReactor)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInputView" {
            let inputVC = segue.destination as! InputViewController
            inputVC.reactor = mainViewReactor.getInputViewReactor()
        }
    }
    
    // MARK: - Helpers
    func bind(reactor: MainViewReactor) { 
        // Action
        changeNameButton.rx.tap
            .withUnretained(self)
            .subscribe {
                $0.0.performSegue(withIdentifier: "goToInputView", sender: self)
            }
            .disposed(by: disposeBag)
        
        resetNameButton.rx.tap
            .map { Reactor.Action.resetBtnTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state
            .map { $0.username }
            .distinctUntilChanged()
            .bind(to: mainLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

