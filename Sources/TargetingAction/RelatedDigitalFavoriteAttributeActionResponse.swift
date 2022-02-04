//
//  VisilabsFavoriteAttributeActionResponse.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

public class RelatedDigitalFavoriteAttributeActionResponse {
    public var favorites: [RelatedDigitalFavoriteAttribute: [String]]
    public var error: VisilabsError?

    internal init(favorites: [RelatedDigitalFavoriteAttribute: [String]], error: VisilabsError? = nil) {
        self.favorites = favorites
        self.error = error
    }
}
