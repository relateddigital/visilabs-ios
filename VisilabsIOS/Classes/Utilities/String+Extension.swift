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
            return ParsedPermissionString(preLink: "", link: self, postLink: "")
        }
        
        let prelink = String(self[..<firstOfFirst])
        let link = String(self[endOfFirst..<firstOfEnd])
        let postLink = String(self[endOfEnd...])
        return ParsedPermissionString(preLink: prelink, link: link, postLink: postLink)
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
}

struct ParsedPermissionString {
    var preLink: String
    var link: String
    var postLink: String
}

struct ParsedClick {
    var omZpc: String
    var omZn: String
}
