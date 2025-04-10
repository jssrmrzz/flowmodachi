import Foundation

struct FlowSession: Codable, Identifiable {
    let id: UUID
    let startDate: Date
    let duration: Int // in seconds
}

