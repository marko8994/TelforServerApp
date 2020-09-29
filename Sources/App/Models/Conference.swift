//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 29/09/2020.
//

import Foundation
import Fluent
import Vapor
import FluentPostgresDriver

final class Conference: Model, Content {
    
    static let schema = "conference"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "image_paths")
    var imagePaths: String
    
    @Field(key: "contact_email")
    var contactEmail: String
    
    @Field(key: "start_date")
    var startDate: Date
    
    @Field(key: "end_date")
    var endDate: Date
    
    @Field(key: "survey_path")
    var surveyPath: String?
    
    @Field(key: "map_path")
    var mapPath: String?
    
    init() { }

    init(name: String, description: String, imagePaths: String, contactEmail: String,
         startDate: Date, endDate: Date, surveyPath: String? = nil, mapPath: String? = nil) {
        self.name = name
        self.description = description
        self.imagePaths = imagePaths
        self.contactEmail = contactEmail
        self.startDate = startDate
        self.endDate = endDate
        self.surveyPath = surveyPath
        self.mapPath = mapPath
    }
}
