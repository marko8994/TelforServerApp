//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Fluent
import Vapor
import FluentPostgresDriver

final class AuthorPaper: Model {
    
    static let schema = "author_papers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "author_id")
    var author: Author
    
    @Parent(key: "paper_id")
    var paper: Paper

    init() { }

    init(authorId: UUID, paperId: UUID) {
        self.$author.id = authorId
        self.$paper.id = paperId
    }
}

