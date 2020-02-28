//
//  GameHandler.swift
//  COpenSSL
//
//  Created by Hitesh Agarwal on 25/02/20.
//

import Foundation
import PerfectHTTP
import PerfectWebSockets
//import TicTacToeShared

class GameHandler: WebSocketSessionHandler {
    var socketProtocol: String? = "tictactoe"
    
    func handleSession(request req: HTTPRequest, socket: WebSocket) {
        socket.readStringMessage { (string, op, fin) in
            
            guard let _string = string else {
                if let player = Game.shared.playerForSocket(webSocket: socket) {
                    
                    do {
                        try Game.shared.handlePlayerLeft(player: player)
                        print("Socket closed for player: \(player.id)")
                    } catch let error {
                        print("Error while closing the socket: \(error)")
                    }
                }
                
                return socket.close()
            }
            
            guard let messageData = _string.data(using: .utf8) else {
                print("Failed while convert string into data object: \(_string)")
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let message = try jsonDecoder.decode(Message.self, from: messageData)
                switch message.type {
                case .join:
                    guard let player = message.player else {
                        return print("Player not find")
                    }
                    try Game.shared.handleJoin(player: player, webSocket: socket)
                case .turn:
                    guard let board = message.board else {
                        return print("Board not find")
                    }
                    try Game.shared.handleTurn(board: board)
                default:
                    break
                }
            } catch let error {
                print(error)
            }
            
            self.handleSession(request: req, socket: socket)
        }
    }
    
    
}
