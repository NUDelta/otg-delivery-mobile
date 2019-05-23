import Foundation

struct Item : Codable {
    private static let apiUrl: String = Constants.apiUrl + "items"
    
    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case name
        case description
        case price
        case location
    }

    let id: String
    let name: String
    let description: String
    let price: Double
    let location: String
}

extension Item {
    func getPriceString() -> String {
        return String.init(format: "$%.2f", self.price)
    }

    static func get(withId id: String, completionHandler: @escaping (Item?) -> Void) {
        print("Get item with id \(id)")
        
        let url = URL(string: "\(Item.apiUrl)/\(id)")
        let session: URLSession = URLSession.shared
        let requestURL = URLRequest(url: url!)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            guard let data = data else {
                return
            }

            print("ITEM: get with id \(id)")

            var item: Item?
            let httpResponse = response as? HTTPURLResponse

            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    item = try decoder.decode(Item.self, from: data)
                } catch {
                    print("ITEM.get: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(item!)
        }

        task.resume()
    }

    static func getAll(forLocation id: String, name: String, completionHandler: @escaping ([Item]) -> Void) {
        print("Get all items for location \(name)")

        let url = URL(string: "\(Item.apiUrl)/\(id)/\(name)")
        let session: URLSession = URLSession.shared
        let requestURL = URLRequest(url: url!)

        let task = session.dataTask(with: requestURL){ data, response, error in
            print("ITEM MODEL: Getting items for \(name)")
            guard let data = data else {
                return
            }

            var items: [Item] = []
            let httpResponse = response as? HTTPURLResponse

            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    items = try decoder.decode([Item].self, from: data)
                } catch {
                    print("ITEM: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(items)
        }

        task.resume()
    }
}
