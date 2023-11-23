//
//  FlickrSearchViewController.swift
//  HelloReactorKit
//
//  Created by 김건우 on 11/23/23.
//

import UIKit

import Kingfisher
import ReactorKit
import RxCocoa
import RxSwift

class FlickrSearchViewController: UIViewController, StoryboardView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var disposeBag: DisposeBag = DisposeBag()
    let flickrSearchViewReactor: FlickrSearchViewReactor = FlickrSearchViewReactor()
    
    private struct Metrics {
        static var spacing: CGFloat = 2.0
        static var columns: CGFloat = 3.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureLayout()
        
        bind(reactor: flickrSearchViewReactor)
    }
    
    private func configureUI() {
        searchController.searchBar.placeholder = "이미지 이름 검색"
        searchController.hidesNavigationBarDuringPresentation = false
    
        navigationItem.searchController = searchController
    }
    
    private func configureLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 2.0
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 2.0, bottom: 0.0, right: 2.0)
        
        collectionView.collectionViewLayout = layout
        collectionView.rx.setDelegate(self)
    }
    
    func bind(reactor: FlickrSearchViewReactor) {
        // Action
        searchController.searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.searchQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.photoList }
            .bind(to: collectionView.rx.items(cellIdentifier: "tempCell", cellType: TempCell.self)) { index, item, cell in
                cell.label.text = item.title
                cell.backgroundColor = UIColor.systemMint
            }
            .disposed(by: disposeBag)
    }

}

//extension FlickrSearchViewReactor: UIScrollViewDelegate { }

extension FlickrSearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
        
        let width = (collectionView.frame.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * Metrics.columns - 1.0))) / (Metrics.columns)
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
}
