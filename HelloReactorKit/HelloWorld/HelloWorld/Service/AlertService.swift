//
//  AlertService.swift
//  HelloWorld
//
//  Created by 김건우 on 11/28/23.
//

import UIKit

import RxSwift
import URLNavigator

protocol AlertActionType {
    var title: String? { get }
    var style: UIAlertAction.Style { get }
}

extension AlertActionType {
    var style: UIAlertAction.Style {
        return .default
    }
}

protocol AlertServiceProtocol {
    func show<Action>(
        title: String?,
        message: String?,
        preferredStyle style: UIAlertController.Style,
        actions: [Action]
    ) -> Observable<Action> where Action: AlertActionType
}

final class AlertService: BaseService, AlertServiceProtocol {
    func show<Action>(
        title: String?,
        message: String?,
        preferredStyle style: UIAlertController.Style,
        actions: [Action]
    ) -> Observable<Action> where Action : AlertActionType {
        return Observable.create { observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: style)
            for action in actions {
                let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                    observer.onNext(action)
                    observer.onCompleted()
                }
                alert.addAction(alertAction)
            }
            Navigator().present(alert)
            return Disposables.create {
                alert.dismiss(animated: true)
            }
        }
    }
}

