//
//  Notification.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 1/20/20.
//  Copyright © 2020 Cooper Barth. All rights reserved.
//

import Foundation

struct Notification : Codable {
    private static let apiUrl: String = Constants.apiUrl + "notification"

    enum CodingKeys : String, CodingKey {
        case datetime
        case recipient = "_id"
        case type
    }

    let datetime: String
    let recipient: String
    let type: String

    private static let validTypes: [String] = [
        "RequestAvailable"
    ]
}

extension Notification {
    static func save(userId: String, type: String) {
        print("Saving notification")

        if (validTypes.contains(type)) {
            var components = URLComponents(string: "")
            components?.queryItems = [
                URLQueryItem(name: "recipient", value: userId),
                URLQueryItem(name: "type", value: type)
            ]

            let url = URL(string: Notification.apiUrl)
            let session: URLSession = URLSession.shared
            var requestURL = URLRequest(url: url!)

            requestURL.httpMethod = "POST"
            requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let httpBodyString: String? = components?.url?.absoluteString
            requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)

            let task = session.dataTask(with: requestURL) { data, response, error in
                guard data != nil else {
                    print(error as Any)
                    return
                }
                print("NOTIFICATION: posted successfully.")
            }
            task.resume()
        } else {
            print("Invalid type \(type)")
        }
    }
}
