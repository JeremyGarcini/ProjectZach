import SwiftUI

/// Composition root.
///
/// The layout is three layers and nothing else: a white page, a scrolling
/// request, and two pinned bars. The header carries the progressive blur, the
/// footer carries the decision, and the middle is free to be the only thing the
/// user reads.
struct ApprovalScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var store = ApprovalFlowStore()
    @State private var activeSheet: ApprovalSheet?
    /// Height of the scroll view minus both pinned bars, measured rather than
    /// guessed. It lets a short state sit optically centred instead of clinging
    /// to the top of a mostly empty page.
    @State private var viewportHeight = 0.0

    var body: some View {
        @Bindable var store = store

        return ZStack {
            // A near-white page. Depth comes from lifted cards and tinted blocks,
            // not from a gradient painted behind the content.
            PersonaPalette.canvas.ignoresSafeArea()
            // A single soft glow bleeding off the top edge. Enough to stop the
            // page reading as a blank sheet; not enough to notice as a gradient.
            PersonaAura()

            ScrollView {
                ApprovalStageView(request: store.currentRequest, stage: store.stage)
                    .frame(maxWidth: PersonaMetrics.contentMaxWidth)
                    .padding(.horizontal, PersonaMetrics.spaceMargin)
                    // Clears the header's blur overhang so nothing rests inside the fade.
                    .padding(.top, PersonaMetrics.scrollEdgeOverhang + PersonaMetrics.spaceTight)
                    .padding(.bottom, PersonaMetrics.scrollEdgeOverhang + PersonaMetrics.spaceSection)
                    // A request is a document and starts at the top; a result is a
                    // statement and belongs in the middle of the page. `minHeight`
                    // rather than an exact frame, so an accessibility text size can
                    // still grow the content past the viewport and scroll.
                    .frame(maxWidth: .infinity, minHeight: viewportHeight, alignment: stageAlignment)
                    .background { viewportProbe }
            }
            .scrollIndicators(.hidden)
            // iOS 26 fades scrolling content into a pinned bar on its own. We keep
            // it on and layer our own longer ramp behind the header, because this
            // bar is taller than the navigation bar the system effect is tuned for.
            .scrollEdgeEffectStyle(.soft, for: [.top, .bottom])
            // `safeAreaBar` rather than `safeAreaInset`: it is the iOS 26 modifier
            // that registers a view as a *bar*, which is what lets the scroll view
            // coordinate its edge effect with it.
            .safeAreaBar(edge: .top, spacing: 0) {
                ApprovalTopBar(
                    selection: $store.scenarioSelection,
                    isWorking: store.stage == .processing,
                    onReset: resetDemo
                )
            }
            .safeAreaBar(edge: .bottom, spacing: 0) {
                ApprovalDecisionBar(
                    request: store.currentRequest,
                    stage: store.stage,
                    onDecline: store.decline,
                    onEdit: presentEditor,
                    onApprove: approve,
                    onCancel: store.cancelOperation,
                    onRetry: store.retry,
                    onUndo: store.undo,
                    onReconsider: store.reconsider
                )
            }
        }
        .sheet(item: $activeSheet, content: sheetContent)
        // Switching scenario while an editor is open would leave the sheet
        // editing something the screen behind it no longer shows.
        .onChange(of: store.selectedScenario) { activeSheet = nil }
        .animation(stageMotion, value: store.stage)
        .animation(stageMotion, value: store.selectedScenario)
        .animation(valueMotion, value: store.currentRequest)
        .sensoryFeedback(.success, trigger: store.stage == .succeeded)
        .sensoryFeedback(.error, trigger: store.stage == .failed)
        // Light-locked for the demo. Every colour is a semantic system colour, so
        // this is one line away from supporting dark mode honestly.
        .preferredColorScheme(.light)
    }

    /// Reports the scroll view's *visible* height. `containerRelativeFrame` resolves
    /// against the scroll container, so this already excludes both pinned bars —
    /// reading the outer geometry and subtracting safe-area insets by hand does not.
    private var viewportProbe: some View {
        Color.clear
            .containerRelativeFrame(.vertical)
            .onGeometryChange(for: Double.self) { $0.size.height } action: { viewportHeight = $0 }
            .allowsHitTesting(false)
    }

    @ViewBuilder
    private func sheetContent(_ sheet: ApprovalSheet) -> some View {
        switch sheet {
        case .edit:
            switch store.currentRequest.payload {
            case .reservation(let proposal):
                ReservationEditView(proposal: proposal, onSave: store.saveReservation)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            case .message(let proposal):
                MessageEditView(proposal: proposal, onSave: store.saveMessage)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        case .review:
            MessageReviewView(proposal: store.message, onConfirm: confirmHighStakes)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var stageAlignment: Alignment {
        store.stage == .awaiting ? .top : .center
    }

    private var stageMotion: Animation {
        PersonaMetrics.motion(.stage, reduceMotion: reduceMotion)
    }

    private var valueMotion: Animation {
        PersonaMetrics.motion(.value, reduceMotion: reduceMotion)
    }

    private func presentEditor() {
        activeSheet = .edit
    }

    /// Where the two stakes diverge. A reservation commits on this tap; a message
    /// only earns a closer look, and commits behind a held press one screen later.
    private func approve() {
        if store.currentRequest.risk.requiresSecondLook {
            activeSheet = .review
        } else {
            store.approveLowStakes()
        }
    }

    private func confirmHighStakes() {
        activeSheet = nil
        store.confirmHighStakes()
    }

    private func resetDemo() {
        activeSheet = nil
        store.resetDemo()
    }
}

#Preview {
    ApprovalScreen()
}
