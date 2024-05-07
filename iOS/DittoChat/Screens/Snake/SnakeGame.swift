//
//  SnakeGame.swift
//  Snake
//
//  Created by Shaunak Jagtap on 14/04/24.
//

import SwiftUI

// Constants for game settings
let gridSize: CGFloat = 20
let horizontalPadding: CGFloat = 30
let verticalPadding: CGFloat = 250

// Enum representing directions
enum Direction {
    case up, down, left, right
}

// Main view representing the game
@available(macOS 10.15, *)
struct SnakeGameView: View {
    @StateObject var viewModel = SnakeGameViewModel()

    var body: some View {
        GeometryReader { geometry in
            let calculatedGameWidth = geometry.size.width - horizontalPadding
            let calculatedGameHeight = geometry.size.height - verticalPadding
            
            VStack {
                ZStack {
                    // Game board
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: calculatedGameWidth, height: calculatedGameHeight)
                        .border(Color.white, width: 2)
                        .clipped() // Avoid potential view clipping
                    
                    // Snake
                    ForEach(viewModel.snake, id: \.self) { segment in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: gridSize, height: gridSize)
                            .position(segment.position)
                    }
                    
                    // Food (replaced with rat emoji)
                    Text("🍓")
                        .font(.system(size: min(calculatedGameWidth, calculatedGameHeight) * 0.05)) // Dynamically adjust font size
                        .position(viewModel.food.position)
                        .zIndex(1) // Ensure the food is on top of the snake
                    
                    // Fireworks animation at the position of the food when eaten
                    if viewModel.foodEaten {
                        FireworksAnimation()
                            .frame(width: 100, height: 100) // Adjust size as needed
                            .position(viewModel.food.position)
                            .onAppear {
                                // Reset the foodEaten flag after a short delay to allow the fireworks animation to play
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    viewModel.foodEaten = false
                                }
                            }
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded(viewModel.handleSwipe)
                )
                .onAppear {
                    viewModel.startGame(width: calculatedGameWidth, height: calculatedGameHeight)
                }
                .onDisappear(perform: viewModel.stopGame)
                
                Button(action: viewModel.restartGame) {
                    Text("Restart")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding() // Add padding for better spacing
                
                Text("Score: \(viewModel.score)")
                    .foregroundColor(.white)
                    .padding()
                    .padding()
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        }
    }
}
