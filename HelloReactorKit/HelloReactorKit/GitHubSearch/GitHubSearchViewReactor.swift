//
//  GitHubSearchViewReactor.swift
//  HelloReactorKit
//
//  Created by 김건우 on 11/24/23.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class GitHubSearchViewReactor: Reactor {
    // Action
    enum Action {
        case updateQuery(String?)
        case loadNextPage
    }
    
    // Mutation
    enum Mutation { 
        case setQuery(String?)
        case setRepos([String], nextPage: Int?)
        case appendRepos([String], nextPage: Int?)
        case setLoadingNextPage(Bool)
    }
    
    // State
    struct State { 
        var query: String?
        var repos: [String] = []
        var nextPage: Int?
        var isLoadingNextPage: Bool = false
    }
    
    var initialState: State = State()
    
    // Action -> Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateQuery(let query):
            return Observable.concat([
                // 1) 현재 검색어 저장 (.setQuery)
                Observable.just(Mutation.setQuery(query)),
                
                // 2) API 호출 및 리포지토리 저장 (.setRepos)
                self.search(query: query, page: 1)
                    // 다른 updateQuery 액션이 발생하면 이전 요청을 중단시킴.
                    .take(until: self.action.filter(Action.isUpdateQuery))
                    .map { Mutation.setRepos($0, nextPage: $1) }
                
            ])
        case .loadNextPage:
            // 중복 요청 막기
            guard !self.currentState.isLoadingNextPage else { return Observable.empty() }
            guard let page = self.currentState.nextPage else { return Observable.empty() }
            return Observable.concat([
                // 1) 로딩 상태를 true로 변경
                Observable.just(Mutation.setLoadingNextPage(true)),
                
                // 2) API 호출 및 리포지토리 추가
                self.search(query: self.currentState.query, page: page)
                    .take(until: self.action.filter(Action.isUpdateQuery))
                    .map { Mutation.appendRepos($0, nextPage: $1) },
                
                // 3) 로딩 상태를 false로 변경
                Observable.just(Mutation.setLoadingNextPage(false))
            ])
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .setQuery(query):
            var newState = state
            newState.query = query
            return newState
        case let .setRepos(repos, nextPage):
            var newState = state
            newState.repos = repos
            newState.nextPage = nextPage
            return newState
        case let .appendRepos(repos, nextPage):
            var newState = state
            newState.repos.append(contentsOf: repos)
            newState.nextPage = nextPage
            return newState
        case let .setLoadingNextPage(isLoadingNextPage):
            var newState = state
            newState.isLoadingNextPage = isLoadingNextPage
            return newState
        }
    }

    private func url(for query: String?, page: Int) -> URL? {
        guard let query = query, !query.isEmpty else { return nil }
        return URL(string: "https://api.github.com/search/repositories?q=\(query)&page=\(page)")
    }
    
    private func search(query: String?, page: Int) -> Observable<(repos: [String], nextPage: Int?)> {
        let emptyResult: ([String], Int?) = ([], nil)
        guard let url = self.url(for: query, page: page) else { return .just(emptyResult) }
        return URLSession.shared.rx.json(url: url)
            .map { json -> ([String], Int?) in
                guard let dict = json as? [String: Any] else { return emptyResult }
                guard let items = dict["items"] as? [[String: Any]] else { return emptyResult }
                let repos = items.compactMap { $0["full_name"] as? String }
                let nextPage = repos.isEmpty ? nil : page + 1
                return (repos, nextPage)
            }
            .do(onError: { error in
                if case let .httpRequestFailed(response, _) = error as? RxCocoaURLError,
                    response.statusCode == 403 {
                    print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
                }
            })
    }
}

extension GitHubSearchViewReactor.Action {
    static func isUpdateQuery(_ action: GitHubSearchViewReactor.Action) -> Bool {
        if case .updateQuery = action {
            return true
        } else {
            return false
        }
    }
}
