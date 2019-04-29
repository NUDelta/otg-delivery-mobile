//
//  RequestStatusTableView.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 4/16/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class RequesterTableView: UITableView {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
