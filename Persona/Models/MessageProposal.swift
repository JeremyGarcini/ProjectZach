import Foundation

struct MessageProposal: Equatable, Sendable {
    let recipient: String
    let relationship: String
    var body: String
    let reason: String
    let evidence: String
    let caution: String

    var recipientFirstName: String {
        recipient.split(separator: " ").first.map(String.init) ?? recipient
    }

    /// Initials for the contact avatar, the way Mail and Messages build theirs.
    var recipientInitials: String {
        recipient.split(separator: " ").prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
    }

    static let sample = MessageProposal(
        recipient: "Daniel Ortiz",
        relationship: "Landlord",
        body: "Hi Daniel — I’d like to renew for another year at the current rate. Send the paperwork whenever you’re ready.",
        reason: "Daniel asked for an answer by 6:00 PM, and you said staying was the plan if the rent held.",
        evidence: "You told me on Sunday that moving was off the table unless the rent went up.",
        caution: "This commits you to another year. Once it is sent, Daniel has your answer."
    )
}
