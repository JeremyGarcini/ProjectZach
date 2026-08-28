import SwiftUI

/// Atmosphere behind the header.
///
/// One soft indigo glow, bled off the top of the screen — not a mesh gradient
/// across the whole page. The distinction matters: a full-bleed mesh puts colour
/// under *every* element, which muddies text, competes with the content and
/// leaves the progressive blur nothing legible to work with. A single
/// concentrated glow instead gives the top of the screen somewhere to come from
/// and disappears entirely by the time content starts.
///
/// It is deliberately close to invisible. If you can point at it and call it a
/// gradient, it is too strong.
struct PersonaAura: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack(alignment: .top) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [PersonaPalette.brand.opacity(0.13), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: width * 0.72
                        )
                    )
                    .frame(width: width * 1.5, height: width * 1.5)
                    .offset(x: -width * 0.30, y: -width * 0.95)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: 0xFF7AC8).opacity(0.09), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: width * 0.58
                        )
                    )
                    .frame(width: width * 1.2, height: width * 1.2)
                    .offset(x: width * 0.48, y: -width * 0.78)
            }
            .frame(width: width, alignment: .top)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
