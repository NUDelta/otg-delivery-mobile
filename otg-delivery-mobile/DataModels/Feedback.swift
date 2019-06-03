import Foundation

struct Feedback: Codable {
    private static let apiUrl: String = Constants.apiUrl + "feedback"

    enum CodingKeys : String, CodingKey {
        case userId
        case requestId
        case nextLocation
        case inconvenience
        case disruption
        case waiting
    }

    var userId: String
    var requestId: String
    var nextLocation: String
    var inconvenience: String
    var disruption: String
    var waiting: String

    init() {
        userId = ""
        requestId = ""
        nextLocation = ""
        inconvenience = ""
        disruption = ""
        waiting = ""
    }

    init(userId: String, requestId: String, nextLocation: String, inconvenience: String, disruption: String, waiting: String) {
        self.userId = userId
        self.requestId = requestId
        self.nextLocation = nextLocation
        self.inconvenience = inconvenience
        self.disruption = disruption
        self.waiting = waiting
    }
}

extension Feedback {
    static func post(feedback: Feedback) {
        print("Posting Feedback")

        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "userId", value: feedback.userId),
            URLQueryItem(name: "requestId", value: feedback.requestId),
            URLQueryItem(name: "nextLocation", value: feedback.nextLocation),
            URLQueryItem(name: "inconvenience", value: feedback.inconvenience),
            URLQueryItem(name: "disruption", value: feedback.disruption),
            URLQueryItem(name: "waiting", value: feedback.waiting),
        ]

        let url = URL(string: Feedback.apiUrl)
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)

        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)

        let task = session.dataTask(with: requestURL) { data, response, error in
            print("USER DATA: user data returned.")
        }
        task.resume()
    }
}
