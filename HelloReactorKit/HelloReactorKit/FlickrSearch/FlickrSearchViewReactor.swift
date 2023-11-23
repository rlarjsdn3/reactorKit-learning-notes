//
//  FlickrSearchViewReactor.swift
//  HelloReactorKit
//
//  Created by 김건우 on 11/23/23.
//

import ReactorKit
import RxSwift

final class FlickrSearchViewReactor: Reactor {
    // Action
    enum Action {
        case searchQuery(String)
    }
    
    // Mutation
    enum Mutation {
        case photoList([Photo])
    }
    
    // State
    struct State {
        var photoList: [Photo] = []
    }
    
    var initialState: State
    let flickrService: FlickrService = FlickrService.shared
    
    init() {
        initialState = State()
    }
    
    // Action -> Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .searchQuery(let query):
            return flickrService.requestQuery(query)
                .map { Mutation.photoList($0) }
        }
    }
    
    // Mutate -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .photoList(let photos):
            newState.photoList = photos
        }
        return newState
    }
}
