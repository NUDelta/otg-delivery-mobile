//
//  HelperTableViewCell.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 4/28/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class HelperTableViewCell: UITableViewCell {
    static let reuseIdentifier = "requestStatusReuseIdentifier"

    let statusLabel = UILabel()
    let itemDetailsLabel = UILabel()
    let locationDetailsLabel = UILabel()
    let contactRequesterButton = UIButton.init(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.isUserInteractionEnabled = false
        self.clipsToBounds = true

        let subtitleTitleColor = UIColor.darkGray
        let subtitleTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)

        let labels = [
            statusLabel,
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

        addContactRequesterButton()
    }

    func addContactRequesterButton() {
        contactRequesterButton.backgroundColor = UIColor.clear
        contactRequesterButton.setTitleColor(self.tintColor, for: .normal)
        contactRequesterButton.setTitle("Contact Helper", for: .normal)
        contactRequesterButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contactRequesterButton)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
