import SwiftUI

/// Rewrite the message before it goes anywhere.
///
/// Saving deliberately drops the user back on the request rather than sending.
/// An edit is not consent, and the send still has to be held for.
struct MessageEditView: View {
    let proposal: MessageProposal
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isEditing: Bool
    @State private var draft: String

    private let characterLimit = 280

    init(proposal: MessageProposal, onSave: @escaping (String) -> Void) {
        self.proposal = proposal
        self.onSave = onSave
        _draft = State(initialValue: proposal.body)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: PersonaMetrics.spaceSection) {
                PersonaCard {
                    PersonaValueRow(label: "To") {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(proposal.recipient).personaRowValue()
                            Text(proposal.relationship)
                                .font(.caption)
                                .foregroundStyle(PersonaPalette.inkTertiary)
                        }
                    }
                }

                VStack(alignment: .trailing, spacing: PersonaMetrics.spaceTight) {
                    TextField("Message", text: $draft, axis: .vertical)
                        .font(.body)
                        .lineLimit(5...10)
                        .focused($isEditing)
                        .padding(PersonaMetrics.spaceRegular)
                        .background(
                            PersonaPalette.surfaceRaised,
                            in: .rect(cornerRadius: PersonaMetrics.radiusSurface, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: PersonaMetrics.radiusSurface, style: .continuous)
                                .strokeBorder(
                                    isEditing ? PersonaPalette.brand.opacity(0.5) : PersonaPalette.border,
                                    lineWidth: isEditing ? 1.5 : 1
                                )
                        }
                        .animation(PersonaMetrics.controlResponse, value: isEditing)

                    Text("\(draft.count)/\(characterLimit)")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(isOverLimit ? PersonaPalette.negative : PersonaPalette.inkTertiary)
                        .contentTransition(.numericText())
                        .animation(PersonaMetrics.valueChange, value: draft.count)
                }

                Label("Saving brings you back to the request. It does not send anything.",
                      systemImage: "lock.fill")
                    .font(.footnote)
                    .foregroundStyle(PersonaPalette.inkSecondary)
                    // A `Label` will happily truncate to one line; this makes it wrap.
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: PersonaMetrics.contentMaxWidth)
            .padding(PersonaMetrics.spaceMargin)
            .frame(maxWidth: .infinity)
            .background(PersonaPalette.canvas)
            .navigationTitle("Edit message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark", action: dismiss.callAsFunction)
                        .labelStyle(.iconOnly)
                }
            }
            .safeAreaBar(edge: .bottom) {
                PersonaCommitButton(
                    title: "Save",
                    isEnabled: !trimmedDraft.isEmpty && !isOverLimit,
                    action: save
                )
                .frame(maxWidth: PersonaMetrics.contentMaxWidth)
                    .padding(.horizontal, PersonaMetrics.spaceMargin)
                    .padding(.bottom, PersonaMetrics.spaceTight)
                    .frame(maxWidth: .infinity)
            }
            .onAppear { isEditing = true }
        }
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isOverLimit: Bool { draft.count > characterLimit }

    private func save() {
        onSave(trimmedDraft)
        dismiss()
    }
}
