//
//  AppDelegate.swift
//  VisilabsIOS
//
//  Created by egemen@visilabs.com on 03/30/2020.
//  Copyright (c) 2020 egemen@visilabs.com. All rights reserved.
//

import Eureka


public final class InAppButtonRowOf<T: Equatable> : _ButtonRowOf<T>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellStyle = .subtitle
    }
}
public typealias InAppButtonRow = InAppButtonRowOf<String>
