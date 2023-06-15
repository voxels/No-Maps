//
//  TextResponseView.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/4/23.
//

import UIKit

public protocol SearchResponseViewControllerDelegate : AnyObject {
    func requestSearch(for query:String)
}

open class SearchResponseViewController : UIViewController {
    public weak var delegate:SearchResponseViewControllerDelegate?
    private let searchBarContainerViewHeight:CGFloat = 48 + 16
    public var responseString:String
    private var searchBarContainerView:UIView = UIView(frame:.zero)
    private var searchBarTextField:UISearchTextField?
    public init(responseString: String) {
        self.responseString = responseString
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        buildSearchBarContainerView(with: responseString)
    }
    
    public func buildSearchBarContainerView(with responseString:String) {
        searchBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBarContainerView)
        searchBarContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBarContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchBarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBarContainerView.heightAnchor.constraint(equalToConstant:searchBarContainerViewHeight).isActive = true
        
        searchBarTextField = UISearchTextField(frame: .zero, primaryAction: UIAction(title: "Search", handler: { [weak self] action in
            if let text = self?.searchBarTextField?.text {
                self?.delegate?.requestSearch(for: text)
            }
            
            self?.searchBarTextField?.resignFirstResponder()
        }))
        searchBarTextField?.translatesAutoresizingMaskIntoConstraints = false
        searchBarContainerView.addSubview(searchBarTextField!)
        searchBarTextField!.leftAnchor.constraint(equalTo: searchBarContainerView.leftAnchor, constant: 20.0).isActive = true
        searchBarTextField!.rightAnchor.constraint(equalTo: searchBarContainerView.rightAnchor, constant: -20.0).isActive = true
        searchBarTextField!.topAnchor.constraint(equalTo: searchBarContainerView.topAnchor, constant: 8.0).isActive = true
        searchBarTextField!.bottomAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor, constant: -8.0).isActive = true
        searchBarTextField?.placeholder = responseString
        searchBarTextField?.text = responseString
    }
    
    public func updateResponseView(with responseString:String) {
        searchBarTextField?.placeholder = responseString
        searchBarTextField?.text = responseString
    }
    
    public func updateResponseView(with responseString:String, placeDetailsResponses:[PlaceDetailsResponse] ) {
        print("Updating response view with response:\(responseString)")
        for response in placeDetailsResponses {
            print(response.searchResponse.name)
            print(response.searchResponse.address)
            print(response.searchResponse.categories)
        }
    }
    
}
