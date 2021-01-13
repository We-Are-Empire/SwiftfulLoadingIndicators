//
//  LoadingShowcaseView.swift
//  SwiftUICookbook (iOS)
//
//  Created by Nick Sarno on 1/12/21.
//

import SwiftUI

public struct LoadingShowcaseView: View {
    public var body: some View {
        #if iOS
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 10, content: {
                ForEach(LoadingIndicator.LoadingAnimation.allCases, id: \.self) { item in
                    VStack(spacing: 10) {
                        LoadingIndicator(animation: item)
                        Text(".\(item.rawValue)")
                            .font(.caption)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                    }
                }
            })
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        #else
        Text("Showcase view is only available on iOS devices.")
        #endif
    }
}

struct LoadingShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingShowcaseView()
    }
}
