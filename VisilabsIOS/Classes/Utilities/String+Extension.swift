//
//  String+Extension.swift
//  VisilabsIOS
//
//  Created by Said Alır on 19.11.2020.
//

import Foundation

extension StringProtocol {
    
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
}

extension String {
    
    func parsePermissionText() -> ParsedPermissionString {
        guard let firstOfFirst = self.index(of: "<LINK>"),
              let endOfFirst = self.endIndex(of: "<LINK>"),
              let firstOfEnd = self.index(of: "</LINK>"),
              let endOfEnd = self.endIndex(of: "</LINK>") else {
            return ParsedPermissionString(string: self, location: 0, length: self.count)
        }

        let prelink = String(self[..<firstOfFirst])
        let link = String(self[endOfFirst..<firstOfEnd])
        let postLink = String(self[endOfEnd...])

        let str = prelink + link + postLink
        let location  = prelink.count
        let length = link.count

        return ParsedPermissionString(string: str, location: location, length: length)
    }

    func parseClick() -> ParsedClick {
        var click = ParsedClick(omZpc: "", omZn: "")
        let strArr = self.split(separator: "&")
        var zpcStr: String = String(strArr[0])
        var znStr: String = strArr.count > 1 ? String(strArr[1]) : ""
        if zpcStr.split(separator: "=").count > 1 {
            zpcStr = String(zpcStr.split(separator: "=")[1])
        }
        if znStr.split(separator: "=").count > 1 {
            znStr = String(znStr.split(separator: "=")[1])
        }
        click.omZpc = zpcStr
        click.omZn = znStr
        return click
    }

    func removeEscapingCharacters() -> String {
        return self.replacingOccurrences(of: "\\n", with: "\n")
    }
}

struct ParsedPermissionString {
    var string: String
    var location: Int
    var length: Int
    
}

struct ParsedClick {
    var omZpc: String
    var omZn: String
}
