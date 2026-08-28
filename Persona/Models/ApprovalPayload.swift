enum ApprovalPayload: Equatable, Sendable {
    case reservation(ReservationProposal)
    case message(MessageProposal)
}

