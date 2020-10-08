//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 07/10/2020.
//

import Foundation
import Vapor
import FluentPostgresDriver

final class SessionAuthor: Model {
    
    static let schema = "sessions_authors"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "session_id")
    var session: Session
    
    @Parent(key: "author_id")
    var author: Author

    init() { }

    init(sessionId: UUID, authorId: UUID) {
        self.$session.id = sessionId
        self.$author.id = authorId
    }
}
