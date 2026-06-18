//
//  LoadingText.swift
//  SwiftfulLoadingIndicators
//
//  Created by Nick Sarno on 1/13/21.
//

import SwiftUI

struct LoadingText: View {

    let items: [String] = "Loading...".map { String($0) }

    let timing: Double

    let maxCounter: Int = 10
    @State var counter = 0

    let frame: CGSize
    let primaryColor: Color

    init(color: Color = .black, size: CGFloat = 50, speed: Double = 0.5) {
        timing = speed / 4
        frame = CGSize(width: size, height: size)
        primaryColor = color
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                Text(items[index])
                    .foregroundColor(primaryColor)
                    .font(.system(size: frame.height / 3, weight: .semibold, design: .default))
                    .offset(y: counter == index ? -frame.height / 8 : 0)
            }
        }
        .frame(height: frame.height, alignment: .center)
        // FUSE-COMPAT: Combine Timer.publish is unavailable on Skip-Fuse Android; a
        // Task.sleep loop ticks the phase counter cross-platform with identical timing.
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(timing * 1_000_000_000))
                withAnimation(Animation.spring()) {
                    counter = counter == (maxCounter - 1) ? 0 : counter + 1
                }
            }
        }
    }

}

struct LoadingText_Previews: PreviewProvider {
    static var previews: some View {
        LoadingPreviewView(animation: .text)
    }
}
