//
//  InputViewReactor.swift
//  HelloWorld
//
//  Created by 김건우 on 11/28/23.
//

import Foundation

import ReactorKit
import RxSwift

final class InputViewReactor: Reactor {
    // MARK: - Action
    enum Action {
        case okBtnTapped(String)
    }
    
    // MARK: - Mutation
    enum Mutation {
        case updateUsername(String)
        case dismiss
    }
    
    // MARK: - State
    struct State {
        var username: String
        var shoudDismissed: Bool = false
    }
    
    // MARK: - Properties
    let provider: ServiceProviderProtocol
    var initialState: State
    
    // MARK: - Intializer
    init(username name: String, provider: ServiceProviderProtocol) {
        self.initialState = State(username: name)
        self.provider = provider
    }
    
    // MARK: - Helpers
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .okBtnTapped(name):
            return provider.userService.updateUserName(to: name)
                .map { _ in .dismiss  }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateUsername(name):
            newState.username = name
        case .dismiss:
            newState.shoudDismissed = true
        }
        return newState
    }
}
