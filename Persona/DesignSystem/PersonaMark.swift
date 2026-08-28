import SwiftUI

/// Mira's mark.
///
/// A monogram on a lit indigo sphere. It is built like a contact avatar rather
/// than an "AI" badge, because the brief describes Persona as something you name
/// and live alongside — a rainbow ring and a `sparkles` glyph say "a robot made
/// this", which is the opposite claim.
///
/// What makes it read as an object rather than a coloured circle is four things
/// layered in this order: a diagonal brand gradient, a specular highlight offset
/// toward the light, a bright rim along the lit edge, and — the one most often
/// left out — a shadow cast in its own indigo instead of in black.
struct PersonaMark: View {
    /// Diameter in points. Everything inside scales from this single number.
    var size: Double = 40
    /// Draws the progress ring. True whenever Persona is doing the thing it asked about.
    var isWorking: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var ringRotation = 0.0

    var body: some View {
        ZStack {
            sphere
            monogram
            if isWorking { activityRing }
        }
        .frame(width: size, height: size)
        .personaGlow(PersonaPalette.brand, intensity: size / 60)
        .accessibilityHidden(true)
    }

    private var sphere: some View {
        Circle()
            .fill(PersonaPalette.markGradient)
            .overlay {
                // Specular highlight, offset up and left toward the light source.
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.55), .white.opacity(0)],
                            center: UnitPoint(x: 0.3, y: 0.2),
                            startRadius: 0,
                            endRadius: size * 0.52
                        )
                    )
            }
            .overlay {
                // Lit rim: bright where the light lands, gone by the bottom.
                Circle().strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.65), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: max(0.6, size * 0.022)
                )
            }
    }

    private var monogram: some View {
        Text("M")
            .font(.system(size: size * 0.40, weight: .bold))
            .tracking(size * -0.008)
            .foregroundStyle(.white)
            // SF Pro's cap height sits high in the em box; this centres it optically.
            .offset(y: size * 0.012)
            .shadow(color: PersonaPalette.brandDeep.opacity(0.35), radius: size * 0.04, y: 1)
    }

    /// A progress ring around the mark, so the identity carries the activity and
    /// no foreign spinner has to appear beside it.
    private var activityRing: some View {
        let width = max(2, size * 0.05)

        return ZStack {
            Circle().stroke(PersonaPalette.brand.opacity(0.16), lineWidth: width)

            Circle()
                .trim(from: 0, to: 0.28)
                .stroke(
                    PersonaPalette.brandGradient,
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
                .rotationEffect(.degrees(ringRotation))
        }
        .padding(-size * 0.13)
        .onAppear {
            // Reduce Motion means no perpetual rotation. The static track still
            // shows that something is in flight.
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
        .onDisappear { ringRotation = 0 }
    }
}

#Preview {
    HStack(spacing: 28) {
        PersonaMark(size: 32)
        PersonaMark(size: 44)
        PersonaMark(size: 76, isWorking: true)
    }
    .padding(60)
    .background(PersonaPalette.canvas)
}
