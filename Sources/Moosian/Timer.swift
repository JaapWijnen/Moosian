//
//  Timer.swift
//  Moosian
//
//  Created by Jaap Wijnen on 24/06/2017.
//

import Foundation

class Timer: CustomStringConvertible {
    
    var currentTiming: (name: String, start: Double)?
    var timings: [(name: String, duration: Double)] = []
    
    var description: String {
        var str = "Timings: \n"
        var total: Double = 0
        for timing in timings {
            str.append("\(timing.name): \(round(100*timing.duration)/100)s.\n")
            total += timing.duration
        }
        str.append("total: \(round(100*total)/100)s.")
        return str
    }
    
    func startTiming(_ name: String) {
        let time = DispatchTime.now().uptimeNanoseconds
        
        guard let lastTime = currentTiming else {
            currentTiming = (name, Double(time) / 1000000000)
            return
        }
        
        let duration = Double(time - UInt64(lastTime.start * 1000000000)) / 1000000000
        timings.append((lastTime.name, duration))
        
        currentTiming = (name, Double(time) / 1000000000)
    }
    
    func endTiming() {
        let time = DispatchTime.now().uptimeNanoseconds
        
        guard let lastTime = currentTiming else {
            fatalError("No timing started before ending")
        }
        
        let duration = Double(time - UInt64(lastTime.start * 1000000000)) / 1000000000
        timings.append((lastTime.name, duration))
        
        currentTiming = nil
    }
}
