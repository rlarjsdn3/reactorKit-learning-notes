//
//  GitHubSearchViewController.swift
//  HelloReactorKit
//
//  Created by 김건우 on 11/23/23.
//

import SafariServices
import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class GitHubSearchViewController: UIViewController, StoryboardView {
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var disposeBag: DisposeBag = DisposeBag()
    let gitHubSearchViewReactor: GitHubSearchViewReactor = GitHubSearchViewReactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.verticalScrollIndicatorInsets.top = tableView.contentInset.top
        searchController.obscuresBackgroundDuringPresentation = true
        navigationItem.searchController = searchController
        
        bind(reactor: gitHubSearchViewReactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        UIView.setAnimationsEnabled(false)
//        searchController.isActive = true
//        searchController.isActive = false
//        UIView.setAnimationsEnabled(true)
//    }
    
    func bind(reactor: GitHubSearchViewReactor) {
        // Action
        searchController.searchBar.rx.text
            .filter { !($0 == "") }
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let `self` = self else { return false }
                guard self.tableView.frame.height > 0 else { return false }
                // ⭐️ offset.y: 최상단 기준 현재 Y축 스크롤 위치
                // ⭐️ frame.height: 화면에 실제로 보이는 기준 높이
                // ⭐️ contentSize.height: 실제 컨텐츠의 높이(길이)
                return (offset.y + self.tableView.frame.height) >= (self.tableView.contentSize.height - 100)
                // 최하단 Y축 스크롤 위치가 마지막 Y축 위치 대비 -100 위치에 다다르면 다음 페이지 불러오기
            }
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.repos }
            .distinctUntilChanged()
            .bind(to: tableView.rx.items(cellIdentifier: "searchCell")) { indexPath, repo, cell in
                cell.textLabel?.text = repo
            }
            .disposed(by: disposeBag)
        
        // View
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self, weak reactor] indexPath in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                guard let repo = reactor?.currentState.repos[indexPath.row] else { return }
                guard let url = URL(string: "https://github.com/\(repo)") else { return }
                let viewController = SFSafariViewController(url: url)
                self.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }

}
