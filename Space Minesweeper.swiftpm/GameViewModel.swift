//
//  GameViewModel.swift
//  Space Minesweeper
//
//  Created by Yutong Sun on 2/21/24.
//

import Foundation

import AVFoundation

class GameViewModel: ObservableObject {
    @Published var airplanePosition = CGPoint(x: 100, y: 800)
    @Published var meteorites: [Meteorite] = []
    @Published var lasers: [LaserBeam] = []
    @Published var score = 0
    var backgroundMusicPlayer: AVAudioPlayer?
    var blasterSoundEffectPlayer: AVAudioPlayer?
    var collisionSoundEffectPlayer: AVAudioPlayer?
    
    private var gameTimer: Timer?
    private var moveTimer: Timer?
    private var screenSize: CGSize = .zero
    
    init() {
        setupAudioPlayers()
        startGame(screenSize: .zero)
        startTimers()
    }
    func setupAudioPlayers() {
        if let backgroundMusicURL = Bundle.main.url(forResource: "bensound-lesprisonnieres", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: backgroundMusicURL)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.play()
            } catch {
                print("Could not load background music file.")
            }
        }
        
        if let blasterSoundURL = Bundle.main.url(forResource: "blaster-2-81267", withExtension: "mp3") {
            do {
                blasterSoundEffectPlayer = try AVAudioPlayer(contentsOf: blasterSoundURL)
            } catch {
                print("Could not load blaster sound effect file.")
            }
        }
        
        if let collisionSoundURL = Bundle.main.url(forResource: "doorhit-98828", withExtension: "mp3") {
            do {
                collisionSoundEffectPlayer = try AVAudioPlayer(contentsOf: collisionSoundURL)
            } catch {
                print("Could not load collision sound effect file.")
            }
        }
    }
    
    func startGame(screenSize: CGSize) {
        self.screenSize = screenSize
        meteorites.removeAll()
        lasers.removeAll()
        score = 0
        startTimers()
    }
    
    private func startTimers() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.addMeteorite()
        }
        
        moveTimer?.invalidate()
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }
    
    private func addMeteorite() {
        let size = CGSize(width: 50, height: 50)
        let xPosition = CGFloat.random(in: 0...screenSize.width - size.width)
        let meteorite = Meteorite(id: UUID(), position: CGPoint(x: xPosition, y: -size.height), size: size, velocity: CGPoint(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: 2...4)))
        meteorites.append(meteorite)
    }
    
    private func updateGame() {
        for (index, _) in meteorites.enumerated().reversed() {
            meteorites[index].position.x += meteorites[index].velocity.x
            meteorites[index].position.y += meteorites[index].velocity.y
            
            // Remove meteorites that move off-screen
            if meteorites[index].position.y > screenSize.height + 50 {
                meteorites.remove(at: index)
                continue
            }
        }
        
        for (index, laser) in lasers.enumerated().reversed() {
            lasers[index].position.y -= 10
            
            // Remove lasers that move off-screen
            if laser.position.y < -10 {
                lasers.remove(at: index)
                continue
            }
        }
        
        checkCollisions()
    }
    
    private func checkCollisions() {
        for meteorite in meteorites {
            for laser in lasers {
                if abs(meteorite.position.x - laser.position.x) < 25 && abs(meteorite.position.y - laser.position.y) < 25 {
                    // Collision detected
                    if let meteoriteIndex = meteorites.firstIndex(where: { $0.id == meteorite.id }),
                       let laserIndex = lasers.firstIndex(where: { $0.id == laser.id }) {
                        meteorites.remove(at: meteoriteIndex)
                        lasers.remove(at: laserIndex)
                        score += 1
                        collisionSoundEffectPlayer?.play()
                        break
                    }
                }
            }
        }
    }
    
    func moveAirplane(to position: CGPoint, screenSize: CGSize) {
        let newX = max(50, min(position.x, screenSize.width - 50))
        let newY = max(screenSize.height - 100, min(position.y, screenSize.height - 50))
        airplanePosition = CGPoint(x: newX, y: newY)
    }
    
    func fireLaser() {
        let laser = LaserBeam(id: UUID(), position: CGPoint(x: airplanePosition.x, y: airplanePosition.y - 30))
        lasers.append(laser)
        blasterSoundEffectPlayer?.play()
    }
}

struct Meteorite: Identifiable {
    let id: UUID
    var position: CGPoint
    let size: CGSize
    var velocity: CGPoint
}

struct LaserBeam: Identifiable {
    let id: UUID
    var position: CGPoint
}

