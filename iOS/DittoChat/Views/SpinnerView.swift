//
//  SpinnerView.swift
//  DittoChat
//
//  Created by Eric Turner on 3/3/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

extension View {
    func spinnerView(_ size: CGSize = CGSize(width: 28, height: 28)) -> some View {
        SpinnerView()
            .frame(width: size.width, height: size.height)
    }
}

struct SpinnerView: View {
    let primary: Color
    let secondary: Color

    init(primary: Color = .white, secondary: Color = .white.opacity(0.2)) {
        self.primary = primary
        self.secondary = secondary
    }

    var body: some View {
        SpinningView(
            content:
            Arc(startAngle: .degrees(0), endAngle: .degrees(-270))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            primary,
                            primary,
                            secondary,
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(-270)
                    ),
                    lineWidth: 3
                )
        )
    }
}

struct SpinningView<Content: View>: View {
    @State var isAnimating = false
    let content: Content

    var body: some View {
        content
            .rotationEffect(isAnimating ? Angle(degrees: 360) : .zero)
            .onAppear {
                withAnimation(
                    Animation
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct Arc: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(
                x: rect.maxX / 2.0,
                y: rect.maxY / 2.0
            ),
            radius: rect.maxX / 2.0,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        return path
    }
}
