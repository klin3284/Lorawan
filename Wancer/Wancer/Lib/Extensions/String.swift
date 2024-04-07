//
//  StringUtil.swift
//  Wancer
//
//  Created by Kenny Lin on 3/22/24.
//

extension String {
    subscript(range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    func splitIntoNCharacterStrings(_ strideLength: Int) -> [String] {
        return stride(from: 0, to: self.count, by: strideLength).map { index in
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(startIndex, offsetBy: strideLength, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[startIndex..<endIndex])
        }
    }
    
    func toPhoneNumberFormat() -> String {
        let pattern = #"(\d{3})(\d{3})(\d{4})"#
        let replacement = "($1) $2-$3"
        return self.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression, range: nil)
    }
}

public func signalStringBuilder(prefix: String, fields: [(field: String, maxLength: Int)]) -> String {
    var message = prefix
    var rangeMinBound = 0
    
    for (field, maxLength) in fields {
        message += field.padding(toLength: maxLength, withPad: " ", startingAt: 0)
        rangeMinBound += maxLength
    }
    
    message = message.padding(toLength: 255, withPad: " ", startingAt: 0)
    
    return message
}

