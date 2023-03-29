///
//  CircularProgressView.swift
//  DittoChat
//
// Credit to Sarun W.
// https://sarunw.com/posts/swiftui-circular-progress-bar/
//
//  Created by Eric Turner on 3/27/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct DittoProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var progress: Double
    var side: CGFloat
    private let lineWidth: CGFloat
    
    init(_ progress: Binding<Double>, side: CGFloat = 240) {
        self._progress = progress
        self.side = side
        self.lineWidth = 0.12 * side
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.accentColor.opacity(0.5),
                    lineWidth: lineWidth
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
            
            PercentageLabel($progress, side: side)
        }
        .frame(width: side, height: side, alignment: .center)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: xmarkCircleKey)
                }
            }
        }
    }
}

struct PercentageLabel: View {
    @Binding var progress: Double
    let side: CGFloat
    @ScaledMetric var scale: CGFloat = 1
    private let percentageFactor: CGFloat
    private let percentSignFactor: CGFloat
    
    init(_ progress: Binding<Double>, side: CGFloat) {
        self._progress = progress
        self.side = side
        self.percentageFactor = side * 0.3
        self.percentSignFactor = side * 0.2
    }
    
    var body: some View {
        Group {
            Text("\(progress * 100, specifier: "%.0f")").font(.system(size: percentageFactor * scale, weight: .bold, design: .rounded))
            + Text("%").font(.system(size: percentSignFactor * scale, weight: .bold, design: .rounded))
        }
        .lineLimit(1)
    }
}

struct DittoProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DittoProgressView(
                .constant (1),// (0.42),
                side: 100
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
