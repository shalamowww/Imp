//
//  Extensions.swift
//  Imp
//
//  Created by Alexander Shalamov on 8/4/17.
//  Copyright © 2017 Alexander Shalamov. All rights reserved.
//

import Foundation

extension String {
    
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
}
