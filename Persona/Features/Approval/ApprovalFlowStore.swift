import Foundation
import Observation

/// The state machine behind the screen.
///
/// Everything the interface can be is one `ApprovalStage`, and every path
/// between stages is a method here. Keeping it in one observable object rather
/// than spreading `@State` across views is what makes the awkward transitions —
/// cancel mid-flight, fail, retry, undo — cheap to reason about and possible to
/// unit test without a simulator.
///
/// There is no networking. The operations are `Task`s that sleep, so "cancel"
/// really does cancel and is not the interface pretending.
@MainActor
@Observable
final class ApprovalFlowStore {
    private(set) var selectedScenario: ApprovalScenario = .reservation
    private(set) var stage: ApprovalStage = .awaiting
    private(set) var reservation = ReservationProposal.sample
    private(set) var message = MessageProposal.sample

    /// Long enough that the in-progress state is a state the user actually sees
    /// and has time to cancel. Below about a second it flashes past and reads as
    /// a glitch, and there is nothing to cancel in practice. This is an operation
    /// out in the world — a call being placed — not a screen transition, so the
    /// rule about never making the user wait does not ask for it to be shorter.
    private static let operationDuration = Duration.seconds(2.2)

    /// The first high-stakes send fails on purpose. A failure that only happens
    /// sometimes is a failure that never gets designed; making it deterministic
    /// means the recovery path is built, tested and demonstrable in one take.
    private var shouldFailNextMessageSend = true
    private var operationTask: Task<Void, Never>?

    var currentRequest: ApprovalRequest {
        switch selectedScenario {
        case .reservation:
            ApprovalRequest(scenario: .reservation, risk: .low, payload: .reservation(reservation))
        case .message:
            ApprovalRequest(scenario: .message, risk: .high, payload: .message(message))
        }
    }

    /// Two-way access for the demo switcher. Routing the setter through `select`
    /// means picking a scenario still cancels anything in flight, and letting
    /// Observation vend the binding avoids handing a non-Sendable closure to
    /// `Binding(get:set:)`.
    var scenarioSelection: ApprovalScenario {
        get { selectedScenario }
        set { select(newValue) }
    }

    func select(_ scenario: ApprovalScenario) {
        guard selectedScenario != scenario else { return }
        operationTask?.cancel()
        selectedScenario = scenario
        stage = .awaiting
    }

    // MARK: Editing
    //
    // Saving an edit always lands back on `.awaiting`. Changing the thing is not
    // the same as agreeing to it, and the user still has to approve afterwards.

    func saveReservation(time: String) {
        reservation.requestedTime = time
        stage = .awaiting
    }

    func saveMessage(body: String) {
        message.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        stage = .awaiting
    }

    // MARK: Committing

    /// A tap is enough at low stakes.
    func approveLowStakes() {
        guard selectedScenario == .reservation else { return }
        beginOperation()
    }

    /// Only reachable from the review sheet, behind a held press.
    func confirmHighStakes() {
        guard selectedScenario == .message else { return }
        beginOperation()
    }

    // MARK: Backing out

    func decline() {
        operationTask?.cancel()
        stage = .declined
    }

    /// Stops the work and returns the user to the untouched request.
    func cancelOperation() {
        operationTask?.cancel()
        stage = .awaiting
    }

    func retry() {
        beginOperation()
    }

    func undo() {
        operationTask?.cancel()
        stage = .undone
    }

    /// Back to the ask, from any ending.
    func reconsider() {
        stage = .awaiting
    }

    /// Returns the prototype to a known state, including the scripted failure, so
    /// a recording can be restarted at any point.
    func resetDemo() {
        operationTask?.cancel()
        reservation = .sample
        message = .sample
        shouldFailNextMessageSend = true
        stage = .awaiting
    }

    private func beginOperation() {
        operationTask?.cancel()
        stage = .processing

        operationTask = Task { [weak self] in
            try? await Task.sleep(for: Self.operationDuration)
            // A cancelled sleep must leave the stage exactly where `cancelOperation`
            // put it, so this returns rather than deciding an outcome.
            guard !Task.isCancelled, let self else { return }

            if selectedScenario == .message, shouldFailNextMessageSend {
                shouldFailNextMessageSend = false
                stage = .failed
            } else {
                stage = .succeeded
            }
        }
    }
}
