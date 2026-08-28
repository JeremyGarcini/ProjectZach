import SwiftUI

/// Persona's working, shown rather than claimed.
///
/// A real timeline: a rule running down the gutter with a dot on each entry, the
/// last one filled in brand indigo because it is the moment the request is
/// about. Showing the source under each line ("Calendar", "18 min drive") is the
/// difference between "trust me" and "here is why" — a user deciding whether to
/// approve wants to know Persona read their calendar, not that it had a hunch.
struct SignalTimelineView: View {
    let signals: [ReservationSignal]

    var body: some View {
        VStack(alignment: .leading, spacing: PersonaMetrics.spaceSnug) {
            Text("Tonight")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.7)
                .textCase(.uppercase)
                .foregroundStyle(PersonaPalette.brand)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(signals.enumerated()), id: \.element.id) { index, signal in
                    row(for: signal, isLast: index == signals.count - 1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PersonaMetrics.spaceRegular)
        .padding(.bottom, PersonaMetrics.spaceRegular)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tonight")
    }

    private func row(for signal: ReservationSignal, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: PersonaMetrics.spaceSnug) {
            Text(signal.time)
                .font(.system(size: 15, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(isLast ? PersonaPalette.brand : PersonaPalette.ink)
                // A fixed column keeps the times flush without hard-coding a
                // width that Dynamic Type would then break.
                .frame(minWidth: 42, alignment: .leading)
                .fixedSize()

            gutter(isLast: isLast)

            VStack(alignment: .leading, spacing: 1) {
                Text(signal.event)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(PersonaPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(signal.source)
                    .font(.system(size: 12))
                    .foregroundStyle(PersonaPalette.inkTertiary)
            }
            .padding(.bottom, isLast ? 0 : PersonaMetrics.spaceRegular)

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    /// The dot and the rule beneath it. The final entry has no rule, which is
    /// what makes the sequence read as ending rather than being cut off.
    private func gutter(isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(isLast ? AnyShapeStyle(PersonaPalette.brandGradient)
                             : AnyShapeStyle(PersonaPalette.brand.opacity(0.28)))
                .frame(width: 9, height: 9)
                .padding(.top, 5)

            if !isLast {
                Rectangle()
                    .fill(PersonaPalette.brand.opacity(0.18))
                    .frame(width: 1.5)
                    .padding(.top, 3)
            }
        }
        .frame(width: 9)
        .accessibilityHidden(true)
    }
}
