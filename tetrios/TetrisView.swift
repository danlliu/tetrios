//
//  ContentView.swift
//  tetrios
//
//  Created by Daniel Liu on 6/18/23.
//

import SwiftUI

enum Piece {
    case I
    case O
    case L
    case J
    case Z
    case S
    case T
    case Empty
    
    func colorForPiece() -> Color {
        switch self {
        case Piece.I:
            return Color.cyan
        case Piece.O:
            return Color.yellow
        case Piece.L:
            return Color.orange
        case Piece.J:
            return Color.blue
        case Piece.Z:
            return Color.red
        case Piece.S:
            return Color.green
        case Piece.T:
            return Color.purple
        case Piece.Empty:
            return Color.init(uiColor: UIColor.lightGray)
        }
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: Piece) {
        switch value {
        case .I:
            appendInterpolation("I")
        case .O:
            appendInterpolation("O")
        case .L:
            appendInterpolation("L")
        case .J:
            appendInterpolation("J")
        case .Z:
            appendInterpolation("Z")
        case .S:
            appendInterpolation("S")
        case .T:
            appendInterpolation("T")
        case .Empty:
            appendInterpolation("<empty>")
        }
    }
}

struct TetrisAbstractCell : Identifiable {
    weak var controller: TetrisController!
    var id: Int
    var piece: Piece = Piece.Empty
    var locked: Bool = false
    var shadow: Bool = false
    var shadowPiece: Piece = Piece.Empty
    
    init(controller: TetrisController, at row: Int, _ col: Int) {
        self.id = row * 10 + col + 10
        self.controller = controller
    }
    
    func color() -> (Color?, AnyGradient?) {
        return (piece == .Empty && shadow) ? (shadowPiece.colorForPiece(), nil) : (nil, piece.colorForPiece().gradient)
    }
    
    func border() -> Color {
        return shadow ? shadowPiece.colorForPiece() : .gray
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: TetrisAbstractCell) {
        switch value.piece {
        case .I:
            appendInterpolation(value.locked ? "I" : "i")
        case .O:
            appendInterpolation(value.locked ? "O" : "o")
        case .L:
            appendInterpolation(value.locked ? "L" : "l")
        case .J:
            appendInterpolation(value.locked ? "J" : "j")
        case .Z:
            appendInterpolation(value.locked ? "Z" : "z")
        case .S:
            appendInterpolation(value.locked ? "S" : "s")
        case .T:
            appendInterpolation(value.locked ? "T" : "t")
        case .Empty:
            appendInterpolation(".")
        }
    }
}

class TetrisBag {
    var bag1: [Piece] = [.I, .O, .L, .J, .Z, .S, .T]
    var bag2: [Piece] = [.I, .O, .L, .J, .Z, .S, .T]
    var idx = 0
    
    init() {
        bag1.shuffle()
        bag2.shuffle()
    }
    
    func next() -> Piece {
        let result = bag1[idx]
        idx += 1
        if idx == bag1.count {
            bag1 = bag2
            bag2.shuffle()
            idx = 0
        }
        return result
    }
    
    func peek(n: Int) -> Piece {
        if idx + n >= bag1.count {
            return bag2[idx + n - bag1.count]
        }
        return bag1[idx + n]
    }
}

class TetrisController : ObservableObject {
    static let ROTATIONS: Dictionary<Piece, [[[Int]]]> = [
        Piece.I: [
            [
                [0, 0, 0, 0],
                [1, 1, 1, 1],
                [0, 0, 0, 0],
                [0, 0, 0, 0]
            ],
            [
                [0, 0, 1, 0],
                [0, 0, 1, 0],
                [0, 0, 1, 0],
                [0, 0, 1, 0]
            ],
            [
                [0, 0, 0, 0],
                [0, 0, 0, 0],
                [1, 1, 1, 1],
                [0, 0, 0, 0]
            ],
            [
                [0, 1, 0, 0],
                [0, 1, 0, 0],
                [0, 1, 0, 0],
                [0, 1, 0, 0]
            ]
        ],
        Piece.J: [
            [
                [1, 0, 0],
                [1, 1, 1],
                [0, 0, 0],
            ],
            [
                [0, 1, 1],
                [0, 1, 0],
                [0, 1, 0],
            ],
            [
                [0, 0, 0],
                [1, 1, 1],
                [0, 0, 1],
            ],
            [
                [0, 1, 0],
                [0, 1, 0],
                [1, 1, 0],
            ],
        ],
        Piece.L: [
            [
                [0, 0, 1],
                [1, 1, 1],
                [0, 0, 0],
            ],
            [
                [0, 1, 0],
                [0, 1, 0],
                [0, 1, 1],
            ],
            [
                [0, 0, 0],
                [1, 1, 1],
                [1, 0, 0],
            ],
            [
                [1, 1, 0],
                [0, 1, 0],
                [0, 1, 0],
            ],
        ],
        Piece.O: [
            [
                [0, 1, 1, 0],
                [0, 1, 1, 0],
                [0, 0, 0, 0]
            ],
            [
                [0, 1, 1, 0],
                [0, 1, 1, 0],
                [0, 0, 0, 0]
            ],
            [
                [0, 1, 1, 0],
                [0, 1, 1, 0],
                [0, 0, 0, 0]
            ],
            [
                [0, 1, 1, 0],
                [0, 1, 1, 0],
                [0, 0, 0, 0]
            ]
        ],
        Piece.S: [
            [
                [0, 1, 1],
                [1, 1, 0],
                [0, 0, 0]
            ],
            [
                [0, 1, 0],
                [0, 1, 1],
                [0, 0, 1]
            ],
            [
                [0, 0, 0],
                [0, 1, 1],
                [1, 1, 0]
            ],
            [
                [1, 0, 0],
                [1, 1, 0],
                [0, 1, 0]
            ]
        ],
        Piece.T: [
            [
                [0, 1, 0],
                [1, 1, 1],
                [0, 0, 0]
            ],
            [
                [0, 1, 0],
                [0, 1, 1],
                [0, 1, 0]
            ],
            [
                [0, 0, 0],
                [1, 1, 1],
                [0, 1, 0]
            ],
            [
                [0, 1, 0],
                [1, 1, 0],
                [0, 1, 0]
            ]
        ],
        Piece.Z: [
            [
                [1, 1, 0],
                [0, 1, 1],
                [0, 0, 0]
            ],
            [
                [0, 0, 1],
                [0, 1, 1],
                [0, 1, 0]
            ],
            [
                [0, 0, 0],
                [1, 1, 0],
                [0, 1, 1]
            ],
            [
                [0, 1, 0],
                [1, 1, 0],
                [1, 0, 0]
            ],
        ]
    ]
    
    @Published var board: [[TetrisAbstractCell]] = []
    
    init() {
        board = (0..<20).map { x in
            return (0..<10).map { y in
                return TetrisAbstractCell(controller: self, at: x, y)
            }
        }
        tick()
    }
    
    var clockPeriod = 1.0
    var gameStart = Date().timeIntervalSinceReferenceDate
    var bag: TetrisBag = TetrisBag()
    var heldPiece: Piece? = nil
    var usedHold = false;
    var fallingPiece: Piece? = nil
    var fallingTopLeft: (Int, Int)? = nil
    var fallingRotationState: Int = 0
    var LOCKS = 3
    var lockCounter = 3
    
    var linesCleared: Int = 0
    @Published var score: Int = 0
    @Published var pps: Double = 0.0
    var piecesPlaced = 0
    @Published var scoringMessage = " "
    
    var lastIsRotation = false
    var TSTOrFinKickUsed = false
    var combo = 0
    var b2b = 0
    
    var gameEnded = false
    
    func spawnPiece(piece: Piece) {
        if fallingPiece == nil {
            // check for blocked
            fallingPiece = piece
            fallingTopLeft = (0, 3)
            fallingRotationState = 0
            if !testPosition(dr: 0, dc: 0, rot: 0) {
                gameEnded = true
                gameOver()
                return
            }
            movePieceToPosition()
        }
    }
    
    func gameOver() {
        board = (0..<20).map { x in
            return (0..<10).map { y in
                return TetrisAbstractCell(controller: self, at: x, y)
            }
        }
        //  . . . x x . . .
        //  .         .
        //  .   .     .   .
        //  .   .     .   .
        //  . . .     . . .
        board[8][1].piece = .Z
        board[8][2].piece = .L
        board[9][1].piece = .L
        board[8][3].piece = .O
        board[10][1].piece = .O
        board[11][1].piece = .S
        board[12][1].piece = .I
        board[10][3].piece = .I
        board[12][2].piece = .J
        board[11][3].piece = .J
        board[8][6].piece = .J
        board[12][3].piece = .T
        board[8][7].piece = .T
        board[9][6].piece = .T
        board[8][8].piece = .Z
        board[10][6].piece = .Z
        board[11][6].piece = .L
        board[12][6].piece = .O
        board[10][8].piece = .O
        board[12][7].piece = .S
        board[11][8].piece = .S
        board[12][8].piece = .I
        
        fallingPiece = nil
        fallingTopLeft = nil
    }
    
    // MARK: Scoring
    
    // returns isTspin, isMini
    func checkTSpin() -> (Bool, Bool) {
        if !lastIsRotation {
            return (false, false);
        }
        if TSTOrFinKickUsed {
            TSTOrFinKickUsed = false;
            return (true, false);
        }
        if let piece = fallingPiece {
            if piece != .T {
                return (false, false)
            }
            // 3 corner check
            let (r, c) = fallingTopLeft!
            var count = 0
            let isOccupied: (Int, Int) -> Bool = {row, col in
                if row >= 20 || col < 0 || col >= 10 {
                    return true
                }
                return self.board[row][col].locked
            }
            let corners = [
                isOccupied(r, c),
                isOccupied(r, c + 2),
                isOccupied(r + 2, c + 2),
                isOccupied(r + 2, c)
            ]
            for b in corners {
                if b {
                    count += 1
                }
            }
            if count >= 3 {
                // T spin vs T spin mini
                if corners[fallingRotationState] && corners[(fallingRotationState + 1) % 4] {
                    // T spin
                    return (true, false)
                } else {
                    // T spin mini
                    return (true, true)
                }
            }
        }
        return (false, false)
    }
    
    func lockPiece() {
        let rot = TetrisController.ROTATIONS[fallingPiece!]![fallingRotationState]
        let rows = rot.count
        let cols = rot[0].count
        for r in fallingTopLeft!.0..<fallingTopLeft!.0+rows {
            if r < 0 || r >= 20 {
                continue
            }
            for c in fallingTopLeft!.1..<fallingTopLeft!.1+cols {
                if c < 0 || c >= 10 {
                    continue
                }
                if board[r][c].piece != .Empty && !board[r][c].locked {
                    board[r][c].locked = true
                }
            }
        }
        
        // Check for line clears
        var newBoard: [[TetrisAbstractCell]] = (0..<20).map { x in
            return (0..<10).map { y in
                return TetrisAbstractCell(controller: self, at: x, y)
            }
        }
        var clears = 0
        var newR = 19
        
        for r in (0...19).reversed() {
            if !board[r].allSatisfy({$0.piece != .Empty}) {
                for c in 0..<10 {
                    newBoard[newR][c].piece = board[r][c].piece
                    newBoard[newR][c].locked = board[r][c].piece != .Empty
                }
                newR -= 1
            } else {
                clears += 1
            }
        }
        
        if clears == 0 {
            combo = 0
            scoringMessage = " "
        } else {
            scoringMessage = ""
            var worth = 0
            
            let (tspin, mini) = checkTSpin()
            if clears == 1 {
                worth = 1
                if mini {
                    scoringMessage += "T-Spin Mini Single"
                } else if tspin {
                    scoringMessage += "T-Spin Single"
                } else {
                    scoringMessage += "Single"
                }
            }
            else if clears == 2 {
                worth = 3
                if mini {
                    scoringMessage += "T-Spin Mini Double"
                } else if tspin {
                    scoringMessage += "T-Spin Double"
                } else {
                    scoringMessage += "Double"
                }
            }
            else if clears == 3 {
                worth = 6
                // TSMT not possible
                if tspin {
                    scoringMessage += "T-Spin Triple"
                } else {
                    scoringMessage += "Triple"
                }
            }
            else if clears == 4 {
                worth = 10
                // tetris
                scoringMessage += "TETRIS"
            }
            
            if mini {
                worth *= 2
            } else if tspin {
                worth *= 4
            }
            
            if newBoard.allSatisfy({$0.allSatisfy({$0.piece == .Empty})}) {
                // PC
                worth += 20
                scoringMessage += " PERFECT CLEAR"
            }
            
            // combo
            if combo > 0 {
                scoringMessage += " \(combo) combo"
                worth += (combo + 1)
            }
            combo += 1
            
            // b2b
            if clears == 4 || mini || tspin {
                if b2b > 0 {
                    scoringMessage += " \(b2b) B2B"
                    worth *= (b2b + 1)
                }
                b2b += 1
            } else {
                b2b = 0
            }
            
            score += worth
            linesCleared += clears
            clockPeriod = pow(0.95, Double(linesCleared / 5))
            LOCKS = Int(ceil(2 / clockPeriod))
        }
        
        piecesPlaced += 1
        pps = (Double(piecesPlaced)) / (Date().timeIntervalSinceReferenceDate - gameStart)
        board = newBoard
        usedHold = false
        fallingPiece = nil
        fallingTopLeft = nil
        fallingRotationState = 0
    }
    
    func movePieceToPosition() {
        for r in 0..<20 {
            for c in 0..<10 {
                if board[r][c].piece != .Empty && !board[r][c].locked {
                    board[r][c].piece = .Empty
                    board[r][c].locked = false
                }
            }
        }
        let orientation: [[Int]] = TetrisController.ROTATIONS[fallingPiece!]![fallingRotationState]
        for r in 0..<orientation.count {
            for c in 0..<orientation[r].count {
                if (orientation[r][c] == 1) {
                    board[r + fallingTopLeft!.0][c + fallingTopLeft!.1].piece = fallingPiece!
                    board[r + fallingTopLeft!.0][c + fallingTopLeft!.1].locked = false
                }
            }
        }
    }
    
    func testPosition(dr: Int, dc: Int, rot: Int) -> Bool {
        if fallingPiece == nil {
            return false
        }
        let orientation: [[Int]] = TetrisController.ROTATIONS[fallingPiece!]![rot]
        for r in 0..<orientation.count {
            for c in 0..<orientation[r].count {
                if (orientation[r][c] == 1) {
                    let rPr = fallingTopLeft!.0 + r + dr
                    let cPr = fallingTopLeft!.1 + c + dc
                    if rPr < 0 || rPr >= 20 || cPr < 0 || cPr >= 10 {
                        return false
                    }
                    if board[rPr][cPr].locked {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func tick() {
        if gameEnded {
            return
        }
        if fallingPiece == nil {
            spawnPiece(piece: bag.next())
        } else {
            if testPosition(dr: 1, dc: 0, rot: fallingRotationState) {
                TSTOrFinKickUsed = false
                lastIsRotation = false
                fallingTopLeft!.0 += 1
                movePieceToPosition()
            } else {
                if lockCounter == 0 {
                    lockCounter = LOCKS
                    lockPiece()
                } else {
                    lockCounter -= 1
                }
            }
        }
        updateShadow()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + clockPeriod) {
            self.tick()
        }
    }
    
    func left() {
        if fallingPiece == nil {
            return
        }
        if testPosition(dr: 0, dc: -1, rot: fallingRotationState) {
            TSTOrFinKickUsed = false
            lastIsRotation = false
            fallingTopLeft!.1 -= 1
            movePieceToPosition()
        }
        updateShadow()
    }
    
    func right() {
        if fallingPiece == nil {
            return
        }
        if testPosition(dr: 0, dc: 1, rot: fallingRotationState) {
            TSTOrFinKickUsed = false
            lastIsRotation = false
            fallingTopLeft!.1 += 1
            movePieceToPosition()
        }
        updateShadow()
    }
    
    // MARK: SRS
    
    func getSRSKick(for piece: Piece, from rot1: Int, to rot2: Int) -> [(Int, Int)] {
        if piece == .O {
            return [(0, 0)]
        } else if piece == .I {
            if rot1 == 0 && rot2 == 1 {
                return [(0, 0), (-2, 0), (1, 0), (-2, 1), (1, -2)]
            }
            if rot1 == 1 && rot2 == 0 {
                return [(0, 0), (2, 0), (-1, 0), (2, -1), (-1, 2)]
            }
            if rot1 == 1 && rot2 == 2 {
                return [(0, 0), (-1, 0), (2, 0), (-1, -2), (2, 1)]
            }
            if rot1 == 2 && rot2 == 1 {
                return [(0, 0), (1, 0), (-2, 0), (1, 2), (-2, -1)]
            }
            if rot1 == 2 && rot2 == 3 {
                return [(0, 0), (2, 0), (-1, 0), (2, -1), (-1, 2)]
            }
            if rot1 == 3 && rot2 == 2 {
                return [(0, 0), (-2, 0), (1, 0), (-2, 1), (1, -2)]
            }
            if rot1 == 3 && rot2 == 0 {
                return [(0, 0), (1, 0), (-2, 0), (1, 2), (2, -1)]
            }
            if rot1 == 0 && rot2 == 3 {
                return [(0, 0), (-1, 0), (2, 0), (-1, -2), (-2, 1)]
            }
        } else {
            if rot1 == 0 && rot2 == 1 {
                return [(0, 0), (-1, 0), (-1, -1), (0, 2), (-1, 2)]
            }
            if rot1 == 1 && rot2 == 0 {
                return [(0, 0), (1, 0), (1, 1), (0, -2), (1, -2)]
            }
            if rot1 == 1 && rot2 == 2 {
                return [(0, 0), (1, 0), (1, 1), (0, -2), (1, -2)]
            }
            if rot1 == 2 && rot2 == 1 {
                return [(0, 0), (-1, 0), (-1, -1), (0, 2), (-1, 2)]
            }
            if rot1 == 2 && rot2 == 3 {
                return [(0, 0), (1, 0), (1, -1), (0, 2), (1, 2)]
            }
            if rot1 == 3 && rot2 == 2 {
                return [(0, 0), (-1, 0), (-1, 1), (0, -2), (-1, -2)]
            }
            if rot1 == 3 && rot2 == 0 {
                return [(0, 0), (-1, 0), (-1, 1), (0, -2), (-1, -2)]
            }
            if rot1 == 0 && rot2 == 3 {
                return [(0, 0), (1, 0), (1, -1), (0, 2), (1, 2)]
            }
        }
        return [(0, 0)]
    }
    
    func rotRight() {
        if fallingPiece == nil {
            return
        }
        let kicks = getSRSKick(for: fallingPiece!, from: fallingRotationState, to: (fallingRotationState + 1) % 4)
        for p in kicks {
            if testPosition(dr: p.1, dc: p.0, rot: (fallingRotationState + 1) % 4) {
                TSTOrFinKickUsed = false
                // Check for TST / Fin Kick
                if fallingPiece! == .T && fallingRotationState == 0 {
                    if p == kicks.last! {
                        TSTOrFinKickUsed = true
                    }
                } else if fallingPiece! == .T && fallingRotationState == 2 {
                    if p == kicks.last! {
                        TSTOrFinKickUsed = true
                    }
                }
                lastIsRotation = true
                fallingTopLeft!.0 += p.1
                fallingTopLeft!.1 += p.0
                fallingRotationState += 1
                fallingRotationState %= 4
                movePieceToPosition()
                break
            }
        }
        updateShadow()
    }
    
    func rotLeft() {
        if fallingPiece == nil {
            return
        }
        let kicks = getSRSKick(for: fallingPiece!, from: fallingRotationState, to: (fallingRotationState + 3) % 4)
        for p in kicks {
            if testPosition(dr: p.1, dc: p.0, rot: (fallingRotationState + 3) % 4) {
                TSTOrFinKickUsed = false
                // Check for TST / Fin Kick
                if fallingPiece! == .T && fallingRotationState == 0 {
                    if p == kicks.last! {
                        TSTOrFinKickUsed = true
                    }
                } else if fallingPiece! == .T && fallingRotationState == 2 {
                    if p == kicks.last! {
                        TSTOrFinKickUsed = true
                    }
                }
                lastIsRotation = true
                fallingTopLeft!.0 += p.1
                fallingTopLeft!.1 += p.0
                fallingRotationState += 3
                fallingRotationState %= 4
                movePieceToPosition()
                break
            }
        }
        updateShadow()
    }
    
    func softDrop() {
        if fallingPiece == nil {
            return
        }
        if testPosition(dr: 1, dc: 0, rot: fallingRotationState) {
            TSTOrFinKickUsed = false
            lastIsRotation = false
            fallingTopLeft!.0 += 1
            movePieceToPosition()
        }
        updateShadow()
    }
    
    func hardDrop() {
        if fallingPiece == nil {
            return
        }
        while testPosition(dr: 1, dc: 0, rot: fallingRotationState) {
            TSTOrFinKickUsed = false
            lastIsRotation = false
            fallingTopLeft!.0 += 1
            movePieceToPosition()
        }
        lockPiece()
        spawnPiece(piece: bag.next())
        updateShadow()
    }
    
    // MARK: Holding
    
    func removeFallingPiece() {
        let rot = TetrisController.ROTATIONS[fallingPiece!]![fallingRotationState]
        let rows = rot.count
        let cols = rot[0].count
        for r in fallingTopLeft!.0..<fallingTopLeft!.0+rows {
            if r < 0 || r >= 20 {
                continue
            }
            for c in fallingTopLeft!.1..<fallingTopLeft!.1+cols {
                if c < 0 || c >= 10 {
                    continue
                }
                if board[r][c].piece != .Empty && !board[r][c].locked {
                    board[r][c].piece = .Empty
                    board[r][c].locked = false
                }
            }
        }
        updateShadow()
    }
    
    func hold() {
        if fallingPiece == nil {
            return
        }
        if usedHold {
            return
        }
        removeFallingPiece()
        if let hold = heldPiece {
            heldPiece = fallingPiece
            fallingPiece = nil
            spawnPiece(piece: hold)
        } else {
            heldPiece = fallingPiece
            fallingPiece = nil
            spawnPiece(piece: bag.next())
        }
        TSTOrFinKickUsed = false
        lastIsRotation = false
        usedHold = true
        updateShadow()
    }
    
    // MARK: Shadow piece
    
    func updateShadow() {
        for r in 0..<20 {
            for c in 0..<10 {
                if board[r][c].shadow {
                    board[r][c].shadow = false
                    board[r][c].shadowPiece = .Empty
                }
            }
        }
        if fallingPiece != nil {
            var dr = 0
            while testPosition(dr: dr + 1, dc: 0, rot: fallingRotationState) {
                dr += 1
            }
            let orientation: [[Int]] = TetrisController.ROTATIONS[fallingPiece!]![fallingRotationState]
            for r in 0..<orientation.count {
                for c in 0..<orientation[r].count {
                    if (orientation[r][c] == 1) {
                        let rPr = fallingTopLeft!.0 + r + dr
                        let cPr = fallingTopLeft!.1 + c
                        board[rPr][cPr].shadow = true
                        board[rPr][cPr].shadowPiece = fallingPiece!
                    }
                }
            }
        }
    }
    
}

struct TetrisCell: View {
    var size: CGFloat
    var cell: TetrisAbstractCell
    var body: some View {
        let (color, gradient) = cell.color()
        if color != nil {
            ZStack {
                Rectangle()
                    .fill(Piece.Empty.colorForPiece())
                    .opacity(1.0)
                    .border(cell.border())
                    .frame(width: size, height: size)
                Rectangle()
                    .fill(color!)
                    .opacity(cell.shadow ? 0.5 : 1.0)
                    .border(cell.border())
                    .frame(width: size, height: size)
            }
        } else {
            Rectangle()
                .fill(gradient!)
                .border(cell.border())
                .frame(width: size, height: size)
        }
    }
}

struct TetrisPiecePreview: View {
    var size: CGFloat
    var piece: Piece
    var body: some View {
        switch piece {
        case .I:
            HStack(spacing: 0) {
                ForEach(0..<4) { _ in
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                }
            }
        case .O:
            VStack(spacing: 0) {
                ForEach(0..<2) { _ in
                    HStack(spacing: 0) {
                        ForEach(0..<2) { _ in
                            Rectangle()
                                .fill(piece.colorForPiece())
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        case .L:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                }
                HStack(spacing: 0) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(piece.colorForPiece())
                            .frame(width: size, height: size)
                    }
                }
            }
        case .J:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                }
                HStack(spacing: 0) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(piece.colorForPiece())
                            .frame(width: size, height: size)
                    }
                }
            }
        case .Z:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                }
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                }
            }
        case .S:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                }
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                }
            }
        case .T:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(piece.colorForPiece())
                        .frame(width: size, height: size)
                    Rectangle()
                        .fill(.clear)
                        .frame(width: size, height: size)
                }
                HStack(spacing: 0) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(piece.colorForPiece())
                            .frame(width: size, height: size)
                    }
                }
            }
        case .Empty:
            Text("help")
        }
    }
}

struct TetrisView: View {
    @StateObject private var controller: TetrisController = TetrisController()
    var body: some View {
        GeometryReader { screen in
            let size = min((screen.size.width - 40) / 25, (screen.size.height - 40) / 5)
            VStack {
                if !controller.gameEnded {
                    Text(controller.scoringMessage)
                    HStack(spacing: 10) {
                        TetrisPiecePreview(size: size, piece: controller.bag.peek(n: 0))
                        TetrisPiecePreview(size: size, piece: controller.bag.peek(n: 1))
                        TetrisPiecePreview(size: size, piece: controller.bag.peek(n: 2))
                        TetrisPiecePreview(size: size, piece: controller.bag.peek(n: 3))
                        TetrisPiecePreview(size: size, piece: controller.bag.peek(n: 4))
                    }
                }
                GeometryReader { geometry in
                    let size = min((geometry.size.width - 40) / 10, (geometry.size.height - 40) / 20)
                    VStack(spacing: 0) {
                        ForEach(0..<20) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<10) { col in
                                    TetrisCell(size: size, cell: controller.board[row][col])
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: (geometry.size.height - size * 20) / 2, leading: (geometry.size.width - size * 10) / 2, bottom: (geometry.size.height - size * 20) / 2, trailing: (geometry.size.width - size * 10) / 2))
                }
                HStack {
                    VStack {
                        Text("score: \(controller.score)")
                        Text(String(format: "pps: %.2f", controller.pps))
                        if !controller.gameEnded {
                            Text("hold: (swipe up)")
                            if let hold = controller.heldPiece {
                                TetrisPiecePreview(size: size, piece: hold)
                            } else {
                                Text("no hold")
                            }
                        }
                    }.frame(height: 80)
                }
            }
            .onTapGesture { loc in
                if controller.gameEnded {
                    return
                }
                if (loc.y > 3 * screen.size.height / 4) {
                    // bottom
                    controller.softDrop()
                }
                else if (loc.x < screen.size.width / 3) {
                    // left
                    controller.left()
                } else if (loc.x > 2 * screen.size.width / 3) {
                    // right
                    controller.right()
                }
            }
            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                .onEnded { g in
                    if controller.gameEnded {
                        return
                    }
                    let horiz = g.translation.width
                    let vert = g.translation.height
                    if abs(horiz) >= abs(vert) * 2 {
                        if horiz > 0 {
                            // right
                            controller.rotRight()
                        } else {
                            // left
                            controller.rotLeft()
                        }
                    } else if abs(vert) >= abs(horiz) * 2 {
                        if vert > 0 {
                            // down swipe
                            controller.hardDrop()
                        } else {
                            // up swipe
                            controller.hold()
                        }
                    }
                }
            )
        }
    }
}

struct TetrisView_Previews: PreviewProvider {
    static var previews: some View {
        TetrisView()
    }
}
