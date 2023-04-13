//
//  ChatDetailsViewController.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/4/23.
//

import UIKit

open class ChatDetailsViewController : UIViewController {
    
    private var model:ChatDetailsViewModel
    private var detailsContainerView = UIView(frame:.zero)
    private var textResponseContainerView = UIView(frame:.zero)
    public init(parameters:AssistiveChatHostQueryParameters) {
        self.model = ChatDetailsViewModel(queryParameters: parameters, delegate: nil)
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
        if textResponseContainerView.superview != nil {
            textResponseContainerView.removeFromSuperview()
        }
        
        textResponseContainerView = UIView(frame: .zero)
        textResponseContainerView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(textResponseContainerView)
        textResponseContainerView.leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        textResponseContainerView.rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
        textResponseContainerView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        textResponseContainerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        let textResponseViewController = TextResponseViewController(responseString: responseString)
        textResponseContainerView.addSubview(textResponseViewController.view)
        addChild(textResponseViewController)
        textResponseViewController.didMove(toParent: self)
        
        textResponseViewController.view.translatesAutoresizingMaskIntoConstraints = false
        textResponseViewController.view.leftAnchor.constraint(equalTo: textResponseContainerView.leftAnchor).isActive = true
        textResponseViewController.view.rightAnchor.constraint(equalTo: textResponseContainerView.rightAnchor).isActive = true
        textResponseViewController.view.topAnchor.constraint(equalTo: textResponseContainerView.topAnchor).isActive = true
        textResponseViewController.view.bottomAnchor.constraint(equalTo: textResponseContainerView.bottomAnchor).isActive = true

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
        if let response = model.responseString {
            if !detailsContainerView.subviews.contains(textResponseContainerView) {
                buildTextResponseContainerView(with: response, parentView:detailsContainerView)
            }
        }
    }
}
