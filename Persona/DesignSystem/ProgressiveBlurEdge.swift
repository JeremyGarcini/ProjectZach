import SwiftUI

/// A true progressive blur behind a pinned bar: content dissolves gradually as
/// it slides underneath, blurriest against the bar and perfectly sharp a short
/// distance away.
///
/// **Why this exists alongside iOS 26's `scrollEdgeEffectStyle`.** The system
/// effect is the right default and stays switched on, but it is calibrated for a
/// standard navigation bar. This app pins a two-storey header, so the transition
/// has to travel further before it looks deliberate rather than clipped.
///
/// **How it is built, given there is no public variable-radius blur.** Each layer
/// is a backdrop-sampling material masked to a band that reaches further down
/// than the layer beneath it. Near the bar every band overlaps and the blur
/// compounds; by the end of the ramp only the widest band survives and almost
/// nothing is applied. Stacking public materials gets a smooth radius ramp
/// without the private `CAFilter` variable blur the popular open-source versions
/// reach for — which matters, because private API is not something to ship.
///
/// **The page-colour wash is not optional.** A material over white renders
/// slightly grey, and five of them render as a visible grey slab. Laying the
/// canvas colour over the same ramp cancels that, and it is also what the effect
/// *should* look like: content being absorbed into the page, not hidden behind a
/// panel.
struct ProgressiveBlurEdge: View {
    /// Total height, including whatever sits above the bar (the status bar, say).
    /// Anything beyond the ramp is simply page colour, so an overestimate is safe.
    var height: Double
    /// The visible transition at the far edge, in points. This is the number to
    /// tune: too short reads as a hard cut, too long reads as fog.
    var ramp: Double = 68
    /// More layers means a smoother radius ramp and more compositing. Five is the
    /// point where adding another stopped being visible.
    var layers: Int = 5
    /// Which way content disappears. `.top` behind a header, `.bottom` behind a bar.
    var edge: VerticalEdge = .top

    var body: some View {
        ZStack {
            ForEach(0..<layers, id: \.self) { index in
                Rectangle()
                    .fill(.clear)
                    .background(.ultraThinMaterial)
                    .mask { blurMask(for: index) }
            }
            wash
        }
        .frame(height: height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// Where the ramp begins, as a fraction of the total height.
    private var rampStart: Double {
        max(0, (height - ramp) / height)
    }

    /// Layer 0 spans the entire ramp; each later layer stops earlier, so the
    /// number of overlapping layers — and therefore the blur radius — falls off
    /// with distance from the bar.
    private func blurMask(for index: Int) -> LinearGradient {
        let span = 1.0 - rampStart
        let reach = rampStart + span * (1.0 - Double(index) / Double(layers))

        return gradient(stops: [
            .init(color: .black, location: 0),
            .init(color: .black, location: rampStart),
            .init(color: .clear, location: reach)
        ])
    }

    /// Page colour over the same ramp. The extra midpoint stop biases the falloff
    /// so it eases out instead of running down in a straight line — a linear fade
    /// is the thing that makes a gradient look computed.
    private var wash: LinearGradient {
        let span = 1.0 - rampStart

        return gradient(stops: [
            .init(color: PersonaPalette.canvas, location: 0),
            .init(color: PersonaPalette.canvas, location: rampStart),
            .init(color: PersonaPalette.canvas.opacity(0.55), location: rampStart + span * 0.42),
            .init(color: PersonaPalette.canvas.opacity(0.0), location: 1)
        ])
    }

    private func gradient(stops: [Gradient.Stop]) -> LinearGradient {
        LinearGradient(
            stops: stops,
            startPoint: edge == .top ? .top : .bottom,
            endPoint: edge == .top ? .bottom : .top
        )
    }
}
