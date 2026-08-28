import SwiftUI

/// Swaps one stage of the flow for the next.
///
/// The transition is a blur-replace rather than a slide: nothing moved anywhere,
/// the same subject simply resolved into a new state. Pairing it with a tiny
/// scale gives the change a direction — settling in for a result, receding when
/// the request comes back — without anyone having to wait for a slide to finish.
struct ApprovalStageView: View {
    let request: ApprovalRequest
    let stage: ApprovalStage

    var body: some View {
        Group {
            switch stage {
            case .awaiting:
                ApprovalRequestView(request: request)
            case .processing:
                ApprovalProgressView(request: request)
            case .succeeded, .declined, .failed, .undone:
                ApprovalOutcomeView(request: request, stage: stage)
            }
        }
        // Identity is stage *and* scenario. Without the scenario, switching stakes
        // reuses the same view and SwiftUI interpolates one layout into the other
        // — which briefly renders both sets of text on top of each other.
        .id(StageIdentity(stage: stage, scenario: request.scenario))
        .transition(.blurReplace.combined(with: .scale(0.97)))
    }

    private struct StageIdentity: Hashable {
        let stage: ApprovalStage
        let scenario: ApprovalScenario
    }
}
