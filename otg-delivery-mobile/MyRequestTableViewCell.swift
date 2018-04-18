//
//  MyRequestTableViewCell.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 4/14/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class MyRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
