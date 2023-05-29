//
//  SearchQueryResponseCollectionViewCell.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 5/29/23.
//

import UIKit

open class SearchQueryResponseCollectionViewCell : UICollectionViewCell {
    public var placeSearchResponse:PlaceSearchResponse? {
        didSet {
            if let response = placeSearchResponse {
                updateView(with: response)
            }
        }
    }
    public var textLabel:UILabel = UILabel(frame:.zero)
    internal var textLabelEdgeInsets = UIEdgeInsets(top: 8, left: 56.0, bottom: -8, right: -20.0)

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func buildViews() {
        contentView.backgroundColor = UIColor.systemBackground
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        textLabel.numberOfLines = 0
        textLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: textLabelEdgeInsets.left).isActive = true
        textLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: textLabelEdgeInsets.right).isActive = true
        textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: textLabelEdgeInsets.top).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: textLabelEdgeInsets.bottom).isActive = true
        textLabel.textColor = UIColor.label
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    internal func updateView(with placeSearchResponse:PlaceSearchResponse) {
        textLabel.text = placeSearchResponse.name
    }
}
