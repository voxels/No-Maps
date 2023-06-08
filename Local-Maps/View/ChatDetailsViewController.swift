//
//  ChatDetailsViewController.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/4/23.
//

import UIKit
import CoreLocation

public enum ChatDetailsViewControllerError : Error {
    case MissingIntent
}

public protocol ChatDetailsViewControllerDelegate : AnyObject {
    func didTap(textResponse:String)
    func didRequestSearch(for query:String)
    func detailsViewTargetLocation()->CLLocation
}

open class ChatDetailsViewController : UIViewController {
    weak public var delegate:ChatDetailsViewControllerDelegate?
    public var model:ChatDetailsViewModel
    private var detailsContainerView = UIView(frame:.zero)
    private var responseContainerView = UIView(frame:.zero)
    private var textResponseViewController:TextResponseViewController?
    private var searchResponseViewController:SearchResponseViewController?
    private var searchQueryResponseViewController:SearchQueryResponseViewController?
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
    
    private func buildResponseContainerView(parentView:UIView) {
        responseContainerView = UIView(frame: .zero)
        responseContainerView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(responseContainerView)
        responseContainerView.leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        responseContainerView.rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
        responseContainerView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        responseContainerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }

    
    private func buildTextResponseContainerView(with responseString:String, placeSearchResponse:PlaceSearchResponse, parentView:UIView) {

        buildResponseContainerView(parentView: parentView)
        
        textResponseViewController = TextResponseViewController(responseString: responseString, targetLocation:CLLocation(latitude: placeSearchResponse.latitude, longitude: placeSearchResponse.longitude), placeName: placeSearchResponse.name)
        responseContainerView.addSubview(textResponseViewController!.view)
        addChild(textResponseViewController!)
        textResponseViewController!.didMove(toParent: self)
        
        textResponseViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        textResponseViewController!.view.leftAnchor.constraint(equalTo: responseContainerView.leftAnchor).isActive = true
        textResponseViewController!.view.rightAnchor.constraint(equalTo: responseContainerView.rightAnchor).isActive = true
        textResponseViewController!.view.topAnchor.constraint(equalTo: responseContainerView.topAnchor).isActive = true
        textResponseViewController!.view.bottomAnchor.constraint(equalTo: responseContainerView.bottomAnchor).isActive = true

    }
    
    private func buildSearchResponseContainerView(with responseString:String, parentView:UIView) {

        buildResponseContainerView(parentView: parentView)
        
        searchResponseViewController = SearchResponseViewController(responseString: responseString)
        searchResponseViewController?.delegate = self
        responseContainerView.addSubview(searchResponseViewController!.view)
        addChild(searchResponseViewController!)
        searchResponseViewController!.didMove(toParent: self)
        
        searchResponseViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        searchResponseViewController!.view.leftAnchor.constraint(equalTo: responseContainerView.leftAnchor).isActive = true
        searchResponseViewController!.view.rightAnchor.constraint(equalTo: responseContainerView.rightAnchor).isActive = true
        searchResponseViewController!.view.topAnchor.constraint(equalTo: responseContainerView.topAnchor).isActive = true
        searchResponseViewController!.view.bottomAnchor.constraint(equalTo: responseContainerView.bottomAnchor).isActive = true
    }
    
    private func buildSearchQueryResponseContainerView(with responseString:String, placeDetailsResponses:[PlaceDetailsResponse], targetLocation:CLLocation, parentView:UIView) {

        buildResponseContainerView(parentView: parentView)
        
        searchQueryResponseViewController = SearchQueryResponseViewController(responseString: responseString, placeDetailsResponses: placeDetailsResponses, targetLocation:targetLocation )
        responseContainerView.addSubview(searchQueryResponseViewController!.view)
        addChild(searchQueryResponseViewController!)
        searchQueryResponseViewController!.didMove(toParent: self)
        
        searchQueryResponseViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        searchQueryResponseViewController!.view.leftAnchor.constraint(equalTo: responseContainerView.leftAnchor).isActive = true
        searchQueryResponseViewController!.view.rightAnchor.constraint(equalTo: responseContainerView.rightAnchor).isActive = true
        searchQueryResponseViewController!.view.topAnchor.constraint(equalTo: responseContainerView.topAnchor).isActive = true
        searchQueryResponseViewController!.view.bottomAnchor.constraint(equalTo: responseContainerView.bottomAnchor).isActive = true

    }
    
    
    private func removeDetailViewController() {
        if responseContainerView.superview != nil {
            if let textResponseViewController = textResponseViewController, textResponseViewController.view.superview != nil {
                textResponseViewController.willMove(toParent: nil)
                textResponseViewController.view.removeFromSuperview()
                textResponseViewController.removeFromParent()
            }

            if let searchResponseViewController = searchResponseViewController, searchResponseViewController.view.superview != nil {
                searchResponseViewController.willMove(toParent: nil)
                searchResponseViewController.view.removeFromSuperview()
                searchResponseViewController.removeFromParent()
            }
            
            if let searchQueryResponseViewController = searchQueryResponseViewController, searchQueryResponseViewController.view.superview != nil {
                searchQueryResponseViewController.willMove(toParent: nil)
                searchQueryResponseViewController.view.removeFromSuperview()
                searchQueryResponseViewController.removeFromParent()
            }            
            
            responseContainerView.removeFromSuperview()
        }
    }
}

extension ChatDetailsViewController {
    
    public func willUpdateModel() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [unowned self] in
                self.willUpdateModel()
            }
            return
        }
        
        removeDetailViewController()
    }
    
    public func update(parameters:AssistiveChatHostQueryParameters, responseString:String? = nil, placeSearchResponses:[PlaceSearchResponse] = [PlaceSearchResponse](), nearLocation:CLLocation ) {
        let _ = Task.detached(priority: .userInitiated) {
            do {
                try await self.model.updateModel(parameters: parameters, responseString: responseString, placeSearchResponses: placeSearchResponses, nearLocation: nearLocation)
            } catch {
                print(error)
                DispatchQueue.main.async { [weak self] in
                    self?.modelDidUpdate()
                }
            }
        }
    }
}

extension ChatDetailsViewController : ChatDetailsViewModelDelegate {
    public func modelDidUpdate() {
        guard let delegate = delegate else {
            return
        }
        switch model.currentIntent.intent {
        case .TellDefault, .OpenDefault, .SearchDefault:
            if let response = model.responseString {
                if !detailsContainerView.subviews.contains(responseContainerView) {
                    buildSearchResponseContainerView(with: response, parentView:detailsContainerView)
                }
                searchResponseViewController?.updateResponseView(with: response, placeDetailsResponses: model.placeDetailsResponses)
            }
        case .SearchQuery:
            if let response = model.responseString {
                if !detailsContainerView.subviews.contains(responseContainerView) {
                    buildSearchQueryResponseContainerView(with: response, placeDetailsResponses: model.placeDetailsResponses, targetLocation: delegate.detailsViewTargetLocation(), parentView:detailsContainerView)
                }
                searchQueryResponseViewController?.updateResponseView(with: response, placeDetailsResponses: model.placeDetailsResponses, targetLocation: delegate.detailsViewTargetLocation())
                searchQueryResponseViewController?.updateMapView(with: model.placeDetailsResponses, targetLocation: delegate.detailsViewTargetLocation())
            }
        default:
            if let response = model.responseString, let selectedPlaceSearchResponse = model.currentIntent.selectedPlaceSearchResponse {
                if !detailsContainerView.subviews.contains(responseContainerView) {
                    buildTextResponseContainerView(with: response, placeSearchResponse: selectedPlaceSearchResponse, parentView:detailsContainerView)
                }
                textResponseViewController?.updateResponseView(with: response)
            }
        }
    }
}

extension ChatDetailsViewController : SearchResponseViewControllerDelegate {
    public func requestSearch(for query: String) {
        delegate?.didRequestSearch(for: query)
    }
}
