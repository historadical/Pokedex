    //
    //  Levenshtein.swift
    //  Pokedex
    //
    //  Created by Nic on 8/27/24.
    //

import Foundation

func levenshtein(_ aStr: String, _ bStr: String) -> Int {
    let a = Array(aStr)
    let b = Array(bStr)
    let empty = [Int](repeating: 0, count: b.count + 1)
    var last = [Int](0...b.count)
    
    for (i, aLett) in a.enumerated() {
        var cur = [i + 1] + empty.dropLast()
        for (j, bLett) in b.enumerated() {
            cur[j + 1] = aLett == bLett ? last[j] : min(last[j], last[j + 1], cur[j]) + 1
        }
        last = cur
    }
    return last.last ?? 0
}
