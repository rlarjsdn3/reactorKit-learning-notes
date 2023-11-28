//
//  MainViewReactor.swift
//  HelloWorld
//
//  Created by 김건우 on 11/28/23.
//

import UIKit

import ReactorKit
import RxSwift

enum ResetAlertAction: AlertActionType {
    case reset
    case cancel
    
    var title: String? {
        switch self {
        case .reset:
            return "확인"
        case .cancel:
            return "취소"
        }
    }
    
    var style: UIAlertAction.Style {
        switch self {
        case .reset:
            return .default
        case .cancel:
            return .cancel
        }
    }
}

final class MainViewReactor: Reactor {
    // MARK: - Action
    enum Action { 
        case resetBtnTapped
    }
    
    // MARK: - Mutation
    enum Mutation { 
        case updateUsername(String)
        case resetUsername
    }
    
    // MARK: - State
    struct State {
        var username: String = "Swift"
    }
    
    // MARK: - Properties
    var initialState: State
    var provider: ServiceProviderProtocol
    
    // MARK: -Intializer
    init() {
        self.initialState = State()
        self.provider = ServiceProvider()
    }
    
    // MARK: - Helpers
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let eventMutation = provider.userService.event
            .flatMap { event -> Observable<Mutation> in
                switch event {
                case let .updateUsername(name):
                    return .just(.updateUsername(name))
                }
            }
        return Observable.merge(eventMutation, mutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .resetBtnTapped:
            let alertActions: [ResetAlertAction] = [.reset, .cancel]
            return provider.alertService.show(
                title: "초기화",
                message: "초기화하시겠습니까?",
                preferredStyle: .alert,
                actions: alertActions)
            .flatMap { alertAction -> Observable<Mutation> in
                switch alertAction {
                case .reset:
                    return .just(.resetUsername)
                case .cancel:
                    return .empty()
                }
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateUsername(name):
            newState.username = name
        case .resetUsername:
            newState.username = ""
        }
        return newState
    }
}

extension MainViewReactor {
    func getInputViewReactor() -> InputViewReactor {
        return InputViewReactor(
            username: currentState.username,
            provider: provider
        )
    }
}
