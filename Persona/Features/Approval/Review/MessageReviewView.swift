import SwiftUI

/// The second look, high stakes only.
///
/// Approving a message opens this instead of sending it. The extra screen is not
/// ceremony: it is the last place the exact words are visible before they belong
/// to somebody else, and it is where the commit gesture changes from a tap to a
/// deliberate hold.
struct MessageReviewView: View {
    let proposal: MessageProposal
    let onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PersonaMetrics.spaceSection) {
                    VStack(alignment: .leading, spacing: PersonaMetrics.spaceSnug) {
                        PersonaChip(text: "Last look", symbol: "eye.fill", tint: PersonaPalette.caution)
                        Text("This goes to \(proposal.recipientFirstName)")
                            .personaHeroTitle()
                        Text("Once it sends, it’s his to read. Nothing here is editable.")
                            .personaSubtitle()
                    }

                    MessageDetailView(proposal: proposal)

                    PersonaCautionRow(text: proposal.caution)
                }
                .frame(maxWidth: PersonaMetrics.contentMaxWidth)
                .padding(PersonaMetrics.spaceMargin)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .background(PersonaPalette.canvas)
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back", systemImage: "chevron.left", action: dismiss.callAsFunction)
                        .labelStyle(.iconOnly)
                }
            }
            .safeAreaBar(edge: .bottom) {
                VStack(spacing: PersonaMetrics.spaceSnug) {
                    HoldToConfirmButton(title: "Hold to send", symbol: "paperplane.fill", action: confirm)

                    Label("Let go any time before it fills and nothing happens.",
                          systemImage: "hand.tap.fill")
                        .font(.system(size: 12, weight: .medium))
                        // Secondary, not tertiary: this line is what tells the
                        // user the hold is safe to start.
                        .foregroundStyle(PersonaPalette.inkSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: PersonaMetrics.contentMaxWidth)
                .padding(.horizontal, PersonaMetrics.spaceMargin)
                .padding(.bottom, PersonaMetrics.spaceTight)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func confirm() {
        dismiss()
        onConfirm()
    }
}
