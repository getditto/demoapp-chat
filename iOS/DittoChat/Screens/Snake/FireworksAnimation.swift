//
//  FireworksAnimation.swift
//  Snake
//
//  Created by Shaunak Jagtap on 14/04/24.
//

import SwiftUI

struct FireworksAnimation: View {
    @State private var particles: [Particle] = []
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                if particles.isEmpty {
                    particles = (0..<100).map { _ in Particle.random() }
                } else {
                    particles = particles.map { $0.update() }
                    if particles.allSatisfy({ $0.alpha <= 0 }) {
                        timer?.invalidate()
                    }
                }
            }
        }
    }
}

struct Particle: Identifiable {
    var id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var alpha: Double
    var size: CGFloat
    var color: Color
    
    func update() -> Particle {
        let newPosition = CGPoint(x: position.x + velocity.x, y: position.y + velocity.y)
        let newAlpha = max(alpha - 0.01, 0)
        return Particle(position: newPosition, velocity: velocity, alpha: newAlpha, size: size, color: color)
    }
    
    static func random() -> Particle {
        let position = CGPoint(x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                               y: CGFloat.random(in: 0..<UIScreen.main.bounds.height))
        let velocity = CGPoint(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: -2...2))
        let alpha = Double.random(in: 0.5...1)
        let size = CGFloat.random(in: 2...6)
        let color = Color(hue: Double.random(in: 0...1), saturation: 1, brightness: 1, opacity: 1)
        return Particle(position: position, velocity: velocity, alpha: alpha, size: size, color: color)
    }
}

