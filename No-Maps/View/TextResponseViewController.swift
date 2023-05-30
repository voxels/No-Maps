//
//  TextResponseView.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/4/23.
//

import UIKit
import MapKit
import CoreLocation

open class TextResponseViewController : UIViewController {
    public var responseString:String
    private var scrollView = UIScrollView(frame: .zero)
    private var textView = UITextView(frame: .zero)
    private var targetLocation:CLLocation
    private var mapView:MKMapView = MKMapView(frame: .zero)
    private var placeName:String
    private var edgeInsets:UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: -20, right: -20)
    public init(responseString: String, targetLocation:CLLocation, placeName:String) {
        self.responseString = responseString
        self.targetLocation = targetLocation
        self.placeName = placeName
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        buildScrollView()
        buildTextResponseView(with: responseString)
        buildMapView(with: targetLocation, placeName:placeName)
    }
    
    internal func buildScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.backgroundColor = UIColor.systemBackground
        scrollView.contentSize = view.bounds.size
    }
    
    internal func buildTextResponseView(with responseString:String) {
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textView)
        
        let attributedText = NSAttributedString(string: responseString, attributes: [.font:UIFont.systemFont(ofSize: 14.0), .foregroundColor:UIColor.label])
        textView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: edgeInsets.left).isActive = true
        textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: edgeInsets.top).isActive = true
        textView.widthAnchor.constraint(equalToConstant: view.frame.size.width - edgeInsets.left + edgeInsets.right).isActive = true
        textView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: edgeInsets.right).isActive = true
        textView.attributedText = attributedText
        textView.isEditable = false
        textView.isScrollEnabled = false
        
        let rect = textView.sizeThatFits(CGSize(width: floor(view.frame.size.width - edgeInsets.left + edgeInsets.right), height: CGFloat.greatestFiniteMagnitude))
        textView.heightAnchor.constraint(equalToConstant: ceil(rect.height)).isActive = true
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.label
        textView.backgroundColor = UIColor.systemBackground

    }
    
    internal func buildMapView(with targetLocation:CLLocation, placeName:String) {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mapView)
        mapView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: edgeInsets.left).isActive = true
        mapView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: edgeInsets.right).isActive = true
        mapView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: edgeInsets.top).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: (view.frame.size.width - edgeInsets.left + edgeInsets.right) * 2.0 / 3.0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: edgeInsets.bottom).isActive = true
        
        mapView.isScrollEnabled = false
        mapView.isPitchEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.setRegion(MKCoordinateRegion(center: targetLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: false)
        
        let pin = MKPointAnnotation()
        pin.title = placeName
        pin.coordinate = targetLocation.coordinate
        mapView.addAnnotation(pin)
    }
    
    public func updateResponseView(with responseString:String) {
        textView.text = responseString
    }
}
