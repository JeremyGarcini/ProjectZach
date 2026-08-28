import SwiftUI

/// The pinned bar that holds whatever the user can do right now.
///
/// It never leaves. Deciding, cancelling mid-flight and recovering afterwards all
/// happen in the same place at the bottom of the screen, so the eye never has to
/// go looking for the controls when the stage changes. Only the buttons inside it
/// are replaced, which is also why the bar can carry the transition instead of the
/// whole layout reflowing around it.
struct ApprovalDecisionBar: View {
    let request: ApprovalRequest
    let stage: ApprovalStage
    let onDecline: () -> Void
    let onEdit: () -> Void
    let onApprove: () -> Void
    let onCancel: () -> Void
    let onRetry: () -> Void
    let onUndo: () -> Void
    let onReconsider: () -> Void

    var body: some View {
        VStack(spacing: PersonaMetrics.spaceSnug) {
            // Above the buttons, not below: the user should know a retry is safe
            // *before* deciding to press it.
            if let footnote {
                Label(footnote.text, systemImage: footnote.symbol)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(footnote.tint)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(footnote.tint.opacity(0.10), in: .capsule)
                    .transition(.opacity.combined(with: .scale(0.94)))
            }

            controls
        }
        .frame(maxWidth: PersonaMetrics.contentMaxWidth)
        .padding(.horizontal, PersonaMetrics.spaceMargin)
        .padding(.top, PersonaMetrics.spaceSnug)
        .padding(.bottom, PersonaMetrics.spaceTight)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) { blur }
    }

    @ViewBuilder
    private var controls: some View {
        switch stage {
        case .awaiting:
            RequestActions(request: request, onDecline: onDecline, onEdit: onEdit, onApprove: onApprove)
        case .processing:
            // Cancel stands alone. Nothing else is a sensible thing to do while
            // Persona is mid-action, and offering more would imply otherwise.
            Button("Cancel", action: onCancel)
                .personaSecondaryAction(fullWidth: true)
        case .succeeded, .declined, .failed, .undone:
            OutcomeActions(stage: stage, onRetry: onRetry, onEdit: onEdit, onUndo: onUndo, onReconsider: onReconsider)
        }
    }

    /// The pill above the buttons. It exists to make the undo window and the
    /// safety of a retry explicit, because those are the two things a user most
    /// needs to trust once Persona has acted for them.
    private var footnote: (text: String, symbol: String, tint: Color)? {
        switch stage {
        case .succeeded:
            ("Undoable for the next few minutes", "clock.arrow.circlepath", PersonaPalette.positive)
        case .failed:
            ("Nothing was sent — retrying is safe", "lock.shield.fill", PersonaPalette.inkSecondary)
        case .awaiting, .processing, .declined, .undone:
            nil
        }
    }

    /// The mirror of the header's ramp. Without it the request would meet the bar
    /// on a hard edge, and the glass controls would sit on raw content instead of
    /// on a surface that receded to meet them.
    private var blur: some View {
        ProgressiveBlurEdge(
            height: 220,
            ramp: PersonaMetrics.scrollEdgeRamp,
            edge: .bottom
        )
        .padding(.top, -PersonaMetrics.scrollEdgeOverhang)
        .ignoresSafeArea(edges: .bottom)
    }
}

/// Three choices, weighted. Decline and edit are icon-only glass buttons grouped
/// at the leading edge; the one action that moves things forward sits alone on
/// the trailing edge with a label that names what it will do. It keeps its
/// intrinsic width — a full-bleed button would read as the default answer, and
/// the default answer here should be the user's.
///
/// At accessibility text sizes that row cannot hold. "Move to 8:00 PM" at
/// AX-Large is wider than an iPhone, and a button that refuses to shrink drags
/// the whole layout off-screen with it. So the bar restacks: the primary action
/// takes the full width on its own line and the two secondaries drop below it
/// with their labels showing, which is what iOS does with its own toolbars.
private struct RequestActions: View {
    let request: ApprovalRequest
    let onDecline: () -> Void
    let onEdit: () -> Void
    let onApprove: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: PersonaMetrics.spaceTight) {
                approve.personaPrimaryAction(fullWidth: true)
                HStack(spacing: PersonaMetrics.spaceTight) {
                    decline.personaSecondaryAction(fullWidth: true)
                    edit.personaSecondaryAction(fullWidth: true)
                }
            }
        } else {
            HStack(spacing: PersonaMetrics.spaceTight) {
                decline.labelStyle(.iconOnly).personaIconAction()
                edit.labelStyle(.iconOnly).personaIconAction()
                Spacer(minLength: PersonaMetrics.spaceSnug)
                approve
                    .personaPrimaryAction()
                    // Never truncate the sentence that says what will happen.
                    // Safe here precisely because the accessibility sizes take
                    // the branch above.
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
            }
        }
    }

    private var decline: some View {
        Button("Not now", systemImage: "xmark", action: onDecline)
            .accessibilityInputLabels(["Not now", "Decline", "No"])
    }

    private var edit: some View {
        Button("Edit", systemImage: "pencil", action: onEdit)
            .accessibilityInputLabels(["Edit", "Change"])
    }

    private var approve: some View {
        Button(primaryTitle, action: onApprove)
            .accessibilityInputLabels([primaryTitle, "Approve", "Yes"])
    }

    /// The button says what happens next, not "Approve". At low stakes that is
    /// the change itself; at high stakes it is honestly only a review, because
    /// the send lives one deliberate step further in.
    private var primaryTitle: String {
        switch request.payload {
        case .reservation(let proposal): "Move to \(proposal.requestedTime)"
        case .message: "Review message"
        }
    }
}

/// What the user can still do once Persona has stopped.
///
/// After a success the prominent button is "Done", not "Undo". Making the loudest
/// control on a screen that just worked say *undo* reads as the app second-
/// guessing itself. Undo sits beside it at secondary weight, with the line
/// underneath saying how long it stays available — present, never pushy.
private struct OutcomeActions: View {
    let stage: ApprovalStage
    let onRetry: () -> Void
    let onEdit: () -> Void
    let onUndo: () -> Void
    let onReconsider: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Two buttons side by side stop fitting well before the text stops
        // growing, so they stack for the same reason the request bar does.
        layout {
            switch stage {
            case .succeeded:
                button("Undo", symbol: "arrow.uturn.backward", isPrimary: false, action: onUndo)
                button("Done", isPrimary: true, action: onReconsider)

            case .declined:
                button("Ask me again", isPrimary: true, action: onReconsider)

            case .failed:
                button("Edit", symbol: "pencil", isPrimary: false, action: onEdit)
                button("Try again", symbol: "arrow.clockwise", isPrimary: true, action: onRetry)

            case .undone:
                button("Back to the request", isPrimary: true, action: onReconsider)

            case .awaiting, .processing:
                EmptyView()
            }
        }
    }

    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: PersonaMetrics.spaceTight))
            : AnyLayout(HStackLayout(spacing: PersonaMetrics.spaceTight))
    }

    @ViewBuilder
    private func button(
        _ title: String,
        symbol: String? = nil,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        // Stacked buttons match each other's width; side-by-side ones hug.
        let stacked = dynamicTypeSize.isAccessibilitySize
        let base = Button(action: action) {
            HStack(spacing: 7) {
                if let symbol { Image(systemName: symbol) }
                Text(title)
            }
        }

        if isPrimary {
            base.personaPrimaryAction(fullWidth: stacked)
        } else {
            base.personaSecondaryAction(fullWidth: stacked)
        }
    }
}
