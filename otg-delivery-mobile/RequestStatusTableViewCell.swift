//
//  RequestStatusTableViewCell.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 4/30/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class RequestStatusTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "requestStatusReuseIdentifier"
    
    let orderLabel = UILabel()
    let statusDetailsLabel = UILabel()
    let expirationDetailsLabel = UILabel()
    let deliveryLocationDetailsLabel = UILabel()
    let specialRequestsDetailsLabel = UILabel()
    
    let deliveryLocationTitleLabel = UILabel()
    
    let contactHelperButton = UIButton.init(type: .system)
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.isUserInteractionEnabled = false;
        
        let subtitleTitleColor = UIColor.darkGray
        let subtitleTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        let subtitleDetailColor = UIColor.lightGray
        let subtitleDetailFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        let labelVerticalSpacing: CGFloat = 5.0
        let labelTopPadding: CGFloat = 10.0
        let labelBottomPadding: CGFloat = 10.0
        
        contactHelperButton.backgroundColor = UIColor.clear
        contactHelperButton.layer.cornerRadius = 1.0;
        contactHelperButton.layer.borderWidth = 0.2;
        contactHelperButton.setTitleColor(self.tintColor, for: .normal)
        contactHelperButton.setTitle("Contact Helper", for: .normal)
        contactHelperButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contactHelperButton)
        
        
        // Order Label
        orderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        orderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(orderLabel)
        
        // Title Labels (left column)
        let statusTitleLabel = UILabel()
        statusTitleLabel.text = "Status:"
        
        let expirationTitleLabel = UILabel()
        expirationTitleLabel.text = "Expiration:"
        
        let specialRequestsTitleLabel = UILabel()
        specialRequestsTitleLabel.text = "Special Requests:"
        
        let titleLabels = [
            statusTitleLabel,
            expirationTitleLabel,
            deliveryLocationTitleLabel,
            specialRequestsTitleLabel
        ]
        
        titleLabels.forEach { label in
            label.font = subtitleTitleFont
            label.textColor = subtitleTitleColor
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        
        // Detail labels (right column - updated with data)
        let detailLabels = [
            statusDetailsLabel,
            expirationDetailsLabel
        ]
        detailLabels.forEach { label in
            label.font = subtitleDetailFont
            label.textColor = subtitleDetailColor
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        
        let deliveryDetailLabels = [
            deliveryLocationDetailsLabel,
            specialRequestsDetailsLabel
        ]
        deliveryDetailLabels.forEach { label in
            label.font = subtitleDetailFont
            label.textColor = subtitleDetailColor
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        
        // Layout Constraints
        let leftMarginConstraint = NSLayoutConstraint(item: orderLabel,
                                                      attribute: .left,
                                                      relatedBy: .equal,
                                                      toItem: self,
                                                      attribute: .leftMargin,
                                                      multiplier: 1.0,
                                                      constant: 0.0)
        
        let rightMarginConstraint = NSLayoutConstraint(item: orderLabel,
                                                       attribute: .right,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .rightMargin,
                                                       multiplier: 1.0,
                                                       constant: 0.0)
        
        
        let constraints = [
            // Order title label
            
            leftMarginConstraint,
            rightMarginConstraint,
            orderLabel.topAnchor.constraint(equalTo: topAnchor, constant: labelTopPadding),
            
            // Status title label and details label
            statusTitleLabel.leftAnchor.constraint(equalTo: orderLabel.leftAnchor, constant: 10),
            statusTitleLabel.rightAnchor.constraint(equalTo: statusDetailsLabel.leftAnchor, constant: -5),
            statusTitleLabel.topAnchor.constraint(equalTo: orderLabel.bottomAnchor,
                                                  constant: labelVerticalSpacing),
            
            statusDetailsLabel.rightAnchor.constraint(equalTo: orderLabel.rightAnchor),
            statusDetailsLabel.leftAnchor.constraint(equalTo: statusTitleLabel.rightAnchor, constant: 5),
            statusDetailsLabel.topAnchor.constraint(equalTo: statusTitleLabel.topAnchor),
            statusDetailsLabel.bottomAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor),
            
            // Expiration title label and details label
            
            expirationTitleLabel.leftAnchor.constraint(equalTo: statusTitleLabel.leftAnchor),
            expirationTitleLabel.rightAnchor.constraint(equalTo: expirationDetailsLabel.leftAnchor),
            expirationTitleLabel.topAnchor.constraint(equalTo: statusDetailsLabel.bottomAnchor,
                                                      constant: labelVerticalSpacing),
            
            expirationDetailsLabel.rightAnchor.constraint(equalTo: statusDetailsLabel.rightAnchor),
            expirationDetailsLabel.topAnchor.constraint(equalTo: expirationTitleLabel.topAnchor),
            expirationDetailsLabel.bottomAnchor.constraint(equalTo: expirationTitleLabel.bottomAnchor),
            
            // Location title label and details label
            
            deliveryLocationTitleLabel.leftAnchor.constraint(equalTo: statusTitleLabel.leftAnchor),
            deliveryLocationTitleLabel.topAnchor.constraint(equalTo: expirationDetailsLabel.bottomAnchor,constant: labelVerticalSpacing),
            
            deliveryLocationDetailsLabel.leftAnchor.constraint(equalTo: deliveryLocationTitleLabel.leftAnchor),
            deliveryLocationDetailsLabel.rightAnchor.constraint(equalTo: statusDetailsLabel.rightAnchor),
            deliveryLocationDetailsLabel.topAnchor.constraint(equalTo: deliveryLocationTitleLabel.bottomAnchor),
            deliveryLocationDetailsLabel.bottomAnchor.constraint(equalTo: specialRequestsTitleLabel.topAnchor, constant: -labelVerticalSpacing),
            
            
            // Details title label and details label
            
            specialRequestsTitleLabel.leftAnchor.constraint(equalTo: statusTitleLabel.leftAnchor),
            specialRequestsTitleLabel.topAnchor.constraint(equalTo: deliveryLocationDetailsLabel.bottomAnchor,
                                                           constant: labelVerticalSpacing),
            
            // Set the bottom of the cell (to set the height of the cell) to be the bottom of this label
            
            specialRequestsDetailsLabel.leftAnchor.constraint(equalTo: specialRequestsTitleLabel.leftAnchor),
            specialRequestsDetailsLabel.rightAnchor.constraint(equalTo: statusDetailsLabel.rightAnchor),
            specialRequestsDetailsLabel.topAnchor.constraint(equalTo: specialRequestsTitleLabel.bottomAnchor),
            specialRequestsDetailsLabel.bottomAnchor.constraint(equalTo: contactHelperButton.topAnchor, constant: -10),
            
            contactHelperButton.leftAnchor.constraint(equalTo: specialRequestsTitleLabel.leftAnchor),
            contactHelperButton.rightAnchor.constraint(equalTo: statusDetailsLabel.rightAnchor),
            contactHelperButton.topAnchor.constraint(equalTo: specialRequestsDetailsLabel.bottomAnchor, constant: 10),
            contactHelperButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
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

