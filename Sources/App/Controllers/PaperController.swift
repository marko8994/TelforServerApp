//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation
import Vapor
import Fluent

struct AddAuthorRequest: Content {
    var paperId: String
    var authorId: String
}

final class PaperController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userPaperRoutes = routes.grouped("api", "u", "paper")
        let adminPaperRoutes = routes.grouped("api", "a", "paper")
        userPaperRoutes.get("getAll", use: index)
        adminPaperRoutes.post("add", use: create)
        adminPaperRoutes.post(":paperId", "addAuthor", ":authorId", use: addAuthor)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Paper> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let paper = try req.content.decode(Paper.self,
                                           using: decoder)
        return paper.save(on: req.db).map { paper }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Paper]> {
        return Paper.query(on: req.db).all()
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
