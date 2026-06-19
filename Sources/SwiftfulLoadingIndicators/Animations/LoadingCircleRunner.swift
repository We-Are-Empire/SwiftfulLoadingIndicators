//
//  LoadingCircleRunner.swift
//  SwiftfulLoadingIndicators
//
//  Created by Nick Sarno on 1/12/21.
//

import SwiftUI

struct LoadingCircleRunner: View {

    @State var isAnimating: Bool = false
    // Android-only: a continuously-incrementing rotation so the wheel spins
    // forever rather than ping-ponging 0↔360 (see the Task loop below).
    @State var rotation: Double = 0
    let timing: Double

    let frame: CGSize
    let primaryColor: Color

    init(color: Color = .black, size: CGFloat = 50, speed: Double = 0.5) {
        timing = speed * 4
        frame = CGSize(width: size, height: size)
        primaryColor = color
    }

    var body: some View {
        #if os(Android)
        // FUSE-COMPAT: on Skip-Fuse, `Animation.repeatForever()` driven by a single
        // `onAppear` toggle does NOT loop — it animates one transition and stops, so
        // the indicator renders static (it shows, but never spins). Drive both the
        // trim pulse and the rotation from a Task-sleep loop instead — the pattern the
        // already-working indicators use (e.g. LoadingThreeBalls). Increment `rotation`
        // each cycle so the spin is continuous, and toggle `isAnimating` each half-cycle
        // for the stroke-width/trim pulse.
        Circle()
            .trim(from: isAnimating ? 0.9 : 0.8, to: 1.0)
            .stroke(primaryColor,
                    style: StrokeStyle(lineWidth:
                        isAnimating ? frame.height / 10 : frame.height / 20,
                                       lineCap: .round, lineJoin: .round)
            )
            .rotationEffect(Angle(degrees: rotation))
            .frame(width: frame.width, height: frame.height, alignment: .center)
            .rotationEffect(Angle(degrees: 360 * 0.15))
            .task {
                while !Task.isCancelled {
                    withAnimation(.linear(duration: timing)) { rotation += 360 }
                    withAnimation(.easeInOut(duration: timing / 2)) { isAnimating = true }
                    try? await Task.sleep(nanoseconds: UInt64(timing / 2 * 1_000_000_000))
                    withAnimation(.easeInOut(duration: timing / 2)) { isAnimating = false }
                    try? await Task.sleep(nanoseconds: UInt64(timing / 2 * 1_000_000_000))
                }
            }
        #else
        Circle()
            .trim(from: isAnimating ? 0.9 : 0.8, to: 1.0)
            .stroke(primaryColor,
                    style: StrokeStyle(lineWidth:
                        isAnimating ? frame.height / 10 : frame.height / 20,
                                       lineCap: .round, lineJoin: .round)
            )
            .animation(Animation.easeInOut(duration: timing / 2).repeatForever(), value: isAnimating)
            .rotationEffect(
                Angle(degrees: isAnimating ? 360 : 0)
            )
            .animation(Animation.linear(duration: timing).repeatForever(autoreverses: false), value: isAnimating)
            .frame(width: frame.width, height: frame.height, alignment: .center)
            .rotationEffect(Angle(degrees: 360 * 0.15))
            .onAppear {
                isAnimating.toggle()
            }
        #endif
    }
}

#if !os(Android)
struct LoadingCircleRunner_Previews: PreviewProvider {
    static var previews: some View {
        LoadingPreviewView(animation: .circleRunner)
    }
}
#endif
