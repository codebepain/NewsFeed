//
//  DateFormatter.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 24.04.2025.
//

import Foundation

extension DateFormatter {
    
    static let utc: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df
    }()
    
    static let fractional: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return df
    }()
    
    static let local: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_Ru")
        df.timeZone = .current
        return df
    }()
}
