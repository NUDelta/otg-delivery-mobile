//
//  RequestStatusTableViewCell.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 4/30/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class RequesterTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let reuseIdentifier = "requestStatusReuseIdentifier"

    let itemDetailsLabel = UILabel()
    let locationDetailsLabel = UILabel()
    let contactHelperButton = UIButton.init(type: .system)

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.isUserInteractionEnabled = false
        self.clipsToBounds = true

        let subtitleTitleColor = UIColor.darkGray
        let subtitleTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)

        let labels = [
            itemDetailsLabel,
            locationDetailsLabel
        ]

        labels.forEach { label in
            label.font = subtitleTitleFont
            label.textColor = subtitleTitleColor
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            addSubview(label)
        }
        addContactHelperButton()
        addConstraints()
    }

    func addContactHelperButton() {
        contactHelperButton.backgroundColor = UIColor.clear
        contactHelperButton.setTitleColor(self.tintColor, for: .normal)
        contactHelperButton.setTitle("Contact Helper", for: .normal)
        contactHelperButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contactHelperButton)
    }
    
    func addConstraints() {
        let topMarginConstraint = NSLayoutConstraint(item: itemDetailsLabel,
                                                     attribute: .top,
                                                     relatedBy: .equal,
                                                     toItem: self,
                                                     attribute: .topMargin,
                                                     multiplier: 1.0,
                                                     constant: 0.0)
        let leftMarginConstraint = NSLayoutConstraint(item: itemDetailsLabel,
                                                      attribute: .left,
                                                      relatedBy: .equal,
                                                      toItem: self,
                                                      attribute: .leftMargin,
                                                      multiplier: 1.0,
                                                      constant: 0.0)
        let bottomMarginConstraint = NSLayoutConstraint(item: contactHelperButton,
                                                        attribute: .bottom,
                                                        relatedBy: .equal,
                                                        toItem: self,
                                                        attribute: .bottomMargin,
                                                        multiplier: 1.0,
                                                        constant: 0.0)

        let constraints = [
            topMarginConstraint,
            leftMarginConstraint,
            bottomMarginConstraint,

            locationDetailsLabel.topAnchor.constraint(equalTo: itemDetailsLabel.bottomAnchor),
            locationDetailsLabel.leftAnchor.constraint(equalTo: itemDetailsLabel.leftAnchor),

            contactHelperButton.topAnchor.constraint(equalTo: locationDetailsLabel.bottomAnchor),
            contactHelperButton.leftAnchor.constraint(equalTo: locationDetailsLabel.leftAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

