//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Vapor
import Fluent

final class PaperController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userPaperRoutes = routes.grouped("api", "u", "paper")
        let adminPaperRoutes = routes.grouped("api", "a", "paper")
        userPaperRoutes.get("getAll", use: index)
        userPaperRoutes.get(":paperId", use: getPaper)
        adminPaperRoutes.post("add", use: create)
        adminPaperRoutes.post(":paperId", "addAuthor", ":authorId", use: addAuthor)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Paper> {
        let decoder = JSONDecoder()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormater.locale = Locale.current
        dateFormater.timeZone = TimeZone.current
        decoder.dateDecodingStrategy = .formatted(dateFormater)
        let paper = try req.content.decode(Paper.self,
                                           using: decoder)
        return paper.save(on: req.db).map { paper }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Paper]> {
        return Paper.query(on: req.db).all()
    }
    
    func getPaper(req: Request) throws -> EventLoopFuture<PaperResponse> {
        guard let paperId = req.parameters.get("paperId", as: UUID.self) else { throw Abort(.badRequest) }
        return Paper.query(on: req.db).filter(\.$id == paperId).with(\.$authors).with(\.$room).first()
            .unwrap(or: Abort(.notFound)).map { paperWithAuthors in
                let lightAuthors = paperWithAuthors.authors.map {
                    LightAuthor(id: $0.id, name: $0.name, imagePath: $0.imagePath)
                }
                return PaperResponse(id: paperWithAuthors.id, title: paperWithAuthors.title,
                                     type: paperWithAuthors.type, presentationDate: paperWithAuthors.presentationDate,
                                     summary: paperWithAuthors.summary,
                                     questionsFormPath: paperWithAuthors.questionsFormPath,
                                     room: LightRoom(id: paperWithAuthors.room.id, name: paperWithAuthors.room.name),
                                     authors: lightAuthors)
        }
    }
    
    func addAuthor(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let paper = Paper.find(req.parameters.get("paperId"),
                               on: req.db).unwrap(or: Abort(.notFound))
        let author = Author.find(req.parameters.get("authorId"),
                                 on: req.db).unwrap(or: Abort(.notFound))
        return paper.and(author).flatMap { paper, author in
            paper.$authors.attach(author, on: req.db)
        }.transform(to: .ok)
    }
    
}
