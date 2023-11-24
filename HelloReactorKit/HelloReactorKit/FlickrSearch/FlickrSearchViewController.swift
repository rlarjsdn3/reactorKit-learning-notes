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

final class FlickrSearchViewController: UIViewController, StoryboardView {
    @IBOutlet weak var collectionView: UICollectionView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var disposeBag: DisposeBag = DisposeBag()
    let flickrSearchViewReactor: FlickrSearchViewReactor = FlickrSearchViewReactor()
    
    private struct Identifier {
        static var imageCell: String = "imageCell"
        static var tempCell: String = "tempCell"
        static var goToDetailVC: String = "goToDetailVC"
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.goToDetailVC {
            let detailVC = segue.destination as! DetailViewController
            if let imageUrl = sender as? URL {
                detailVC.loadViewIfNeeded() // ⭐️ 뷰가 메모리에 로드되기도 전에 imageView에 접근하고 있으므로, 가능하면 미리 로드해야 에러가 안남.
                detailVC.imageUrl = imageUrl
            }
        }
    }
    
    private func configureUI() {
        navigationItem.searchController = searchController
        
        searchController.searchBar.placeholder = "이미지 이름 검색"
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    private func configureLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 2.0
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 2.0, bottom: 0.0, right: 2.0)
        
        collectionView.collectionViewLayout = layout
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: FlickrSearchViewReactor) {
        // Action
        searchController.searchBar.rx.text
            .orEmpty
            .filter { !$0.isEmpty }
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.searchQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Photo.self)
            .withUnretained(self)
            .subscribe {
                $0.0.performSegue(withIdentifier: Identifier.goToDetailVC, sender: $0.1.imageUrl)
            }
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.photoList }
            .bind(to: collectionView.rx.items(cellIdentifier: Identifier.imageCell, cellType: ImageCell.self)) { index, item, cell in
                cell.imageUrl = item.imageUrl
            }
            .disposed(by: disposeBag)
    }

}

extension FlickrSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
        
        let width = (collectionView.frame.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * Metrics.columns - 1.0))) / (Metrics.columns)
        let height = width
        
        return CGSize(width: width, height: height)
    }
}
