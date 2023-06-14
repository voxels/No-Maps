//
//  SearchQueryResponseCollectionViewCell.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 5/29/23.
//

import UIKit

open class SearchQueryResponseCollectionViewCell : UICollectionViewCell {
    public var placeDetailsResponse:PlaceDetailsResponse?
    
    internal var textLabel:UILabel = UILabel(frame:.zero)
    internal var textLabelEdgeInsets = UIEdgeInsets(top: 8, left: 28.0, bottom: -8, right: -20.0)
    internal var indexLabel:UILabel = UILabel(frame:.zero)

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
        
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        indexLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        indexLabel.textColor = .label
        contentView.addSubview(indexLabel)
        indexLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        indexLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.text = ""
        indexLabel.text = ""
        
    }
    
    internal func updateView(with placeDetailsResponse:PlaceDetailsResponse, index:Int) {
        let rating = placeDetailsResponse.rating
        if rating > 0 {
            textLabel.text = "\(placeDetailsResponse.searchResponse.name) is rated \(placeDetailsResponse.rating)."
        } else {
            textLabel.text = "\(placeDetailsResponse.searchResponse.name) is not rated."
        }
        
        indexLabel.text = "\(index + 1)"
    }
}
