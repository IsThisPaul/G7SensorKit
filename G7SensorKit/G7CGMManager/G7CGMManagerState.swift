//
//  G7CGMManagerState.swift
//  CGMBLEKit
//
//  Created by Pete Schwamb on 9/26/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import Foundation
import LoopKit


public struct G7CGMManagerState: RawRepresentable, Equatable {
    public typealias RawValue = CGMManager.RawStateValue

    public var sensorID: String?
    public var activatedAt: Date?
    public var latestReading: G7GlucoseMessage?
    public var latestReadingReceivedAt: Date?
    public var latestConnect: Date?

    init() {
    }

    public init(rawValue: RawValue) {
        self.sensorID = rawValue["sensorID"] as? String
        self.activatedAt = rawValue["activatedAt"] as? Date
        if let readingData = rawValue["latestReading"] as? Data {
            latestReading = G7GlucoseMessage(data: readingData)
        }
        self.latestReadingReceivedAt = rawValue["latestReadingReceivedAt"] as? Date
        self.latestConnect = rawValue["latestConnect"] as? Date
    }

    public var rawValue: RawValue {
        var rawValue: RawValue = [:]
        rawValue["sensorID"] = sensorID
        rawValue["activatedAt"] = activatedAt
        rawValue["latestReading"] = latestReading?.data
        rawValue["latestReadingReceivedAt"] = latestReadingReceivedAt
        rawValue["latestConnect"] = latestConnect
        return rawValue
    }
}
