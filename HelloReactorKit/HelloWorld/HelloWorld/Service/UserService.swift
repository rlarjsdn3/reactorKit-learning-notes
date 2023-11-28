//
//  UserService.swift
//  HelloWorld
//
//  Created by 김건우 on 11/28/23.
//

import Foundation
import RxSwift

enum UserEvent {
    case updateUsername(String)
}

protocol UserServiceProtocol {
    var event: PublishSubject<UserEvent> { get }
    func updateUserName(to name: String) -> Observable<String>
}

class UserService: BaseService, UserServiceProtocol {
    var event: PublishSubject<UserEvent> = PublishSubject<UserEvent>()
    
    func updateUserName(to name: String) -> Observable<String> {
        event.onNext(.updateUsername(name))
        return .just(name)
    }
}
