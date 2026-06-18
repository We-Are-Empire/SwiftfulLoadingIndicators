//
//  LoadingThreeBalls.swift
//  SwiftfulLoadingIndicators
//
//  Created by Nick Sarno on 1/12/21.
//

import SwiftUI

struct LoadingThreeBalls: View {

    let timing: Double

    let maxCounter = 3
    @State var counter = 0

    let frame: CGSize
    let primaryColor: Color

    init(color: Color = .black, size: CGFloat = 50, speed: Double = 0.5) {
        timing = speed
        frame = CGSize(width: size, height: size)
        primaryColor = color
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<maxCounter) { index in
                Circle()
                    .scale(counter == index ? 1.0 : 0.5)
                    .fill(primaryColor)
            }
        }
        .frame(width: frame.width, height: frame.height, alignment: .center)
        // FUSE-COMPAT: Combine Timer.publish is unavailable on Skip-Fuse Android; a
        // Task.sleep loop ticks the phase counter cross-platform with identical timing.
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(timing * 1_000_000_000))
                withAnimation(.linear(duration: timing)) {
                    counter = counter == (maxCounter - 1) ? 0 : counter + 1
                }
            }
        }
    }
}

#if !os(Android)
struct LoadingThreeBalls_Previews: PreviewProvider {
    static var previews: some View {
        LoadingPreviewView(animation: .threeBalls)
    }
}
#endif
