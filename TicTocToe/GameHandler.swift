//
//  GameHandler.swift
//  TicTocToe
//
//  Created by Hitesh Agarwal on 21/02/20.
//  Copyright © 2020 Hitesh Agarwal. All rights reserved.
//

import Foundation

enum BoxValue {
    case cross
    case circle
    case empty
    
    var description: String {
        switch self {
        case .cross:
            return "〇"
        case .circle:
            return "✗"
        case .empty:
            return ""
        }
    }
}

struct Box {
    var value: BoxValue
    init(value: BoxValue) {
        self.value = value
    }
}

class GameViewModel: ObservableObject {
    @Published var squares = [Box]()
    var movesCount = 0
    @Published var showActionSheet = false
    var lastMove: BoxValue = .cross
    
    init() {
        resetSquares()
    }
    
    func resetSquares() {
        squares = []
        for _ in 0...8 {
            squares.append(Box(value: .empty))
        }
        movesCount = 0
        lastMove = .cross
    }
    
    func getCurrentMove() -> BoxValue {
        if lastMove == .circle {
            lastMove = .cross
        } else {
            lastMove = .circle
        }
        return lastMove
    }
    
    func getArrayIndex(xIndex: Int, yIndex: Int) -> Int {
        return (3 * yIndex) + xIndex
    }
    
    func getTextFor(xIndex: Int, yIndex: Int) -> String {
        let index = getArrayIndex(xIndex: xIndex, yIndex: yIndex)
        if index < squares.count {
            return squares[index].value.description
        }
        return ""
    }
    
    func makeMove(xIndex: Int, yIndex: Int) {
        let index = getArrayIndex(xIndex: xIndex, yIndex: yIndex)
        guard squares[index].value == .empty else {
            return
        }
        squares[index].value = getCurrentMove()
        movesCount += 1
        if movesCount == 9 {
            showActionSheet = true
        } else if winner != .empty {
            showActionSheet = true
        }
    }
    
    var winner: BoxValue {
        if let winner = checkWinner(indexs: [0, 1, 2]) {
            return winner
        } else if let winner = checkWinner(indexs: [3, 4, 5]) {
            return winner
        } else if let winner = checkWinner(indexs: [6, 7, 8]) {
            return winner
        } else if let winner = checkWinner(indexs: [0, 3, 6]) {
            return winner
        } else if let winner = checkWinner(indexs: [1, 4, 7]) {
            return winner
        } else if let winner = checkWinner(indexs: [2, 5, 8]) {
            return winner
        } else if let winner = checkWinner(indexs: [0, 4, 8]) {
            return winner
        } else if let winner = checkWinner(indexs: [2, 4, 6]) {
            return winner
        }
        return .empty
    }
    
    func checkWinner(indexs: [Int]) -> BoxValue? {
        var crossWinners = 0
        var circleWinners = 0
        for index in indexs {
            if squares[index].value == .cross {
                crossWinners += 1
            } else if squares[index].value == .circle {
                circleWinners += 1
            }
        }
        
        if crossWinners == 3 {
            return .cross
        } else if circleWinners == 3 {
            return .circle
        }
        return nil
    }
}
