//
//  TextResponseView.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/4/23.
//

import UIKit

open class TextResponseViewController : UIViewController {
    public var responseString:String
    var textView = UITextView(frame: .zero)
    public init(responseString: String) {
        self.responseString = responseString
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
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        textView.text = responseString
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.label
        textView.backgroundColor = UIColor.systemBackground
    }
    
    public func updateResponseView(with responseString:String) {
        textView.text = responseString
    }
}
