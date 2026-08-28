import Testing
@testable import Persona

@MainActor
struct ApprovalFlowStoreTests {
    @Test
    func selectingAnotherScenarioReturnsToAwaiting() {
        let store = ApprovalFlowStore()
        store.decline()

        store.select(.message)

        #expect(store.selectedScenario == .message)
        #expect(store.stage == .awaiting)
        #expect(store.currentRequest.risk == .high)
    }

    @Test
    func editingReservationUpdatesTheApprovalCopy() {
        let store = ApprovalFlowStore()

        store.saveReservation(time: "8:15 PM")

        #expect(store.reservation.requestedTime == "8:15 PM")
        #expect(store.currentRequest.title == "Move dinner to 8:15 PM")
    }

    @Test
    func editingMessageTrimsAccidentalWhitespace() {
        let store = ApprovalFlowStore()
        store.select(.message)

        store.saveMessage(body: "  I would like to renew.  ")

        #expect(store.message.body == "I would like to renew.")
    }

    @Test
    func resetRestoresTheDeterministicDemo() {
        let store = ApprovalFlowStore()
        store.saveReservation(time: "8:30 PM")
        store.decline()

        store.resetDemo()

        #expect(store.reservation == .sample)
        #expect(store.message == .sample)
        #expect(store.stage == .awaiting)
    }

    @Test
    func approvalEntersCancelableProcessing() {
        let store = ApprovalFlowStore()

        store.approveLowStakes()
        #expect(store.stage == .processing)

        store.cancelOperation()
        #expect(store.stage == .awaiting)
    }
}

@MainActor
struct ApprovalRiskTests {
    @Test
    func onlyHighStakesAsksTwice() {
        #expect(ApprovalRisk.low.requiresSecondLook == false)
        #expect(ApprovalRisk.high.requiresSecondLook)
        #expect(ApprovalRisk.low.requiresHeldConfirmation == false)
        #expect(ApprovalRisk.high.requiresHeldConfirmation)
    }

    @Test
    func onlyHighStakesSpellsOutAConsequence() {
        let store = ApprovalFlowStore()
        #expect(store.currentRequest.caution == nil)

        store.select(.message)
        #expect(store.currentRequest.caution != nil)
    }

    @Test
    func theSubtitleNeverRepeatsTheRecipientRowBelowIt() {
        let store = ApprovalFlowStore()
        store.select(.message)

        #expect(store.currentRequest.subtitle.contains(store.message.recipient) == false)
    }
}
