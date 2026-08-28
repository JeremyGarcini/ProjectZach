import Foundation

/// One thing Persona noticed, with where it came from.
///
/// Showing the working is the difference between "trust me" and "here is why".
/// The source matters as much as the fact: a user deciding whether to approve
/// wants to know Persona read their calendar, not that it had a hunch.
struct ReservationSignal: Equatable, Sendable, Identifiable {
    let time: String
    let event: String
    let source: String

    var id: String { time + event }
}

struct ReservationProposal: Equatable, Sendable {
    let venue: String
    let partySize: Int
    let originalTime: String
    var requestedTime: String
    let reason: String
    let signals: [ReservationSignal]
    let evidence: String

    var partyDescription: String { "Table for \(partySize)" }

    /// How much later the new time is. Shown as a chip beside the change so the
    /// size of the ask is legible without doing arithmetic.
    var delayDescription: String { "+30 min" }

    static let sample = ReservationProposal(
        venue: "Bar Pitti",
        partySize: 4,
        originalTime: "7:30 PM",
        requestedTime: "8:00 PM",
        reason: "Your design review is running 24 minutes over.",
        signals: [
            ReservationSignal(time: "7:42", event: "Design review ends", source: "Calendar"),
            ReservationSignal(time: "8:00", event: "You’d reach Bar Pitti", source: "18 min drive")
        ],
        evidence: "You have moved a table rather than turn up late four times this year."
    )
}
