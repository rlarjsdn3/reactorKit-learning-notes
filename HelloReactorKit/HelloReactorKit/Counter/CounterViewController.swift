//
//  CounterViewController.swift
//  HelloReactorKit
//
//  Created by 김건우 on 11/23/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class CounterViewController: UIViewController, StoryboardView {
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var disposeBag: DisposeBag = DisposeBag()
    let counterViewReactor: CounterViewReactor = CounterViewReactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(reactor: counterViewReactor)
    }
    
    func bind(reactor: CounterViewReactor) {
        // Action
        increaseButton.rx.tap
            .debug()
            .map { CounterViewReactor.Action.increase }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .debug()
            .map { CounterViewReactor.Action.decrease }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.value }
            .debug()
            .distinctUntilChanged()
            .map { "\($0)" }
            .bind(to: valueLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { !$0.isLoading }
            .debug()
            .distinctUntilChanged()
            .bind(to: activityIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .debug()
            .distinctUntilChanged()
            .bind(to: activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$alertMessage)
            .debug("[Pulse Event]")
            .compactMap{ $0 }
            .subscribe(onNext: { [weak self] message in
                let alertController = UIAlertController(
                  title: nil,
                  message: message,
                  preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(
                  title: "OK",
                  style: .default,
                  handler: nil
                ))
                self?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
//        reactor.state.map { $0.alertMessage }
//            .compactMap { $0 }
//            .distinctUntilChanged()
//            .subscribe(onNext: { [weak self] message in
//                let alertController = UIAlertController(
//                  title: nil,
//                  message: message,
//                  preferredStyle: .alert
//                )
//                alertController.addAction(UIAlertAction(
//                  title: "OK",
//                  style: .default,
//                  handler: nil
//                ))
//                self?.present(alertController, animated: true)
//            })
//            .disposed(by: disposeBag)
    }
}
