//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 07/10/2020.
//

import Foundation
import Vapor
import Fluent

final class SessionController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userSessionRoutes = routes.grouped("api", "u", "session")
        let adminSessionRoutes = routes.grouped("api", "a", "session")
        userSessionRoutes.get("getAll", use: index)
        userSessionRoutes.get(":sessionId", use: getSession)
        adminSessionRoutes.post("add", use: create)
        adminSessionRoutes.post(":sessionId", "addAuthor", ":authorId", use: addChairperson)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Session> {
        let decoder = JSONDecoder()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormater.locale = Locale.current
        dateFormater.timeZone = TimeZone.current
        decoder.dateDecodingStrategy = .formatted(dateFormater)
        let session = try req.content.decode(Session.self, using: decoder)
        return session.save(on: req.db).map { session }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Session]> {
        return Session.query(on: req.db).all()
    }
    
    func getSession(req: Request) throws -> EventLoopFuture<SessionResponse> {
        guard let sessionId = req.parameters.get("sessionId", as: UUID.self) else { throw Abort(.badRequest) }
        return Session.query(on: req.db).filter(\.$id == sessionId)
            .with(\.$papers).with(\.$authors).with(\.$room).first().unwrap(or: Abort(.notFound))
            .map { fullSession in
                let lightPapers = fullSession.papers.map {
                    LightPaper(id: $0.id, title: $0.title, authorNames: $0.authorNames)
                }
                let lightChairpersons = fullSession.authors.map {
                    LightAuthor(id: $0.id, name: $0.name, imagePath: $0.imagePath)
                }
                return SessionResponse(id: fullSession.id,
                                       name: fullSession.name,
                                       date: fullSession.date,
                                       papers: lightPapers,
                                       room: LightRoom(id: fullSession.room.id, name: fullSession.room.name),
                                       chairpersons: lightChairpersons)
        }
    }
    
    func addChairperson(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let session = Session.find(req.parameters.get("sessionId"),
                               on: req.db).unwrap(or: Abort(.notFound))
        let author = Author.find(req.parameters.get("authorId"),
                                 on: req.db).unwrap(or: Abort(.notFound))
        return session.and(author).flatMap { paper, author in
            paper.$authors.attach(author, on: req.db)
        }.transform(to: .ok)
    }
}
