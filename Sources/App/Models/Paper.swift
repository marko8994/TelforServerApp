//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class Paper: Model, Content {
    
    static let schema = "papers"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "presentation_date")
    var presentationDate: Date
    
    @Field(key: "summary")
    var summary: String?
    
    @Field(key: "questions_form_path")
    var questionsFormPath: String?
    
    @Field(key: "author_names")
    var authorNames: String?
    
    @Parent(key: "room_id")
    var room: Room    
    
    @Siblings(through: AuthorPaper.self, from: \.$paper, to: \.$author)
    var authors: [Author]

    init() { }

    init(id: UUID? = nil, title: String, type: String, presentationDate: Date, summary: String? = nil, questionsFormPath: String? = nil, roomId: UUID) {
        self.id = id
        self.title = title
        self.type = type
        self.presentationDate = presentationDate
        self.summary = summary
        self.questionsFormPath = questionsFormPath
        self.$room.id = roomId
    }
}
