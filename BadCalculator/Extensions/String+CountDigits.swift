//
//  String+CountDigits.swift
//  BadCalculator
//
//  Created by Jordan Gardner on 8/6/19.
//  Copyright © 2019 jordanthomasg. All rights reserved.
//

import Foundation

extension String {
    
    // Count the number of digits in a string
    func countDigits() -> Int {
        var count: Int = 0
        let zero = UnicodeScalar("0")
        let nine = UnicodeScalar("9")
        for scalar in self.unicodeScalars {
            switch scalar {
            case zero...nine:
                count += 1
            default:
                break
            }
        }
        return count
    }
}
