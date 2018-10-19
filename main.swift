//
//  main.swift
//  CalculateSolver
//
//  Created by Toby on 2018-09-19.
//  Copyright © 2018 Toby. All rights reserved.
//

import Foundation

var initial = 0
var moves = 0
var goal = 0
var availableOperations: [String] = []
var portal = Portal(inPos: Int.max, outPos: 0)
//var op = Reverse()
//print(op.operate(-15))

func solveStart(){
    
    availableOperations.removeAll()
    portal = Portal(inPos: Int.max, outPos: 0)
    
    print("Initial: ", terminator: "")
    initial = Int(readLine()!) ?? 0
    
    print("moves: ", terminator: "")
    moves = Int(readLine()!) ?? 0
    
    print("goal: ", terminator: "")
    goal = Int(readLine()!) ?? 0
    
    var str = readLine()!
    while (str != ""){
        if let op = getOperation(input: str) {
            availableOperations.append("\(op)")
        }
        str = readLine()!
    }
    
    print("operations are: ", terminator: "")
    for op in availableOperations{
        print(op, terminator: " ")
    }
    print()
    
    print(initial, terminator: " ")
    for op in solver(operations: availableOperations, num: initial, step: 0){
        print(op, terminator: " ")
    }
    print()
}

func getOperation(input: String) -> Operation?{
    var str = input
    switch str {
    case "<<":
        return Delete()
    case "+-":
        return Sign()
    case "r":
        return Reverse()
    case "sum":
        return Sum()
    case "m":
        return Mirror()
    case "inv":
        return Inverse()
    default:
        break;
    }
    switch str.first!{
    case "+":
        str.removeFirst()
        if str.first! == "+" {
            str.removeFirst()
            return Increment(Int(str) ?? 0)
        }
        return Add(Int(str) ?? 0)
    case "-":
        str.removeFirst()
        return Subtract(Int(str) ?? 0)
    case "*":
        str.removeFirst()
        return Multiply(Int(str) ?? 0)
    case "/":
        str.removeFirst()
        return Divide(Int(str) ?? 0)
    case "^":
        str.removeFirst()
        return Power(Int(str) ?? 0)
    case "<":
        return Shift(shiftLeft: true)
    case ">":
        return Shift(shiftLeft: false)
    case "s":
        str.removeFirst()
        if str == "t" {
            return Store(error)
        }
        if str == "" {
            print("invalid operation")
            return nil
        }
        str.removeFirst()
        return Store(Int(str) ?? 0)
    default:
        if let num = Int(str) {
            return Append(num)
        } else if str.contains(">"){
            var splited = str.split(separator: ">")
            if splited.count == 2 {
                return Replace(ori: String(splited[0]),
                               target: String(splited[1]))
            }
        } else if str.contains("-"){
            var splited = str.split(separator: "-")
            if splited.count == 2 {
                portal = Portal(inPos: Int(splited[0]) ?? error,
                                outPos: Int(splited[1]) ?? 0)
                return nil
            }
        }
    }
    print("invalid operation")
    return nil
}

func stringsToOperations(strings: [String]) -> [Operation]{
    var result: [Operation] = []
    for str in strings {
        let op = getOperation(input: str)!
        if op is Store {
            result.append(Paste(op.const))
        }
        result.append(op)
    }
    return result
}

func operationsToStrings(operations: [Operation]) -> [String] {
    var result: [String] = []
    for op in operations {
        if !(op is Paste){
            result.append("\(op)")
        }
    }
    return result
}

func solver(operations: [String], num: Int, step: Int) -> [String]{
    let operations = stringsToOperations(strings: operations)
    if step >= moves {
        return []
    }
    for op in operations {
        //operate
        var currentNum = op.operate(num)
        //error checking
        if currentNum == error {
            continue
        }
        //portal checking
        var portaled = portal.operate(currentNum)
        while portaled != currentNum {
            currentNum = portaled
            portaled = portal.operate(currentNum)
        }
        //increment cheking
        if op is Increment {
            for o in operations {
                if !(o is Increment) {
                    o.const += op.const
                }
            }
        }
        //goal checking
        if currentNum == goal {
            return ["\(op)"]
        }
        //step increment
        let nextStep = op is Store ? step : step + 1
        //recursion calling
        let seq = solver(operations: operationsToStrings(operations: operations), num: currentNum, step: nextStep)
        //increment cheking
        if op is Increment {
            for o in operations {
                if !(o is Increment) {
                    o.const -= op.const
                }
            }
        }
        //recursion result checking
        if !seq.isEmpty {
            return ["\(op)"] + seq
        }
    }
    return []
}

while true{
    solveStart()
}
