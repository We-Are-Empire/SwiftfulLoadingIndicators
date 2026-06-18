//
//  LoadingFiveLinesPulse.swift
//  SwiftfulLoadingIndicators
//
//  Created by Nick Sarno on 1/12/21.
//

import SwiftUI

struct LoadingFiveLinesPulse: View {

    let timing: Double

    let maxCounter: Int = 5
    @State var counter = 0

    let frame: CGSize
    let primaryColor: Color

    init(color: Color = .black, size: CGFloat = 50, speed: Double = 0.5) {
        timing = speed / 2
        frame = CGSize(width: size, height: size)
        primaryColor = color
    }

    var body: some View {
        HStack(spacing: frame.width / 10) {
            ForEach(0..<maxCounter) { index in
                
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(primaryColor)
                    .frame(maxHeight:
                            (index == 2) && (counter == 0) ? .infinity :
                            (index == 1 || index == 3) && (counter == 1) ? .infinity :
                            (index == 0 || index == 4) && (counter == 2) ? .infinity :
                            frame.height / 2
                    )
            }
        }
        .frame(width: frame.width, height: frame.height, alignment: .center)
        // FUSE-COMPAT: Combine Timer.publish is unavailable on Skip-Fuse Android; a
        // Task.sleep loop ticks the phase counter cross-platform with identical timing.
        // This style cycles a 4-phase counter (0...3), not 0..<maxCounter.
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(timing * 1_000_000_000))
                withAnimation(Animation.easeOut(duration: timing)) {
                    counter = counter == 3 ? 0 : counter + 1
                }
            }
        }
    }
}

#if !os(Android)
struct LoadingFiveLinesPulse_Previews: PreviewProvider {
    static var previews: some View {
        LoadingPreviewView(animation: .fiveLinesPulse)
    }
}
#endif
