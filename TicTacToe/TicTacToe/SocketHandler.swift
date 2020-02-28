//
//  SocketHandler.swift
//  TicTacToe
//
//  Created by Hitesh Agarwal on 25/02/20.
//  Copyright © 2020 Hitesh Agarwal. All rights reserved.
//

import Foundation
import Starscream

protocol TicTacToeClientDelegate: AnyObject {
    func clientDidConnect()
    func clientDidDisconnect(_ error: Error?)
    func clientDidReceiveMessage(_ message: Message)
}

class TicTacToeClient {
    
    weak var delegate: TicTacToeClientDelegate?
    private var socket: WebSocket!
    init() {
        let url = URL(string: "http://localhost:8181/game")!
        let urlRequest = URLRequest(url: url)
        socket = WebSocket(request: urlRequest)
        socket.delegate = self
    }
    
    func connect() {
        socket.connect()
    }
    
    func join(player: Player) {
        let message = Message.join(player: player)
        writeMessageToSocket(message)
    }
    
    func playTurn(updateBorad board: [Tile], activePlayer: Player) {
        let message = Message.turn(board: board, player: activePlayer)
        writeMessageToSocket(message)
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func writeMessageToSocket(_ message: Message) {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(message)
            self.socket.write(data: jsonData)
        } catch let error {
            print("Error: \(error)")
        }
    }
}

extension TicTacToeClient: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.clientDidConnect()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.clientDidDisconnect(error)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else {
            print("failed to convert text into data")
            return
        }
        
        do {
            let jsonDecoder = JSONDecoder()
            let message = try jsonDecoder.decode(Message.self, from: data)
            self.delegate?.clientDidReceiveMessage(message)
        } catch let error {
            print("websocketDidReceiveMessage with error: \(error)")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
