//
//  CounterViewReactor.swift
//  HelloReactorKit
//
//  Created by 김건우 on 11/23/23.
//

import ReactorKit
import RxSwift

final class CounterViewReactor: Reactor {
    // Action은 사용자가 전달하는 이벤트
    enum Action {
        case increase
        case decrease
    }
    
    // Mutate는 뷰에 노출되지 않고, 상태를 조정하는 최소 단위
    enum Mutation {
        case increaseValue
        case decreaseValue
        case setLoading(Bool)
        case setAlertMessage(String)
    }
    
    // State는 뷰의 상태
    struct State {
        var value: Int
        var isLoading: Bool
        @Pulse var alertMessage: String?
        // ⭐️ Pulse 프로퍼티 래퍼 기본 이론: 
        // - 동일한 값이든, 다른 값이든 상관없이 값을 새로 할당하면(valueUpdatedCount 값이 바뀌면) 이벤트를 방출함.
        
        // State 이벤트는 값이 변화 유무에 상관없이 항상 전체 이벤트를 뷰에 방출함.
        // (즉, 다른 프로퍼티가 변경되어도 전체 State 이벤트를 뷰에 방출함. 이런 이유로 distinctUntilChange() 연산자로 동일한 이벤트를 필터링해야 함)
        // 그에 반해, Pulse 이벤트는 지정한 프로퍼티에 동일한 값이든, 다른 값이든 상관없이 새로운 값이 할당되는 경우에만 이벤트를 방출함.
        // (즉, 다른 프로퍼티가 변경되어도 Pulse 프로퍼티에 새로운 값을 할당하지 않았다면 이벤트를 방출하지 않음)
        
        // 만약, Pulse 프로퍼티를 제외한 나머지 State 값이 변경되면, State 이벤트를 방출하되, Pulse 이벤트는 방출하지 않음.
        // Pulse 프로퍼티가 변경이 되면, 그제서야 Pulse 이벤트를 방출함.
        
        // 이렇게 동작할 수 있는 이유는 Pulse 프로퍼티에 새로운 값을 할당될 때마다 내부에 valueUpdatedCount 값을 증가시키고,
        // pulse 메서드는 valueUpdatedCount 값이 변경된 경우에만, 이벤트를 방출하기 때문임.
        
        // 정리하면, alertMessage에 Pulse 프로퍼티 래퍼를 적용함으로써,
        // State 이벤트 방출로 인해 알림창이 중복으로 표시되는 걸 방지하고, 동일한 알림 메시지 이벤트를 방출하더라도 정상적으로 알림창이 표시되게 할 수 있음.
    }
    
    let initialState: State
    
    init() {
        initialState = State(
            value: 0,
            isLoading: false
        )
    }
    
    // Action -> Action (Transform)
//    func transform(action: Observable<Action>) -> Observable<Action> {
//      return action.debug("action") // Use RxSwift's debug() operator
//    }
    
    // Action -> Mutate (mutate 메서드에서 필요한 사이드 이펙트를 수행할 수 있음)
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .increase:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.increaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false)),
                Observable.just(Mutation.setAlertMessage("Increased!"))
            ])
        case .decrease:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.decreaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false)),
                Observable.just(Mutation.setAlertMessage("Decreased!"))
            ])
        }
    }
    
    // Mutate -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .increaseValue:
            newState.value += 1
        case .decreaseValue:
            newState.value -= 1
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setAlertMessage(let message):
            newState.alertMessage = message
        }
        return newState
    }
    
}
