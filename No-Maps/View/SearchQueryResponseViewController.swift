//
//  SearchQueryResponseViewController.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 5/27/23.
//

import UIKit

open class SearchQueryResponseViewController : UIViewController {
    public var responseString:String
    public var placeSearchResponses:[PlaceSearchResponse]
    
    var textView = UILabel(frame:.zero)
    public init(responseString: String, placeSearchResponses:[PlaceSearchResponse]) {
        self.responseString = responseString
        self.placeSearchResponses = placeSearchResponses
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.buildTextResponseView(with: self.responseString)
    }
    
    public func buildTextResponseView(with responseString:String) {
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
                
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        textView.text = responseString
        
        let height = textView.sizeThatFits(CGSize(width: view.frame.size.width - 40, height: CGFloat.infinity)).height
        textView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.label
        textView.backgroundColor = UIColor.systemBackground
    }
    
    public func updateResponseView(with responseString:String, placeSearchResponses:[PlaceSearchResponse]) {
        textView.text = responseString
    }
}

