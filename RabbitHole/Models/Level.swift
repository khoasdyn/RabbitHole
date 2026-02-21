import Foundation

enum Level: Int, CaseIterable, Codable {
    case newcomer = 1
    case explorer = 2
    case student = 3
    case practitioner = 4
    case expert = 5

    var label: String {
        switch self {
        case .newcomer: "Newcomer"
        case .explorer: "Explorer"
        case .student: "Student"
        case .practitioner: "Practitioner"
        case .expert: "Expert"
        }
    }

    var description: String {
        switch self {
        case .newcomer: "The basics — grounding the question in context"
        case .explorer: "Key concepts and figures behind the question"
        case .student: "Deeper principles, nuance, and counterarguments"
        case .practitioner: "Real-world application and critical thinking"
        case .expert: "Advanced discourse, synthesis, and original thinking"
        }
    }
}
