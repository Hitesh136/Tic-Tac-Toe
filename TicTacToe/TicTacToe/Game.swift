//
//  Game.swift
//  TicTacToe
//
//  Created by Hitesh Agarwal on 25/02/20.
//  Copyright © 2020 Hitesh Agarwal. All rights reserved.
//

import Foundation
import CoreGraphics

class GameViewModel: ObservableObject {

    // We use an array of tiles to represent the game board.
    @Published var board = [Tile]()
    
    // We use this client for interacting with the server.
    private (set) var client = TicTacToeClient()

    // The state is initally disconnected - wait for the client to connect.
    @Published var state: GameState = .disconnected

    // This player instance represents the player behind this device.
    @Published var player = Player()
        
    // The tile type for the currently active player
    private (set) var playerTile: Tile = .none
  
    @Published var showActionSheet = false
    // MARK: - Public
    
    func start() {
        self.client.delegate = self
        self.client.connect()
    }
    
    func stop() {
        self.client.disconnect()
    }
     
    func getArrayIndex(xIndex: Int, yIndex: Int) -> Int {
        return (3 * yIndex) + xIndex
    }
        
    func getTextFor(xIndex: Int, yIndex: Int) -> String {
        let index = getArrayIndex(xIndex: xIndex, yIndex: yIndex)
        if index < board.count {
            return board[index].rawValue
        }
        return ""
    }

    func playTile(at_xIndexs xIndex: Int,and_yIndex yIndex: Int) {
        let index = getArrayIndex(xIndex: xIndex, yIndex: yIndex)
        
        let tile = self.board[index]
        if tile == .none {
            self.board[index] = self.playerTile
            self.client.playTurn(updateBorad: self.board, activePlayer: self.player)
            self.state = .waiting
        }
    }

    // MARK: - Private

    private func configurePlayerTileIfNeeded(_ playerTile: Tile) {
        let emptyTiles = board.filter({ $0 == .none })
        if emptyTiles.count == 9 {
            self.playerTile = playerTile
        }
    }
}

// MARK: - TicTacToeClientDelegate

extension GameViewModel: TicTacToeClientDelegate {
    func clientDidDisconnect(_ error: Error?) {
        self.state = .disconnected
    }
    
    func clientDidConnect() {
        self.client.join(player: self.player)
        self.state = .connected
    }
    
    func clientDidReceiveMessage(_ message: Message) {
        if let board = message.board {
            self.board = board
        }
        
        switch message.type {
        case .finish:
            self.playerTile = .none
            
            if let winningPlayer = message.player {
                self.state = (winningPlayer == self.player) ? .playerWon : .playerLost
            } else {
                self.state = .draw
            }
            showActionSheet = true
        case .stop:
            self.board = [Tile]()
            
            self.playerTile = .none

            self.state = .stopped
        case .turn:
            guard let activePlayer = message.player else {
                print("no player found - this should never happen")
                return
            }
            
            if activePlayer == self.player {
                self.state = .active
                configurePlayerTileIfNeeded(.x)
            } else {
                self.state = .waiting
                configurePlayerTileIfNeeded(.o)
            }
        default: break
        }
    } 
}
