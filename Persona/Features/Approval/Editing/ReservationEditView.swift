import SwiftUI

/// Change the thing before approving it.
///
/// The brief asks for edit, not just accept or reject, and the honest version of
/// editing a reservation is picking from times the restaurant could actually
/// hold — not a free-form clock. Saving returns to the request; it never becomes
/// an implicit approval.
struct ReservationEditView: View {
    let proposal: ReservationProposal
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTime: String

    private let timeOptions = ["7:45 PM", "8:00 PM", "8:15 PM", "8:30 PM"]

    /// The segmented control needs `Identifiable` options; a raw `String` cannot
    /// be one without polluting the standard library.
    struct TimeOption: Hashable, Identifiable {
        let value: String
        var id: String { value }
    }

    private var timeSelection: Binding<TimeOption> {
        Binding(
            get: { TimeOption(value: selectedTime) },
            set: { selectedTime = $0.value }
        )
    }

    init(proposal: ReservationProposal, onSave: @escaping (String) -> Void) {
        self.proposal = proposal
        self.onSave = onSave
        _selectedTime = State(initialValue: proposal.requestedTime)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: PersonaMetrics.spaceSection) {
                VStack(alignment: .leading, spacing: PersonaMetrics.spaceTight) {
                    Text("Ask for a different time").personaHeroTitle()
                    Text("These are the tables \(proposal.venue) still has tonight.")
                        .personaSubtitle()
                }

                PersonaSegmentedControl(
                    options: timeOptions.map(TimeOption.init),
                    selection: timeSelection,
                    title: \.value
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel("New time")

                PersonaCard {
                    PersonaValueRow(label: "Booked now") {
                        Text(proposal.originalTime).personaRowValue()
                    }
                    PersonaDivider()
                    PersonaValueRow(label: "Party") {
                        Text(proposal.partyDescription).personaRowValue()
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: PersonaMetrics.contentMaxWidth)
            .padding(PersonaMetrics.spaceMargin)
            .frame(maxWidth: .infinity)
            .background(PersonaPalette.canvas)
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark", action: dismiss.callAsFunction)
                        .labelStyle(.iconOnly)
                }
            }
            .safeAreaBar(edge: .bottom) {
                PersonaCommitButton(title: "Save", action: save)
                    .frame(maxWidth: PersonaMetrics.contentMaxWidth)
                    .padding(.horizontal, PersonaMetrics.spaceMargin)
                    .padding(.bottom, PersonaMetrics.spaceTight)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func save() {
        onSave(selectedTime)
        dismiss()
    }
}
