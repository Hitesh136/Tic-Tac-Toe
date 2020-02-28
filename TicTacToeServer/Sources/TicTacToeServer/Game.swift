//
//  Game.swift
//  COpenSSL
//
//  Created by Hitesh Agarwal on 24/02/20.
//

import Foundation
import PerfectLib
import PerfectHTTPServer
import PerfectHTTP
//import PerfectWebSockets
import PerfectWebSockets
//import TicTacToeShared

enum GameError: Error {
    case failedToSerializeMessageToJsonString(message: Message)
}

class Game {
    static let shared = Game()
    private var playerSocketInfo = [ Player: WebSocket]()
    private var activePlayer: Player?
    private var board = [Tile](repeating: Tile.none, count: 9)
    
    private init() {}
    var players: [Player] {
        Array(playerSocketInfo.keys)
    }
    
    func playerForSocket(webSocket: WebSocket) -> Player? {
        for key in playerSocketInfo.keys {
            if playerSocketInfo[key]! == webSocket {
                return key
            }
        }
        return nil
    }
    
    func handlePlayerLeft(player: Player) throws {
        guard playerSocketInfo[player] != nil else {
            return 
        }
        
        playerSocketInfo[player] = nil
        let message = Message.stop()
        try notifyPlayers(message: message)
    }
    
    func handleJoin(player: Player, webSocket: WebSocket) throws{
        guard playerSocketInfo.count < 2 else {
            return
        }
        playerSocketInfo[player] = webSocket
        if playerSocketInfo.count == 2 {
            try startGame()
        }
    }
    
    func handleTurn(board: [Tile]) throws {
        self.board = board
        if didPlayerWin() {
            let message = Message.finish(board: board, winningPlayer: activePlayer)
            try notifyPlayers(message: message)
        } else if board.filter({ $0 == Tile.none }).count == 0 {
            let message = Message.finish(board: board, winningPlayer: nil)
            try notifyPlayers(message: message)
        } else {
            activePlayer = nextActivePlayer()
            let message = Message.turn(board: board, player: activePlayer)
            try notifyPlayers(message: message)
        }
    }
    
    private func didPlayerWin() -> Bool {
        let winningTiles: [[Int]] = [
            [0, 1, 2], // the bottm row
            [3, 4, 5], // the middle row
            [6, 7, 8], // the top row
            [0, 3, 6], // the left column
            [1, 4, 7], // the middle column
            [2, 5, 8], // the right column
            [0, 4, 8], // diagonally bottom-left to top-right
            [6, 4, 2], // diagonally top-left to bottom-right
        ]
        
        for tileIdxs in winningTiles {
            let tileIdx0 = tileIdxs[0]
            let tileIdx1 = tileIdxs[1]
            let tileIdx2 = tileIdxs[2]
            
            // Check if the 3 tiles are set and are all equal
            if (self.board[tileIdx0] != Tile.none &&
                self.board[tileIdx0] == self.board[tileIdx1] &&
                self.board[tileIdx1] == self.board[tileIdx2]) {
                return true
            }
        }
        
        return false
    }
    
    private func nextActivePlayer() -> Player? {
        return self.players.filter({ $0 != self.activePlayer }).first
    }
    
    private func startGame() throws {
        setupBoard()
        
        activePlayer = randomPlayer()
        let message = Message.turn(board: board, player: activePlayer)
        try notifyPlayers(message: message)
    }
    
    func setupBoard() {
        (0..<9).forEach({
            board[$0] = (Tile.none)
        })
    }
    
    func randomPlayer() -> Player {
        let randomIdx = Int(arc4random() % UInt32(self.players.count))
        return players[randomIdx]
    }
    
    func notifyPlayers(message: Message) throws {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(message)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw GameError.failedToSerializeMessageToJsonString(message: message)
        }
        
        self.playerSocketInfo.values.forEach({
            $0.sendStringMessage(string: jsonString, final: true) {
                print("did send message: \(message.type)")
            }
        })
    }
}
