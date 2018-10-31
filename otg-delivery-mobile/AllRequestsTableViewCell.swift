//
//  AllRequests.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 10/8/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class AllRequestsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "allRequestsReuseIdentifier"
    
    let pickupDetailsLabel = UILabel()
    let dropoffDetailsLabel = UILabel()
    let expirationDetailsLabel = UILabel()
    let requesterDetailsLabel = UILabel()
    let itemDetailsLabel = UILabel()
    let priceDetailsLabel = UILabel()
    
    
    
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Set font details
        let detailColor = UIColor.darkGray
        let detailFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        let titleColor = UIColor.lightGray
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        let summaryDetailFont = UIFont.systemFont(ofSize: 9, weight: .semibold)
        
        let summaryTitleFont = UIFont.systemFont(ofSize: 9, weight: .semibold)
        
        
        
        // Set spacing
        let labelTopPadding: CGFloat = 10.0    
        
        
        // Title labels (left column)
        let pickupTitleLabel = UILabel()
        pickupTitleLabel.text = "pickup"
        
        let dropoffTitleLabel = UILabel()
        dropoffTitleLabel.text = "dropoff"
        
        let expirationTitleLabel = UILabel()
        expirationTitleLabel.text = "expiration"
        
        let summaryTitleLabel = UILabel()
        summaryTitleLabel.text = "summary"
        
        let titleLabels = [
            pickupTitleLabel,
            dropoffTitleLabel,
            expirationTitleLabel,
            summaryTitleLabel
        ]
        
        titleLabels.forEach { label in
            label.font = titleFont
            label.textColor = titleColor
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        
        
        
        
        // Detail labels (right column, updated with data)
        let detailLabels = [
            pickupDetailsLabel,
            dropoffDetailsLabel,
            expirationDetailsLabel,
        ]
        
        detailLabels.forEach { label in
            label.font = detailFont
            label.textColor = detailColor
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        
        
        // Summary title labels
        let requesterTitleLabel = UILabel()
        requesterTitleLabel.text = "requester"
        
        let itemTitleLabel = UILabel()
        itemTitleLabel.text = "item"
        
        let priceTitleLabel = UILabel()
        priceTitleLabel.text = "price"
        
        let summaryTitleLabels = [
            requesterTitleLabel,
            itemTitleLabel,
            priceTitleLabel,
        ]
        
        summaryTitleLabels.forEach { label in
            label.font = summaryTitleFont
            label.textColor = titleColor
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        
        
        
        
        
        // Summary details labels
        let summaryDetailLabels = [
            requesterDetailsLabel,
            itemDetailsLabel,
            priceDetailsLabel,
        ]
        
        summaryDetailLabels.forEach { label in
            label.font = summaryDetailFont
            label.textColor = detailColor
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        
        
        
        // Layout constraints
        let leftMargin = NSLayoutConstraint(item: pickupTitleLabel,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .leftMargin,
                                            multiplier: 1.0,
                                            constant: 0.0)
        
        let rightMargin = NSLayoutConstraint(item: pickupDetailsLabel,
                                             attribute: .right,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .rightMargin,
                                             multiplier: 1.0,
                                             constant: 0.0)
        
        let constraints = [
            // Pickup Constraints
            leftMargin,
            pickupTitleLabel.rightAnchor.constraint(equalTo: leftAnchor, constant: 80),
            pickupTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: labelTopPadding),
            
            
            //pickupDetailsLabel.rightAnchor.constraint(equalTo: rightMargin),
            rightMargin,
            pickupDetailsLabel.topAnchor.constraint(equalTo: pickupTitleLabel.topAnchor),
            pickupDetailsLabel.bottomAnchor.constraint(equalTo: pickupTitleLabel.bottomAnchor),
            
            
            
            //Dropoff Constraints
            dropoffTitleLabel.leftAnchor.constraint(equalTo: pickupTitleLabel.leftAnchor),
            dropoffTitleLabel.rightAnchor.constraint(equalTo: pickupTitleLabel.rightAnchor),
            dropoffTitleLabel.topAnchor.constraint(equalTo: pickupTitleLabel.bottomAnchor, constant: 5),
            
            dropoffDetailsLabel.rightAnchor.constraint(equalTo: pickupDetailsLabel.rightAnchor),
            dropoffDetailsLabel.leftAnchor.constraint(equalTo: dropoffTitleLabel.rightAnchor, constant: 10),
            dropoffDetailsLabel.topAnchor.constraint(equalTo: dropoffTitleLabel.topAnchor),
            dropoffDetailsLabel.bottomAnchor.constraint(equalTo: expirationTitleLabel.topAnchor, constant: -5),
            
            
            
            // Expiration Constraints
            expirationTitleLabel.leftAnchor.constraint(equalTo: pickupTitleLabel.leftAnchor),
            expirationTitleLabel.topAnchor.constraint(equalTo: dropoffTitleLabel.bottomAnchor, constant: 5),
            
            expirationDetailsLabel.rightAnchor.constraint(equalTo: pickupDetailsLabel.rightAnchor),
            expirationDetailsLabel.topAnchor.constraint(equalTo: expirationTitleLabel.topAnchor),
            expirationDetailsLabel.bottomAnchor.constraint(equalTo: expirationTitleLabel.bottomAnchor),
            
            
            
            // Summary Constraints
            summaryTitleLabel.leftAnchor.constraint(equalTo: pickupTitleLabel.leftAnchor),
            summaryTitleLabel.topAnchor.constraint(equalTo: expirationTitleLabel.bottomAnchor, constant: 5),
            
            
            
            // Requester Constraints
            requesterTitleLabel.leftAnchor.constraint(equalTo: summaryTitleLabel.rightAnchor, constant: 10),
            requesterTitleLabel.topAnchor.constraint(equalTo: summaryTitleLabel.topAnchor),
            requesterTitleLabel.bottomAnchor.constraint(equalTo: summaryTitleLabel.bottomAnchor),
            
            requesterDetailsLabel.rightAnchor.constraint(equalTo: pickupDetailsLabel.rightAnchor),
            requesterDetailsLabel.leftAnchor.constraint(equalTo: requesterTitleLabel.rightAnchor, constant: 10),
            requesterDetailsLabel.topAnchor.constraint(equalTo: requesterTitleLabel.topAnchor),
            requesterDetailsLabel.bottomAnchor.constraint(equalTo: requesterTitleLabel.bottomAnchor),
            
            // Price Constraints
            priceTitleLabel.leftAnchor.constraint(equalTo: summaryTitleLabel.rightAnchor, constant: 10),
            priceTitleLabel.topAnchor.constraint(equalTo: requesterTitleLabel.bottomAnchor),
            
            priceDetailsLabel.rightAnchor.constraint(equalTo: pickupDetailsLabel.rightAnchor),
            priceDetailsLabel.topAnchor.constraint(equalTo: priceTitleLabel.topAnchor),
            priceDetailsLabel.bottomAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor),
            
            // Item Constraints
            itemTitleLabel.leftAnchor.constraint(equalTo: summaryTitleLabel.rightAnchor, constant: 10),
            itemTitleLabel.rightAnchor.constraint(equalTo: itemTitleLabel.leftAnchor, constant: 30),
            itemTitleLabel.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor),
            
            itemDetailsLabel.rightAnchor.constraint(equalTo: pickupDetailsLabel.rightAnchor),
            itemDetailsLabel.leftAnchor.constraint(equalTo: itemTitleLabel.rightAnchor, constant: 10),
            itemDetailsLabel.topAnchor.constraint(equalTo: itemTitleLabel.topAnchor),
            itemDetailsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
