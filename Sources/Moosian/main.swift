//
//  main.swift
//  Moosian
//
//  Created by Jaap Wijnen on 24/06/2017.
//

import Foundation

let version = "0.0.0"

func printVersion() {
    print("Moosian \(version)")
    exit(0)
}

func printHelp() {
    print("Moosian compiler")
    print("Usage: moosian [options] <inputs>")
    print("Options:")
    print("--version, -v Show version information and exit")
    exit(0)
}

func build(with options: Set<String>) throws {
    
}

do {
    for arg in CommandLine.arguments {
        switch arg {
        case "-v", "--version":
            printVersion()
        case "-h", "--help":
            printHelp()
        default:
            if !arg.hasSuffix(".moose") {
                print("invalid option: \(arg)")
            }
            break
        }
    }
    let options = Set<String>()
    try build(with: options)
} catch {
    print("error: \(error)")
    exit(-1)
}

func getTime() -> Double {
    var timeVal = timeval()
    gettimeofday(&timeVal, nil)
    
    return Double(timeVal.tv_sec) + Double(timeVal.tv_usec) / 10000000
}

func startTiming(_ name: String) {
    
}

func endTiming() {
    
}

