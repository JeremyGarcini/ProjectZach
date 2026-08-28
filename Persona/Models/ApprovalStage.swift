enum ApprovalStage: Hashable, Sendable {
    case awaiting
    case processing
    case succeeded
    case declined
    case failed
    case undone
}

