//  Post.swift
//  Posts
//
//  Created  on 11/01/20.
//
//

import Foundation

struct Post {
    let createdAt: String
    let title: String
    var isSelected: Bool = false
    
    init(dict: [String: Any]) {
        let title = dict["title"] as? String ?? ""
        let date = dict["created_at"] as? String ?? ""
        let formattedString = formatString(date: date)
        self.title = title
        self.createdAt = formattedString
    }
    
}

fileprivate func formatString(date: String) -> String {
    let dateFormatter = DateFormatter()
    let tempLocale = dateFormatter.locale // save locale temporarily
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let date = dateFormatter.date(from: date)!
    dateFormatter.dateFormat = "MMM d, yyyy" ; //"dd-MM-yyyy HH:mm:ss"
    dateFormatter.locale = tempLocale // reset the locale --> but no need here
    let dateString = dateFormatter.string(from: date)
    return dateString
}
