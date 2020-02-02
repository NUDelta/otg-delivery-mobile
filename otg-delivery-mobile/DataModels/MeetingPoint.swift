import Foundation

struct MeetingPoint : Codable {
    private static let apiUrl: String = Constants.apiUrl + "meeting"

    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case latitude
        case longitude
        case radius
        case requestId
        case description
        case startTime
        case endTime
    }

    let id: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var requestId: String
    var description: String
    var startTime: String
    var endTime: String

    init(latitude: Double, longitude: Double, radius: Double, requestId: String) {
        self.id = "_id"
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.requestId = requestId
        self.description = ""
        self.startTime = ""
        self.endTime = ""
    }
}

extension MeetingPoint {
    static func post(point: MeetingPoint, completionHandler: @escaping (MeetingPoint) -> Void) {
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: "\(point.latitude)"),
            URLQueryItem(name: "longitude", value: "\(point.longitude)"),
            URLQueryItem(name: "radius", value: "\(point.radius)"),
            URLQueryItem(name: "requestId", value: point.requestId),
            URLQueryItem(name: "description", value: point.description),
            URLQueryItem(name: "startTime", value: point.startTime),
            URLQueryItem(name: "endTime", value: point.endTime)
        ]

        let url = URL(string: "\(MeetingPoint.apiUrl)")
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)

        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)

        let task = session.dataTask(with: requestURL) { data, response, error in
            print("Meeting Point: Data post successful.")
            guard let data = data else {
                return
            }

            var meetingPoint: MeetingPoint?
            let httpResponse = response as? HTTPURLResponse

            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    meetingPoint = try decoder.decode(MeetingPoint.self, from: data)
                    completionHandler(meetingPoint!)
                } catch {
                    print("MEETING POINT: error trying to convert data to JSON...")
                    print(error)
                }
            }
        }

        task.resume()
    }

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

    static func getById(with_id requestId: String, completionHandler: @escaping (MeetingPoint) -> Void) {
        let url = URL(string: "\(MeetingPoint.apiUrl)/\(requestId)")
        let session: URLSession = URLSession.shared
        let requestURL = URLRequest(url: url!)

        let task = session.dataTask(with: requestURL) { data, response, error in
            print("Meeting Point: Data retrieved successfully.")
            guard let data = data else {
                return
            }

            var meetingPoint: MeetingPoint?
            let httpResponse = response as? HTTPURLResponse

            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    meetingPoint = try decoder.decode(MeetingPoint.self, from: data)
                    completionHandler(meetingPoint!)
                } catch {
                    print("MEETING POINT: error trying to convert data to JSON...")
                    print(error)
                }
            }
        }

        task.resume()
    }

    static func getByRequest(with_id requestId: String, completionHandler: @escaping ([MeetingPoint]) -> Void) {
        let url = URL(string: "\(MeetingPoint.apiUrl)/\(requestId)/request")
        let session: URLSession = URLSession.shared
        let requestURL = URLRequest(url: url!)

        let task = session.dataTask(with: requestURL){ data, response, error in
            print("MEETING POINT MODEL: Getting all potential locations for request \(requestId)")
            guard let data = data else {
                return
            }

            var meetingPoints: [MeetingPoint] = []
            let httpResponse = response as? HTTPURLResponse

            if (httpResponse?.statusCode != 400) {
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

    static func value(userId: String, meetingPointLatitude: Double, meetingPointLongitude: Double, meetingPointEndTime: String, completionHandler: @escaping (Double) -> Void) {
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "meetingPointLatitude", value: String(meetingPointLatitude)),
            URLQueryItem(name: "meetingPointLongitude", value: String(meetingPointLongitude)),
            URLQueryItem(name: "meetingPointEndTime", value: meetingPointEndTime)
        ]

        let url = URL(string: "\(MeetingPoint.apiUrl)/value")
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)

        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)

        let task = session.dataTask(with: requestURL) { data, response, error in
            print("Meeting Point: Value requested.")
            guard let data = data else {
                return
            }

            let httpResponse = response as? HTTPURLResponse

            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    let value = try decoder.decode(Double.self, from: data)
                    completionHandler(value)
                } catch {
                    print("MEETING POINT VALUE: error trying to convert data to Double...")
                    print(error)
                }
            }
        }

        task.resume()
    }
}
