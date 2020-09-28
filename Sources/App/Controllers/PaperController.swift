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

struct PaperResponse: Content {
    let paper: Paper
    let authors: [LightAuthor]
}

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
        decoder.dateDecodingStrategy = .secondsSince1970
        let paper = try req.content.decode(Paper.self,
                                           using: decoder)
        return paper.save(on: req.db).map { paper }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Paper]> {
        return Paper.query(on: req.db).all()
    }
    
    func getPaper(req: Request) throws -> EventLoopFuture<PaperResponse> {
        guard let paperId = req.parameters.get("paperId", as: UUID.self) else { throw Abort(.badRequest) }
        let paper = Paper.query(on: req.db).filter(\.$id == paperId).with(\.$room).first().unwrap(or: Abort(.notFound))
        let authors = Author.query(on: req.db).join(AuthorPaper.self, on: \Author.$id == \AuthorPaper.$author.$id)
            .filter(AuthorPaper.self, \AuthorPaper.$paper.$id == paperId).all()
            .flatMapThrowing { authors in
                authors.map { author in
                    LightAuthor(id: author.id ?? UUID(), name: author.name, imagePath: author.imagePath)
                }
            }
        return paper.and(authors).map { (paper, authors) -> (PaperResponse) in
            PaperResponse(paper: paper, authors: authors)
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
