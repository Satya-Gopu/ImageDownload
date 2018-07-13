//
//  Int+PrimeFinder.swift
//  SpinCar
//
//  Created by Satya on 7/9/18.
//  Copyright © 2018 Satya. All rights reserved.
//

import Foundation

// MARK: - Int+PrimeFinder

extension Int {
    
    // MARK: Checks if the number is a prime
    
    func isPrime() -> Bool {
        if self < 2 {
            return false
        }
        var current = 2
        while current * current <= self {
            if self%current == 0 {
                return false
            }
            current += 1
        }
        return true
    }
}
