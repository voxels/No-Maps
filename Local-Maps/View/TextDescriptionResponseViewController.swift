//
//  TextResponseView.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/4/23.
//

import UIKit
import MapKit
import CoreLocation

open class TextDescriptionResponseViewController : UIViewController {
    public var responseString:String
    private var textView = UITextView(frame: .zero)
    private var targetLocation:CLLocation
    private var nearLocation:CLLocation
    private var mapView:MKMapView = MKMapView(frame: .zero)
    private var placeName:String
    private var edgeInsets:UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: -20, right: -20)
    public init(responseString: String, nearLocation:CLLocation, targetLocation:CLLocation, placeName:String) {
        self.responseString = responseString
        self.targetLocation = targetLocation
        self.nearLocation = nearLocation
        self.placeName = placeName
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        buildMapView(nearLocation:nearLocation, targetLocation:targetLocation, placeName:placeName)
        buildTextResponseView(with: responseString)
    }
        
    internal func buildTextResponseView(with responseString:String) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        let attributedText = NSAttributedString(string: responseString, attributes: [.font:UIFont.systemFont(ofSize: 14.0), .foregroundColor:UIColor.label])
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: edgeInsets.left).isActive = true
        textView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: edgeInsets.top).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: edgeInsets.right).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: edgeInsets.bottom).isActive = true
        textView.attributedText = attributedText
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.label
        textView.backgroundColor = UIColor.systemBackground
    }
    
    internal func buildMapView(nearLocation:CLLocation, targetLocation:CLLocation, placeName:String) {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: (view.frame.size.width) * 2.0 / 3.0).isActive = true
        
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = false
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        
        let pin = MKPointAnnotation()
        pin.title = placeName
        pin.coordinate = targetLocation.coordinate
        mapView.addAnnotation(pin)
        
        let distanceBetween = nearLocation.distance(from: targetLocation)
        let centerCoordinate = CLLocationCoordinate2D(latitude: (targetLocation.coordinate.latitude + nearLocation.coordinate.latitude) / 2.0, longitude: (targetLocation.coordinate.longitude + nearLocation.coordinate.longitude) / 2.0)

        mapView.setRegion(MKCoordinateRegion(center:centerCoordinate, latitudinalMeters: distanceBetween * 1.25, longitudinalMeters: distanceBetween * 1.25), animated: false)
    }
    
    public func updateResponseView(with responseString:String) {
        textView.text = responseString
    }
}
