import SwiftUI

// MARK: - Button roles

/// The one action that advances the flow. Exactly one per screen.
///
/// A gradient capsule that glows in its own indigo rather than a flat fill. The
/// glow is what separates a button that looks placed from one that looks lit —
/// it is the same trick as the coloured shadow under the mark.
struct PersonaPrimaryButtonStyle: ButtonStyle {
    var fullWidth = false

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, fullWidth ? 0 : 22)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: 52)
            .background(PersonaPalette.brandGradient, in: .capsule)
            .overlay {
                // A bright inner edge along the top. Real objects catch light there.
                Capsule().strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.35), .white.opacity(0.04)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            }
            .personaGlow(PersonaPalette.brand, intensity: isEnabled ? 1 : 0)
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(PersonaMetrics.controlResponse, value: configuration.isPressed)
    }
}

/// Everything the user can do that is not the primary action. Liquid Glass, per
/// Apple's guidance that glass is the material of controls floating above
/// content — which is also why no card in this app is made of it.
struct PersonaSecondaryButtonStyle: ButtonStyle {
    var fullWidth = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(PersonaPalette.ink)
            .padding(.horizontal, fullWidth ? 0 : 20)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: 52)
            // Solid white rather than a material. Over a near-white page a
            // translucent material has nothing to refract and just reads as a
            // washed-out smudge; the page is not busy enough to earn glass.
            .background(PersonaPalette.surfaceRaised, in: .capsule)
            .overlay { Capsule().strokeBorder(PersonaPalette.borderStrong, lineWidth: 1) }
            .personaElevation(.card)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(PersonaMetrics.controlResponse, value: configuration.isPressed)
    }
}

/// A circular icon-only control. Same material as the secondary button so the
/// two read as one family when they sit side by side in the bar.
struct PersonaIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(PersonaPalette.inkSecondary)
            .frame(width: 52, height: 52)
            .background(PersonaPalette.surfaceRaised, in: .circle)
            .overlay { Circle().strokeBorder(PersonaPalette.borderStrong, lineWidth: 1) }
            .personaElevation(.card)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(PersonaMetrics.controlResponse, value: configuration.isPressed)
    }
}

extension View {
    func personaPrimaryAction(fullWidth: Bool = false) -> some View {
        buttonStyle(PersonaPrimaryButtonStyle(fullWidth: fullWidth))
    }

    func personaSecondaryAction(fullWidth: Bool = false) -> some View {
        buttonStyle(PersonaSecondaryButtonStyle(fullWidth: fullWidth))
    }

    func personaIconAction() -> some View {
        buttonStyle(PersonaIconButtonStyle())
    }
}

// MARK: - Segmented control

/// The demo switcher.
///
/// Hand-built rather than `.pickerStyle(.segmented)` so the active pill can
/// carry the brand gradient and *slide* between options via
/// `matchedGeometryEffect`. The system control cannot be tinted, and a grey
/// active segment is exactly the kind of default that makes a screen look
/// assembled rather than designed.
struct PersonaSegmentedControl<Option: Hashable & Identifiable>: View {
    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> String

    @Namespace private var pill
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options) { option in
                Button {
                    withAnimation(PersonaMetrics.motion(.control, reduceMotion: reduceMotion)) {
                        selection = option
                    }
                } label: {
                    Text(title(option))
                        .font(.system(size: 14, weight: selection == option ? .semibold : .medium))
                        .foregroundStyle(selection == option ? .white : PersonaPalette.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background {
                            if selection == option {
                                Capsule()
                                    .fill(PersonaPalette.brandGradient)
                                    .personaGlow(PersonaPalette.brand, intensity: 0.6)
                                    .matchedGeometryEffect(id: "pill", in: pill)
                            }
                        }
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == option ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(4)
        .background(PersonaPalette.surface, in: .capsule)
        .overlay { Capsule().strokeBorder(PersonaPalette.border, lineWidth: 1) }
    }
}

// MARK: - The high-stakes commit control

/// Sending a message to a real person should not be reachable by the same
/// gesture as nudging a dinner reservation. A tap is one accident away; a
/// deliberate held press is not, and it gives the user a full second in which
/// letting go is free. This is where the brief's "where does the friction
/// belong" question gets its answer, and it is friction the user can feel rather
/// than another dialog.
///
/// The hold is interruptible by design: releasing early — or sliding a finger
/// off — retracts the fill and nothing is sent. Assistive technologies get a
/// plain button instead, since a timed hold is not something VoiceOver or Switch
/// Control should have to reproduce.
struct HoldToConfirmButton: View {
    let title: String
    let symbol: String
    /// Long enough to be a decision, short enough that it never feels punitive.
    var holdDuration: Double = 1.1
    let action: () -> Void

    @State private var progress = 0.0
    @State private var isHolding = false
    @State private var didComplete = false
    @State private var completion: Task<Void, Never>?

    /// How far the finger may wander before the hold is abandoned.
    private static let escapeDistance = 44.0

    var body: some View {
        Capsule()
            .fill(PersonaPalette.brandTint)
            .overlay(alignment: .leading) { sweep }
            .overlay { label(PersonaPalette.brand) }
            // The same label in white, revealed only where the sweep has passed.
            // One extra layer, and it is the detail that makes the control feel
            // machined rather than assembled.
            .overlay { label(.white).mask(sweepMask) }
            .clipShape(.capsule)
            .overlay { Capsule().strokeBorder(PersonaPalette.brand.opacity(0.22), lineWidth: 1) }
            .frame(height: 58)
            .contentShape(.capsule)
            .personaGlow(PersonaPalette.brand, intensity: 0.4 + progress * 0.6)
            .scaleEffect(isHolding ? 0.985 : 1)
            .animation(PersonaMetrics.controlResponse, value: isHolding)
            .gesture(pressGesture)
            .sensoryFeedback(.impact(weight: .light), trigger: isHolding) { _, holding in holding }
            .sensoryFeedback(.success, trigger: didComplete) { _, done in done }
            .accessibilityRepresentation { Button(title, action: action) }
    }

    private var sweep: some View {
        Rectangle()
            .fill(PersonaPalette.brandGradient)
            .scaleEffect(x: progress, anchor: .leading)
    }

    private var sweepMask: some View {
        Rectangle().scaleEffect(x: progress, anchor: .leading)
    }

    private func label(_ color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
            Text(title)
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(color)
    }

    /// `minimumDistance: 0` fires on touch-down rather than after a drag
    /// threshold, so the fill starts the instant the finger lands.
    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if value.translation.width.magnitude > Self.escapeDistance
                    || value.translation.height.magnitude > Self.escapeDistance {
                    cancelHold()
                } else {
                    beginHold()
                }
            }
            .onEnded { _ in cancelHold() }
    }

    private func beginHold() {
        guard !isHolding, !didComplete else { return }
        isHolding = true
        withAnimation(.linear(duration: holdDuration)) { progress = 1 }

        completion = Task {
            try? await Task.sleep(for: .seconds(holdDuration))
            guard !Task.isCancelled else { return }
            didComplete = true
            action()
            isHolding = false
        }
    }

    private func cancelHold() {
        completion?.cancel()
        guard !didComplete else { return }
        isHolding = false
        withAnimation(PersonaMetrics.controlResponse) { progress = 0 }
    }
}

/// A sheet's committing action: full width, because a sheet has one job.
struct PersonaCommitButton: View {
    let title: String
    var symbol: String?
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let symbol { Image(systemName: symbol) }
                Text(title)
            }
        }
        .personaPrimaryAction(fullWidth: true)
        .disabled(!isEnabled)
    }
}
