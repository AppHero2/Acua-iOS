//
//  URLEncodedString.swift
//  Acua
//
//  Created by AHero on 9/13/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import Foundation


struct URLEncodedString {
    
    private (set) var encodedString: String
    
    init(_ string: String) {
        self.encodedString = URLEncodedString.URLEncode(string: string)
    }
    
    // Based on Alamofire Parameter Encoding: https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift
    static func URLEncode(string: String) -> String {
        let value = string.replacingOccurrences(of: " ", with: "+")
        let generalDelimiters = ":#[]@ " // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimiters = "!$&'()*,;="
        
        let allowedCharacters = generalDelimiters + subDelimiters
        let customAllowedSet =  NSCharacterSet(charactersIn:allowedCharacters).inverted
        let escapedString = value.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
//        let escapedString = string.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        return escapedString
    }
    
}

extension URLEncodedString: StringLiteralConvertible {
    var description: String {
        get {
            return encodedString
        }
    }
}

extension URLEncodedString: CustomStringConvertible {
    
    init(stringLiteral value: String) {
        self.init(value)
    }
    
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    
    init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    
}
