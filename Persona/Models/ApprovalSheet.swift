enum ApprovalSheet: Identifiable, Sendable {
    case edit
    case review

    var id: Self { self }
}

