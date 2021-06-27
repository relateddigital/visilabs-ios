//
//  VisilabsFavoriteAttributeActionResponse.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

public class VisilabsFavoriteAttributeActionResponse {
    public var favorites: [VisilabsFavoriteAttribute: [String]]
    public var error: VisilabsError?

    internal init(favorites: [VisilabsFavoriteAttribute: [String]], error: VisilabsError? = nil) {
        self.favorites = favorites
        self.error = error
    }
}
