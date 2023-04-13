//
//  ChatDetailsViewController.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/4/23.
//

import UIKit

public enum ChatDetailsViewControllerError : Error {
    case MissingIntent
}

public protocol ChatDetailsViewControllerDelegate : AnyObject {
    func didTap(textResponse:String)
    func didRequestSearch(for query:String)
}

open class ChatDetailsViewController : UIViewController {
    weak public var delegate:ChatDetailsViewControllerDelegate?
    private var model:ChatDetailsViewModel
    private var detailsContainerView = UIView(frame:.zero)
    private var textResponseContainerView = UIView(frame:.zero)
    private var textResponseViewController:TextResponseViewController?
    private var searchResponseContainerView = UIView(frame:.zero)
    private var searchResponseViewController:SearchResponseViewController?
    public init(parameters:AssistiveChatHostQueryParameters) {
        if let lastIntent = parameters.queryIntents.last {
            self.model = ChatDetailsViewModel(queryParameters: parameters,intent:lastIntent, delegate: nil)
        } else {
            self.model = ChatDetailsViewModel(queryParameters: parameters,intent:AssistiveChatHostIntent(caption: "Ask a different question", intent: .OpenDefault, selectedPlaceSearchResponse: nil, selectedPlaceSearchDetails: nil, placeSearchResponses: [PlaceSearchResponse]()), delegate: nil)
        }
        super.init(nibName: nil, bundle: nil)
        self.model.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        buildContainerView()
    }
    
    private func buildContainerView() {
        detailsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(detailsContainerView)
        detailsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        detailsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        detailsContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        detailsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func buildTextResponseContainerView(with responseString:String, parentView:UIView) {
        removeDetailViewController()
        textResponseContainerView = UIView(frame: .zero)
        textResponseContainerView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(textResponseContainerView)
        textResponseContainerView.leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        textResponseContainerView.rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
        textResponseContainerView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        textResponseContainerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        textResponseViewController = TextResponseViewController(responseString: responseString)
        textResponseContainerView.addSubview(textResponseViewController!.view)
        addChild(textResponseViewController!)
        textResponseViewController!.didMove(toParent: self)
        
        textResponseViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        textResponseViewController!.view.leftAnchor.constraint(equalTo: textResponseContainerView.leftAnchor).isActive = true
        textResponseViewController!.view.rightAnchor.constraint(equalTo: textResponseContainerView.rightAnchor).isActive = true
        textResponseViewController!.view.topAnchor.constraint(equalTo: textResponseContainerView.topAnchor).isActive = true
        textResponseViewController!.view.bottomAnchor.constraint(equalTo: textResponseContainerView.bottomAnchor).isActive = true

    }
    
    private func buildSearchResponseContainerView(with responseString:String, parentView:UIView) {
        removeDetailViewController()
        searchResponseContainerView = UIView(frame: .zero)
        searchResponseContainerView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(searchResponseContainerView)
        searchResponseContainerView.leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        searchResponseContainerView.rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
        searchResponseContainerView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        searchResponseContainerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        searchResponseViewController = SearchResponseViewController(responseString: responseString)
        searchResponseViewController?.delegate = self
        searchResponseContainerView.addSubview(searchResponseViewController!.view)
        addChild(searchResponseViewController!)
        searchResponseViewController!.didMove(toParent: self)
        
        searchResponseViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        searchResponseViewController!.view.leftAnchor.constraint(equalTo: searchResponseContainerView.leftAnchor).isActive = true
        searchResponseViewController!.view.rightAnchor.constraint(equalTo: searchResponseContainerView.rightAnchor).isActive = true
        searchResponseViewController!.view.topAnchor.constraint(equalTo: searchResponseContainerView.topAnchor).isActive = true
        searchResponseViewController!.view.bottomAnchor.constraint(equalTo: searchResponseContainerView.bottomAnchor).isActive = true
    }
    
    private func removeDetailViewController() {
        if textResponseContainerView.superview != nil {
            if let textResponseViewController = textResponseViewController, textResponseViewController.view.superview != nil {
                textResponseViewController.willMove(toParent: nil)
                textResponseViewController.view.removeFromSuperview()
                textResponseViewController.removeFromParent()
            }
            textResponseContainerView.removeFromSuperview()
        }
        
        if searchResponseContainerView.superview != nil {
            if let searchResponseViewController = searchResponseViewController, searchResponseViewController.view.superview != nil {
                searchResponseViewController.willMove(toParent: nil)
                searchResponseViewController.view.removeFromSuperview()
                searchResponseViewController.removeFromParent()
            }
            searchResponseContainerView.removeFromSuperview()
        }
    }
}

extension ChatDetailsViewController {
    public func update(parameters:AssistiveChatHostQueryParameters, responseString:String? = nil ) {
        do {
            try self.model.updateModel(parameters: parameters, responseString: responseString)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ChatDetailsViewController : ChatDetailsViewModelDelegate {
    public func modelDidUpdate() {
        
        switch model.currentIntent.intent {
        case .TellDefault, .OpenDefault, .SearchDefault:
            if let response = model.responseString {
                if !detailsContainerView.subviews.contains(searchResponseContainerView) {
                    buildSearchResponseContainerView(with: response, parentView:detailsContainerView)
                } else {
                    searchResponseViewController?.updateResponseView(with: response)
                }
            }
        default:
            if let response = model.responseString {
                if !detailsContainerView.subviews.contains(textResponseContainerView) {
                    buildTextResponseContainerView(with: response, parentView:detailsContainerView)
                } else {
                    textResponseViewController?.updateResponseView(with: response)
                }
            }
        }
    }
}

extension ChatDetailsViewController : SearchResponseViewControllerDelegate {
    public func requestSearch(for query: String) {
        delegate?.didRequestSearch(for: query)
    }
}
