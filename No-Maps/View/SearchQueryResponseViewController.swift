//
//  SearchQueryResponseViewController.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 5/27/23.
//

import UIKit

open class SearchQueryResponseViewController : UIViewController {
    
    internal var collectionView: UICollectionView! = nil
    internal var textView = UILabel(frame:.zero)
    internal var model:SearchQueryResponseViewModel
    
    var dataSource: UICollectionViewDiffableDataSource<Section, PlaceSearchResponse>! = nil
    
    enum Section {
        case main
    }
    
    public init(responseString: String, placeSearchResponses:[PlaceSearchResponse]) {
        model = SearchQueryResponseViewModel(responseString:responseString, placeSearchResponses: placeSearchResponses)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        buildTextResponseView(with: model.responseString)
        buildSearchQueryResponseCollectionView()
    }
    
    public func buildTextResponseView(with responseString:String) {
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        textView.text = responseString
        
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.label
        textView.backgroundColor = UIColor.systemBackground
        textView.text = responseString
    }
    
    public func buildSearchQueryResponseCollectionView() {
        configureHierarchy()
        configureDataSource()
        updateResponseView(with: model.responseString, placeSearchResponses: model.placeSearchResponses)
    }
    
    public func updateResponseView(with responseString:String, placeSearchResponses:[PlaceSearchResponse]) {
        model = SearchQueryResponseViewModel(responseString: responseString, placeSearchResponses: placeSearchResponses)
        textView.text = model.responseString
        updateCollectionViewModel()
    }
}

extension SearchQueryResponseViewController {
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension SearchQueryResponseViewController {
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints  = false
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.topAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<SearchQueryResponseCollectionViewCell, PlaceSearchResponse> { (cell, indexPath, item) in
            cell.placeSearchResponse = item
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, PlaceSearchResponse>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: PlaceSearchResponse) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    private func updateCollectionViewModel() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PlaceSearchResponse>()
        snapshot.appendSections([.main])
        snapshot.appendItems(model.placeSearchResponses)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension SearchQueryResponseViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
