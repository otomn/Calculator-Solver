//
//  Operation.swift
//  CalculateSolver
//
//  Created by Toby on 2018-09-19.
//  Copyright © 2018 Toby. All rights reserved.
//

import Foundation

let maxLen = 7
let error = Int.max

class Operation: CustomStringConvertible {
    
    var description: String {
        return ""
    }
    
    var const: Int
    
    init() {
        const = 0
    }
    
    init(_ const: Int) {
        self.const = const
    }
    
    func operate(_ num: Int) -> Int {
        return num
    }
}


// /1
class Divide: Operation{
    
    override var description: String {
        return "/\(const)"
    }
    
    override func operate(_ num: Int) -> Int {
        if num % const != 0 {
            return error
        }
        return num / const
    }
}

// *1
class Multiply: Operation{
    
    override var description: String {
        return "*\(const)"
    }
    
    override func operate(_ num: Int) -> Int {
        return num * const
    }
}

// +1
class Add: Operation{
    
    override var description: String {
        return "+\(const)"
    }
    
    override func operate(_ num: Int) -> Int {
        return num + const
    }
}

// -1
class Subtract: Operation{
    
    override var description: String {
        return "-\(const)"
    }
    
    override func operate(_ num: Int) -> Int {
        return num - const
    }
    
}

// <<
class Delete: Operation{
    
    override var description: String {
        return "<<"
    }
    
    override func operate(_ num: Int) -> Int {
        var str = String(num)
        str.removeLast()
        return Int(str) ?? 0
    }
    
}

// 1
class Append: Operation{
    
    override var description: String {
        return "\(const)"
    }
    
    override func operate(_ num: Int) -> Int {
        let str = String(num) + String(const)
        return str.count > maxLen ? error : Int(str)!
    }
    
}

// ^1 (x^1 in the game)
class Power: Operation{
    
    override var description: String {
        return "^\(const)"
    }
    
    override func operate(_ num: Int) -> Int {
        let result = pow(Double(num), Double(const))
        return result.magnitude > Double(Int.max) ? error : Int(result)
    }
    
}

// +- (+/- in the game)
class Sign: Operation{
    
    override var description: String {
        return "+-"
    }
    
    override func operate(_ num: Int) -> Int {
        return -num
    }
}

// 1>2 (1>>2 in the game)
class Replace: Operation{
    
    var ori: String
    var target: String
    
    init(ori: String, target: String) {
        self.target = target
        self.ori = ori
        super.init()
    }
    
    override var description: String {
        return "\(ori)>\(target)"
    }
    
    override func operate(_ num: Int) -> Int {
        let key = ori
        var str = "\(num)"
        var result = ""
        while str != "" {
            if findMatch(str: str){
                let start = str[key.count]
                let end = str.endIndex
                str = String(str[start ..< end])
                result.append(target)
            } else {
                result.append(str.removeFirst())
            }
        }
        return Int(result)!
    }
    
    func findMatch(str: String) -> Bool {
        let key = ori
        if str.count < key.count {
            return false
        }
        let start = str.startIndex
        let end = str.index(str.startIndex, offsetBy: key.count)
        return str[start ..< end] == key
    }
}

// r (Reverse in the game)
class Reverse: Operation{
    
    override var description: String {
        return "r"
    }
    
    override func operate(_ num: Int) -> Int {
        return Int(String("\(num.magnitude)".reversed()))! * num.signum()
    }
    
}

// sum
class Sum: Operation{
    
    override var description: String {
        return "sum"
    }
    
    override func operate(_ num: Int) -> Int {
        var sum = 0
        for i in "\(num)" {
            sum += Int("\(i)") ?? 0
        }
        return num.signum() * sum
    }
    
}

// < or > (shift< or shift> in the game)
class Shift: Operation{
    
    var left: Bool
    
    init(shiftLeft: Bool) {
        left = shiftLeft
        super.init()
    }
    
    override var description: String {
        return left ? "<" : ">"
    }
    
    override func operate(_ num: Int) -> Int {
        var str = "\(num.magnitude)"
        if left {
            str = str + "\(str.first!)"
            str.removeFirst()
        } else {
            str = "\(str.last!)" + str
            str.removeLast()
        }
        return num.signum() * (Int(str) ?? 0)
    }
    
}

// m (Mirror in the game)
class Mirror: Operation {
    
    override var description: String {
        return "m"
    }
    
    override func operate(_ num: Int) -> Int {
        let str = "\(num)" + String("\(num.magnitude)".reversed())
        return str.count > maxLen ? error : Int(str)!
    }
    
}

// ++ ([+] in the game)
class Increment: Operation {
    
    override var description: String {
        return "++\(const)"
    }
    
    override func operate(_ num: Int) -> Int {
        return num
    }
    
}

// st (hold store in the game)
class Store: Operation {
    
    override var description: String {
        return const == error ? "st" : "st\(const)"
    }
    
    override func operate(_ num: Int) -> Int {
        let mag = Int(num.magnitude)
        if mag == const {
            return error
        }
        const = mag
        return num
    }
    
}

// ps (tap store in the game)
class Paste: Append {
    
    override var description: String {
        return "ps\(const)"
    }
    
}

// inv (inverse in the game)
class Inverse: Operation {
    
    override var description: String {
        return "inv"
    }
    
    override func operate(_ num: Int) -> Int {
        let str = "\(num)"
        var result = ""
        for c in str {
            result += c == "-" ? "-" : String((10 - Int("\(c)")!) % 10)
        }
        return Int(result)!
    }
    
}

// 1-0 (portals in the game)
class Portal: Operation {
    
    let inPos: Int
    let outPos: Int
    
    init(inPos: Int, outPos: Int) {
        self.inPos = inPos
        self.outPos = outPos
        super.init()
    }
    
    override var description: String {
        return "\(inPos)-\(outPos)"
    }
    
    override func operate(_ num: Int) -> Int {
        let str = String(num.magnitude)
        if str.count <= inPos {
            return num
        }
        return num.signum() * processPortal(str)
    }
    
    func processPortal(_ str: String) -> Int {
        let pos = str.count - inPos - 1
        let first = str[str[0]..<str[pos]]
        let d = str[str[pos]]
        let last = str[str[pos + 1]...str[str.count - 1]]
        return Int(first + last)! + Int("\(d)")! * pow10(mag: outPos)
    }
    
    func pow10(mag: Int) -> Int {
        var result = "1"
        for _ in 0 ..< mag {
            result += "0"
        }
        return Int(result)!
    }
    
}

extension String {
    subscript(index: Int) -> String.Index{
        return self.index(startIndex, offsetBy: index)
    }
}
