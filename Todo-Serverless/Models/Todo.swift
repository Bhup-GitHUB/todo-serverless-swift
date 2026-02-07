import Foundation

struct Todo: Codable, Identifiable, Equatable, Hashable {
    let id: String
    var title: String
    var completed: Bool
}
