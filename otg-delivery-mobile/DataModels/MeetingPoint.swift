//
//  MeetingPoint.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 3/9/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import Foundation

struct MeetingPoint : Codable {
    private static let apiUrl: String = Constants.apiUrl + "meeting"

    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case name
    }

    let id: String
    let name: String
}

extension MeetingPoint {

    static func getAll(completionHandler: @escaping ([MeetingPoint]) -> Void) {
        let url = URL(string: "\(MeetingPoint.apiUrl)")
        let session: URLSession = URLSession.shared
        let requestURL = URLRequest(url: url!)

        let task = session.dataTask(with: requestURL){ data, response, error in
            print("MEETING POINT MODEL: Getting all locations")
            guard let data = data else {
                return
            }

            var meetingPoints: [MeetingPoint] = []
            let httpResponse = response as? HTTPURLResponse

            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    meetingPoints = try decoder.decode([MeetingPoint].self, from: data)
                } catch {
                    print("MEETING POINT: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(meetingPoints)
        }
        
        task.resume()
    }
}
