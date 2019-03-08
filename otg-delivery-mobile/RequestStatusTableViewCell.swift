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
    
    let statusDetailsLabel = UILabel()
    let expirationDetailsLabel = UILabel()
    let deliveryLocationDetailsLabel = UILabel()
    let timeFrame1Label = UILabel()
    let probability1Label = UILabel()
    let timeFrame2Label = UILabel()
    let probability2Label = UILabel()
    let timeFrame3Label = UILabel()
    let probability3Label = UILabel()
    let timeFrame4Label = UILabel()
    let probability4Label = UILabel()
    
    // Title label text can change
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
        
        // Title Labels (left column)
        let statusTitleLabel = UILabel()
        statusTitleLabel.text = "Status:"
        
        let expirationTitleLabel = UILabel()
        expirationTitleLabel.text = "Delivery Timeframe:"
        
        let timeProbTitleLabel = UILabel()
        timeProbTitleLabel.text = "% Requests Typically Completed:"
        
        let titleLabels = [
            statusTitleLabel,
            expirationTitleLabel,
            deliveryLocationTitleLabel,
            timeProbTitleLabel
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
            timeFrame1Label,
            timeFrame2Label,
            timeFrame3Label,
            timeFrame4Label
        ]
        deliveryDetailLabels.forEach { label in
            label.font = subtitleDetailFont
            label.textColor = subtitleDetailColor
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        
        let probabilityLabels = [
            probability1Label,
            probability2Label,
            probability3Label,
            probability4Label,
        ]
        probabilityLabels.forEach { label in
            label.font = subtitleDetailFont
            label.textColor = subtitleDetailColor
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        
        // Layout Constraints
        let leftMarginConstraint = NSLayoutConstraint(item: statusTitleLabel,
                                                      attribute: .left,
                                                      relatedBy: .equal,
                                                      toItem: self,
                                                      attribute: .leftMargin,
                                                      multiplier: 1.0,
                                                      constant: 0.0)
        
        let rightMarginConstraint = NSLayoutConstraint(item: statusTitleLabel,
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
            
            // Status title label and details label
            statusTitleLabel.topAnchor.constraint(equalTo: topAnchor,
                                                  constant: labelTopPadding),
            
            statusDetailsLabel.topAnchor.constraint(equalTo: statusTitleLabel.topAnchor),
            statusDetailsLabel.rightAnchor.constraint(equalTo: rightAnchor),
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
            deliveryLocationDetailsLabel.bottomAnchor.constraint(equalTo: timeProbTitleLabel.topAnchor, constant: -labelVerticalSpacing),
            
            timeProbTitleLabel.leftAnchor.constraint(equalTo: statusTitleLabel.leftAnchor),
            timeProbTitleLabel.topAnchor.constraint(equalTo: deliveryLocationDetailsLabel.bottomAnchor, constant: labelVerticalSpacing),
            
            timeFrame1Label.leftAnchor.constraint(equalTo: timeProbTitleLabel.leftAnchor),
            timeFrame1Label.rightAnchor.constraint(equalTo: probability1Label.leftAnchor),
            timeFrame1Label.topAnchor.constraint(equalTo: timeProbTitleLabel.bottomAnchor, constant: labelVerticalSpacing),
            timeFrame1Label.bottomAnchor.constraint(equalTo: timeFrame2Label.topAnchor, constant: -10),
            
            probability1Label.leftAnchor.constraint(equalTo: statusDetailsLabel.leftAnchor),
            probability1Label.rightAnchor.constraint(equalTo: timeProbTitleLabel.rightAnchor),
            probability1Label.topAnchor.constraint(equalTo: timeFrame1Label.topAnchor),
            probability1Label.bottomAnchor.constraint(equalTo: timeFrame2Label.topAnchor, constant: -10),
            
            timeFrame2Label.leftAnchor.constraint(equalTo: timeProbTitleLabel.leftAnchor),
            timeFrame2Label.rightAnchor.constraint(equalTo: timeProbTitleLabel.rightAnchor),
            timeFrame2Label.topAnchor.constraint(equalTo: probability1Label.bottomAnchor),
            timeFrame2Label.bottomAnchor.constraint(equalTo: timeFrame3Label.topAnchor, constant: -10),
            
            probability2Label.leftAnchor.constraint(equalTo: statusDetailsLabel.leftAnchor),
            probability2Label.rightAnchor.constraint(equalTo: timeProbTitleLabel.rightAnchor),
            probability2Label.topAnchor.constraint(equalTo: timeFrame2Label.topAnchor),
            probability2Label.bottomAnchor.constraint(equalTo: timeFrame3Label.topAnchor, constant: -10),
            
            timeFrame3Label.leftAnchor.constraint(equalTo: timeProbTitleLabel.leftAnchor),
            timeFrame3Label.rightAnchor.constraint(equalTo: timeProbTitleLabel.rightAnchor),
            timeFrame3Label.topAnchor.constraint(equalTo: timeFrame2Label.bottomAnchor),
            timeFrame3Label.bottomAnchor.constraint(equalTo: timeFrame4Label.topAnchor, constant: -10),
            
            probability3Label.leftAnchor.constraint(equalTo: statusDetailsLabel.leftAnchor),
            probability3Label.rightAnchor.constraint(equalTo: timeProbTitleLabel.rightAnchor),
            probability3Label.topAnchor.constraint(equalTo: timeFrame3Label.topAnchor),
            probability3Label.bottomAnchor.constraint(equalTo: timeFrame4Label.topAnchor, constant: -10),
            
            timeFrame4Label.leftAnchor.constraint(equalTo: timeProbTitleLabel.leftAnchor),
            timeFrame4Label.rightAnchor.constraint(equalTo: timeProbTitleLabel.rightAnchor),
            timeFrame4Label.topAnchor.constraint(equalTo: timeFrame3Label.bottomAnchor),
            timeFrame4Label.bottomAnchor.constraint(equalTo: contactHelperButton.topAnchor, constant: -10),
            
            probability4Label.leftAnchor.constraint(equalTo: statusDetailsLabel.leftAnchor),
            probability4Label.rightAnchor.constraint(equalTo: timeProbTitleLabel.rightAnchor),
            probability4Label.topAnchor.constraint(equalTo: timeFrame4Label.topAnchor),
            probability4Label.bottomAnchor.constraint(equalTo: contactHelperButton.topAnchor, constant: -10),
            
            contactHelperButton.leftAnchor.constraint(equalTo: deliveryLocationTitleLabel.leftAnchor),
            contactHelperButton.rightAnchor.constraint(equalTo: statusDetailsLabel.rightAnchor),
            contactHelperButton.topAnchor.constraint(equalTo: timeFrame4Label.bottomAnchor, constant: 10),
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

