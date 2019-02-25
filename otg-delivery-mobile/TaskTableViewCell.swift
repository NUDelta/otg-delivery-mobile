//
//  RequestStatusTableViewCell.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 4/30/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "acceptedRequestReuseIdentifier"
    
    let orderLabel = UILabel()
    let statusDetailsLabel = UILabel()
    let expirationDetailsLabel = UILabel()
    let pickupLocationDetailsLabel = UILabel()
    let deliveryLocationDetailsLabel = UILabel()
    let specialRequestsDetailsLabel = UILabel()
    
    let completeOrderButton = UIButton.init(type: .system)
    let pickedUpButton = UIButton.init(type: .system)
    let contactRequesterButton = UIButton.init(type: .system)
    
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
        
        //Edit button
        completeOrderButton.backgroundColor = UIColor.clear
        completeOrderButton.layer.cornerRadius = 1.0;
        completeOrderButton.layer.borderWidth = 0.2;
        completeOrderButton.setTitleColor(self.tintColor, for: .normal)
        completeOrderButton.setTitle("Mark Order as Completed", for: .normal)
        completeOrderButton.translatesAutoresizingMaskIntoConstraints = false
        //editButton.addTarget(self, action: #selector(self.editActionTest), for: .touchUpInside)
        self.addSubview(completeOrderButton)
        
        pickedUpButton.backgroundColor = UIColor.clear
        pickedUpButton.layer.cornerRadius = 1.0;
        pickedUpButton.layer.borderWidth = 0.2;
        pickedUpButton.setTitleColor(self.tintColor, for: .normal)
        pickedUpButton.setTitle("Mark Order as Picked Up", for: .normal)
        pickedUpButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pickedUpButton)
        
        contactRequesterButton.backgroundColor = UIColor.clear
        contactRequesterButton.layer.cornerRadius = 1.0;
        contactRequesterButton.layer.borderWidth = 0.2;
        contactRequesterButton.setTitleColor(self.tintColor, for: .normal)
        contactRequesterButton.setTitle("Contact Requester", for: .normal)
        contactRequesterButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contactRequesterButton)

        
        
        // Order Label
        orderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        orderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(orderLabel)
        
        // Title Labels (left column)
        let statusTitleLabel = UILabel()
        statusTitleLabel.text = "Status:"
        
        let expirationTitleLabel = UILabel()
        expirationTitleLabel.text = "Expiration:"
        
        let pickupLocationTitleLabel = UILabel()
        pickupLocationTitleLabel.text = "Pickup Location:"
        
        let deliveryLocationTitleLabel = UILabel()
        deliveryLocationTitleLabel.text = "Delivery Location:"
        
        let specialRequestsTitleLabel = UILabel()
        specialRequestsTitleLabel.text = "Special Requests:"
        
        let titleLabels = [
            statusTitleLabel,
            expirationTitleLabel,
            pickupLocationTitleLabel,
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
            pickupLocationDetailsLabel,
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
            statusTitleLabel.rightAnchor.constraint(equalTo: statusDetailsLabel.leftAnchor),
            statusTitleLabel.topAnchor.constraint(equalTo: orderLabel.bottomAnchor,
                                                  constant: labelVerticalSpacing),
            
            statusDetailsLabel.rightAnchor.constraint(equalTo: orderLabel.rightAnchor),
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
            
            pickupLocationTitleLabel.leftAnchor.constraint(equalTo: statusTitleLabel.leftAnchor),
            pickupLocationTitleLabel.topAnchor.constraint(equalTo: expirationDetailsLabel.bottomAnchor,constant: labelVerticalSpacing),
            
            pickupLocationDetailsLabel.leftAnchor.constraint(equalTo: pickupLocationTitleLabel.leftAnchor),
            pickupLocationDetailsLabel.rightAnchor.constraint(equalTo: statusDetailsLabel.rightAnchor),
            pickupLocationDetailsLabel.topAnchor.constraint(equalTo: pickupLocationTitleLabel.bottomAnchor),
            pickupLocationDetailsLabel.bottomAnchor.constraint(equalTo: deliveryLocationTitleLabel.topAnchor),
            
            // Location title label and details label
            
            deliveryLocationTitleLabel.leftAnchor.constraint(equalTo: statusTitleLabel.leftAnchor),
            deliveryLocationTitleLabel.topAnchor.constraint(equalTo: pickupLocationDetailsLabel.bottomAnchor,constant: labelVerticalSpacing),
            
            deliveryLocationDetailsLabel.leftAnchor.constraint(equalTo: deliveryLocationTitleLabel.leftAnchor),
            deliveryLocationDetailsLabel.rightAnchor.constraint(equalTo: statusDetailsLabel.rightAnchor),
            deliveryLocationDetailsLabel.topAnchor.constraint(equalTo: deliveryLocationTitleLabel.bottomAnchor),
            deliveryLocationDetailsLabel.bottomAnchor.constraint(equalTo: specialRequestsTitleLabel.topAnchor),
            
            
            // Details title label and details label
            
            specialRequestsTitleLabel.leftAnchor.constraint(equalTo: statusTitleLabel.leftAnchor),
            specialRequestsTitleLabel.topAnchor.constraint(equalTo: deliveryLocationDetailsLabel.bottomAnchor,
                                                           constant: labelVerticalSpacing),
            
            // Set the bottom of the cell (to set the height of the cell) to be the bottom of this label
            
            specialRequestsDetailsLabel.leftAnchor.constraint(equalTo: specialRequestsTitleLabel.leftAnchor),
            specialRequestsDetailsLabel.rightAnchor.constraint(equalTo: statusDetailsLabel.rightAnchor),
            specialRequestsDetailsLabel.topAnchor.constraint(equalTo: specialRequestsTitleLabel.bottomAnchor),
            specialRequestsDetailsLabel.bottomAnchor.constraint(equalTo: pickedUpButton.topAnchor, constant: -10),
            
//            // Button constraints
            pickedUpButton.bottomAnchor.constraint(equalTo: completeOrderButton.topAnchor, constant: -5),
            pickedUpButton.leftAnchor.constraint(equalTo: specialRequestsTitleLabel.leftAnchor),
            pickedUpButton.rightAnchor.constraint(equalTo: specialRequestsDetailsLabel.rightAnchor),
            pickedUpButton.topAnchor.constraint(equalTo: specialRequestsDetailsLabel.bottomAnchor, constant: 10),
            
            completeOrderButton.bottomAnchor.constraint(equalTo: contactRequesterButton.topAnchor, constant: -5),
            completeOrderButton.leftAnchor.constraint(equalTo: specialRequestsTitleLabel.leftAnchor),
            completeOrderButton.rightAnchor.constraint(equalTo: specialRequestsDetailsLabel.rightAnchor),
            completeOrderButton.topAnchor.constraint(equalTo: pickedUpButton.bottomAnchor, constant: 5),
            
            contactRequesterButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            contactRequesterButton.leftAnchor.constraint(equalTo: specialRequestsTitleLabel.leftAnchor),
            contactRequesterButton.rightAnchor.constraint(equalTo: specialRequestsDetailsLabel.rightAnchor),
            contactRequesterButton.topAnchor.constraint(equalTo: completeOrderButton.bottomAnchor, constant: 5),

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
