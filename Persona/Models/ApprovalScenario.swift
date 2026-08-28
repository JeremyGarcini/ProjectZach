import Foundation

/// The two requests the prototype can show. The brief asks for one app that
/// flexes between stakes, so the scenario is the only thing that changes —
/// every screen, transition and control below is shared.
enum ApprovalScenario: String, CaseIterable, Identifiable, Sendable {
    case reservation
    case message

    var id: Self { self }

    /// Wording in the demo switcher. Named after the stakes rather than the
    /// content so a reviewer can find both halves of the brief immediately.
    var switcherTitle: String {
        switch self {
        case .reservation: "Low stakes"
        case .message: "High stakes"
        }
    }
}
