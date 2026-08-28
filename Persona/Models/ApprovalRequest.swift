import Foundation

/// One thing Persona wants to do, and everything the user needs to judge it.
struct ApprovalRequest: Identifiable, Equatable, Sendable {
    let scenario: ApprovalScenario
    let risk: ApprovalRisk
    let payload: ApprovalPayload

    var id: ApprovalScenario { scenario }

    /// The half-second read: what is about to happen, as a plain sentence.
    var title: String {
        switch payload {
        case .reservation(let proposal): "Move dinner to \(proposal.requestedTime)"
        case .message(let proposal): "Text \(proposal.recipientFirstName) about the lease"
        }
    }

    /// The next line down: who or what it touches.
    var subtitle: String {
        switch payload {
        case .reservation(let proposal): "\(proposal.venue) · tonight"
        // Deliberately not the recipient — the "To" row right below already says
        // who. The subtitle's job is to name the stake instead.
        case .message: "Commits you to another year"
        }
    }

    /// Why Persona thinks now is the moment.
    var reason: String {
        switch payload {
        case .reservation(let proposal): proposal.reason
        case .message(let proposal): proposal.reason
        }
    }

    /// What Persona learned about the user that led it here.
    var evidence: String {
        switch payload {
        case .reservation(let proposal): proposal.evidence
        case .message(let proposal): proposal.evidence
        }
    }

    /// The consequence worth spelling out before committing. High stakes only —
    /// a warning that appears on every request is a warning nobody reads.
    var caution: String? {
        switch payload {
        case .reservation: nil
        case .message(let proposal): proposal.caution
        }
    }
}
