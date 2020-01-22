import Foundation

struct LocationUpdate : Codable {
    private static let apiUrl: String = Constants.apiUrl + "locupdates"    

    enum CodingKeys : String, CodingKey {
        case latitude
        case longitude
        case speed
        case direction
        case uncertainty
        case userId
    }

    let latitude: Double
    let longitude: Double
    let speed: Double
    let direction: Double
    let uncertainty: Double
    let userId: String
}

extension LocationUpdate {
    static func post(locUpdate: LocationUpdate) {
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(locUpdate.latitude)),
            URLQueryItem(name: "longitude", value: String(locUpdate.longitude)),
            URLQueryItem(name: "speed", value: String(locUpdate.speed)),
            URLQueryItem(name: "direction", value: String(locUpdate.direction)),
            URLQueryItem(name: "uncertainty", value: String(locUpdate.uncertainty)),
            URLQueryItem(name: "userId", value: String(locUpdate.userId))
        ]

        let url = URL(string: LocationUpdate.apiUrl)
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)

        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        //These two lines are cancerous :: something severly wrong with my hack with URLComponents
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)

        let task = session.dataTask(with: requestURL){ data, response, error in
            //let httpResponse = response as? HTTPURLResponse

            // Keep retrying if unsuccessful
            //print(httpResponse?.statusCode)
//            if(httpResponse?.statusCode != 200){
//                print("Retry")
//                self.post(locUpdate: locUpdate)
//            }
        }

        task.resume()
    }

    static func getRecent(withId userId: String, completionHandler: @escaping (LocationUpdate?) -> Void) {
        print(userId)
        let url = URL(string: "\(LocationUpdate.apiUrl)/\(userId)/recent")
        let session: URLSession = URLSession.shared
        let requestURL = URLRequest(url: url!)

        let task = session.dataTask(with: requestURL){ data, response, error in
            print("MEETING POINT MODEL: Getting all potential locations for request \(userId)")
            guard let data = data else {
                return
            }

            var recentLocation: LocationUpdate?
            let httpResponse = response as? HTTPURLResponse

            if (httpResponse?.statusCode != 400) {
                do {
                    let decoder = JSONDecoder()
                    recentLocation = try decoder.decode(LocationUpdate.self, from: data)
                } catch {
                    print("MEETING POINT: error trying to convert data to JSON...")
                    print(error)
                }
            }

            completionHandler(recentLocation)
        }
        task.resume()
    }

/*
    static func dateToString(d: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return formatter.string(from: d)
    }

    static func stringToDate(d: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return formatter.date(from: d)!
    }
*/
}
