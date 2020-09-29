//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 29/09/2020.
//

import Foundation
import Vapor

struct HomeData: Content {
    let name: String
    let imagePaths: String
    let authors: [LightAuthor]
    let papers: [LightPaper]
    let rooms: [LightRoom]
}

public struct AuthorResponse: Content {
    let id: UUID?
    let name: String
    let organization: String
    let position: String
    let imagePath: String?
    let biography: String?
    let papers: [LightPaper]?
}

struct AddAuthorToPaperRequest: Content {
    var paperId: String
    var authorId: String
}

struct PaperResponse: Content {
    let id: UUID?
    let title: String
    let type: String
    let presentationDate: Date
    let summary: String?
    let questionsFormPath: String?
    var room: LightRoom
    let authors: [LightAuthor]?
}

public struct RoomResponse: Content {
    let id: UUID?
    let name: String
    let mapPath: String
    let papers: [LightPaper]?
}

struct LightAuthor: Content {
    let id: UUID?
    let name: String
    let imagePath: String?
}

struct LightPaper: Content {
    let id: UUID?
    let title: String
    let authorNames: String?
}

struct LightRoom: Content {
    let id: UUID?
    let name: String
}
