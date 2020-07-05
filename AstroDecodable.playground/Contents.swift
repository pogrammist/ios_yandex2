import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct SpaceInfo: Decodable {
    let message: String
    let number: Int
    let people: [Astronaut]
}

struct Astronaut: Decodable {
    let name: String
    let craft: String
}

func load () {
    let stringUrl = "http://api.open-notify.org/astros.json"
    guard let url = URL(string: stringUrl) else { return }
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard error == nil else {
            print(error?.localizedDescription ?? "noDesc")
            return
        }
        guard let data = data else { return }
        guard let spaceInfo = try? JSONDecoder().decode(SpaceInfo.self, from: data) else {
            print("Error: can't parse SpaceInfo")
            return
        }
        print("\(spaceInfo.message.capitalized)! There are currently \(spaceInfo.number) humans in space!")
        let uniqueSpacecrafts = Set(spaceInfo.people.map { $0.craft })
        print("Spacecrafts: \(uniqueSpacecrafts.joined(separator: ","))")
    }
    task.resume()
}
load()
