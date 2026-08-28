import SwiftUI

/// The pinned header.
///
/// It stays put while the request scrolls beneath it, and it carries the
/// progressive blur that makes that legible. The bar itself has no opaque
/// background — if it did, the blur behind it would be invisible.
struct ApprovalTopBar: View {
    @Binding var selection: ApprovalScenario
    let isWorking: Bool
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: PersonaMetrics.spaceSnug) {
            identity
            PersonaSegmentedControl(
                options: ApprovalScenario.allCases,
                selection: $selection,
                title: \.switcherTitle
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Approval stakes")
        }
        .frame(maxWidth: PersonaMetrics.contentMaxWidth)
        .padding(.horizontal, PersonaMetrics.spaceMargin)
        .padding(.bottom, PersonaMetrics.spaceSnug)
        .frame(maxWidth: .infinity)
        .background(alignment: .bottom) { blur }
    }

    /// Mira, named and present. The mark doubles as the activity indicator, so
    /// the header quietly shows that something is happening without a second
    /// spinner appearing elsewhere.
    private var identity: some View {
        HStack(spacing: PersonaMetrics.spaceSnug) {
            PersonaMark(size: 38, isWorking: isWorking)

            VStack(alignment: .leading, spacing: 1) {
                Text("Mira")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(PersonaPalette.ink)
                Text(isWorking ? "Working on it" : "Your Persona")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isWorking ? PersonaPalette.brand : PersonaPalette.inkTertiary)
                    .contentTransition(.opacity)
            }

            Spacer(minLength: PersonaMetrics.spaceTight)

            Button("Start over", systemImage: "arrow.counterclockwise", action: onReset)
                .labelStyle(.iconOnly)
                .buttonStyle(PersonaCompactIconButtonStyle())
                .accessibilityInputLabels(["Start over", "Reset"])
        }
        .frame(minHeight: PersonaMetrics.hitTarget)
    }

    /// The progressive blur, anchored to the bar's bottom edge and bleeding up
    /// through the status bar. The negative bottom padding pushes the ramp below
    /// the bar, so the last sharp thing the eye sees is the header and the first
    /// blurred thing is content.
    private var blur: some View {
        ProgressiveBlurEdge(height: 300, ramp: PersonaMetrics.scrollEdgeRamp)
            .padding(.bottom, -PersonaMetrics.scrollEdgeOverhang)
            .ignoresSafeArea(edges: .top)
    }
}

/// A smaller sibling of `PersonaIconButtonStyle`, sized for the header where a
/// 52pt target would dominate the row.
struct PersonaCompactIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(PersonaPalette.inkSecondary)
            .frame(width: 40, height: 40)
            .background(PersonaPalette.surfaceRaised, in: .circle)
            .overlay { Circle().strokeBorder(PersonaPalette.borderStrong, lineWidth: 1) }
            .personaElevation(.card)
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(PersonaMetrics.controlResponse, value: configuration.isPressed)
    }
}
