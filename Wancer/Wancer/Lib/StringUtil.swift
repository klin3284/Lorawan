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
}
