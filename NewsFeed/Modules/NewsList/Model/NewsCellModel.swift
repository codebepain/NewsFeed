//
//  NewsCellModel.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 24.04.2025.
//

import UIKit

struct NewsCellModel: Hashable {
    let id: Int
    let title: String
    let publishedDate: String
    let description: String
    let imageURL: URL?
    let category: String
    
    init(news: News) {
        id = news.id
        title = news.title
        publishedDate = Self.formatDate(news.publishedDate)
        description = news.description
        imageURL = news.imageURL
        category = news.category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NewsCellModel, rhs: NewsCellModel) -> Bool {
        lhs.id == rhs.id
    }
    
    private static func formatDate(_ date: Date) -> String {
        let df = DateFormatter.local
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let newsYear = calendar.component(.year, from: date)
        
        if currentYear == newsYear {
            df.setLocalizedDateFormatFromTemplate("d MMMM")
        } else {
            df.setLocalizedDateFormatFromTemplate("d MMMM yyyy")
        }
        return df.string(from: date)
    }
}
