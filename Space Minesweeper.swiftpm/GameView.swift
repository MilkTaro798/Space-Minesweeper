//
//  GameView.swift
//  Space Minesweeper
//
//  Created by Yutong Sun on 2/21/24.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel = GameViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Text("Score: \(viewModel.score)")
                    .foregroundColor(.white)
                    .position(x: geometry.size.width / 2, y: 20)
                
                Image("airPlane")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .position(viewModel.airplanePosition)
                    .gesture(DragGesture().onChanged { gesture in
                        viewModel.moveAirplane(to: gesture.location, screenSize: geometry.size)
                    })
                
                ForEach(viewModel.meteorites) { meteorite in
                    Image("meteorite")
                        .resizable()
                        .frame(width: meteorite.size.width, height: meteorite.size.height)
                        .position(meteorite.position)
                }
                
                ForEach(viewModel.lasers) { laser in
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 3, height: 30)
                        .position(laser.position)
                }
            }
            .onAppear {
                viewModel.startGame(screenSize: geometry.size)
            }
            .gesture(TapGesture().onEnded {
                viewModel.fireLaser()
            })
        }
    }
}


#Preview {
    GameView()
}
