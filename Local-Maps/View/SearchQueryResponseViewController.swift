//
//  SearchQueryResponseViewController.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 5/27/23.
//

import UIKit
import MapKit

open class SearchQueryResponseViewController : UIViewController {
    internal var collectionView: UICollectionView! = nil
    internal var textView = UILabel(frame:.zero)
    internal var mapView = MKMapView(frame: .zero)
    internal var mapViewAnnotations = [MKAnnotation]()
    internal var model:SearchQueryResponseViewModel
    
    var dataSource: UICollectionViewDiffableDataSource<Section, PlaceDetailsResponse>! = nil
    
    enum Section {
        case main
    }
    
    public init(responseString: String, placeDetailsResponses:[PlaceDetailsResponse], targetLocation:CLLocation) {
        model = SearchQueryResponseViewModel(responseString:responseString, placeDetailsResponses: placeDetailsResponses, targetLocation: targetLocation)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        buildMapView()
        buildSearchQueryResponseCollectionView()
        buildTextResponseView(with: model.responseString)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
    }
    
    public func buildTextResponseView(with responseString:String) {
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 20).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        textView.text = responseString
        
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.label
        textView.backgroundColor = UIColor.systemBackground
        textView.text = responseString
    }
        
    public func buildMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: view.frame.size.width * 2.0 / 3.0).isActive = true
        mapView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        
        updateMapView(with: model.placeDetailsResponses, targetLocation: model.targetLocation)
    }

    public func updateMapView(with placeDetailsResponses:[PlaceDetailsResponse], targetLocation:CLLocation) {
        mapView.removeAnnotations(mapViewAnnotations)
        mapViewAnnotations.removeAll()
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = false
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.showsCompass = false

        mapView.setRegion(MKCoordinateRegion(center: targetLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: false)
                
        for index in 0..<placeDetailsResponses.count {
            let response = placeDetailsResponses[index]
            let pin = MKPointAnnotation()
            pin.title = "\(response.searchResponse.name)"
            pin.coordinate = CLLocationCoordinate2D(latitude: response.searchResponse.latitude, longitude: response.searchResponse.longitude)
            mapView.addAnnotation(pin)
            mapViewAnnotations.append(pin)
        }
    }
    
    public func buildSearchQueryResponseCollectionView() {
        configureHierarchy()
        configureDataSource()
        updateResponseView(with: model.responseString, placeDetailsResponses: model.placeDetailsResponses, targetLocation: model.targetLocation)
    }
    
    public func updateResponseView(with responseString:String, placeDetailsResponses:[PlaceDetailsResponse], targetLocation:CLLocation) {
        model = SearchQueryResponseViewModel(responseString: responseString, placeDetailsResponses: placeDetailsResponses, targetLocation: targetLocation)
        textView.text = model.responseString
        updateCollectionViewModel()
    }
}

extension SearchQueryResponseViewController {
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance:.plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension SearchQueryResponseViewController {
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints  = false
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8.0).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<SearchQueryResponseCollectionViewCell, PlaceDetailsResponse> { [weak self] (cell, indexPath, item) in
            cell.placeDetailsResponse = item
            let index = self?.model.placeDetailsResponses.firstIndex(of: item) ?? indexPath.row
            cell.updateView(with: item, index:index)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, PlaceDetailsResponse>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: PlaceDetailsResponse) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
    
    private func updateCollectionViewModel() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PlaceDetailsResponse>()
        snapshot.appendSections([.main])
        snapshot.appendItems(model.placeDetailsResponses)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension SearchQueryResponseViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
