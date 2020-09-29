//
//  File.swift
//  
//
//  Created by Marko Mladenovic on 27/09/2020.
//

import Foundation

import Vapor
import Fluent

struct LightPaper: Content {
    let id: UUID?
    let title: String
    let authorNames: [String]?
}

struct LightAuthor: Content {
    let id: UUID?
    let name: String
    let imagePath: String?
}

struct LightRoom: Content {
    let id: UUID?
    let name: String
}

struct HomeData: Content {
    let name: String
    let imagePath: String
    let authors: [LightAuthor]
    let papers: [LightPaper]
    let rooms: [LightRoom]
}

final class MainController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let mainRoutes = routes.grouped("api", "u")
        let mainAdminRoutes = routes.grouped("api", "a")
        mainRoutes.get("home", "getAll", use: getAll)
        mainRoutes.get("info", use: getInfo)
        mainAdminRoutes.post("conference", "add", use: createConference)
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<HomeData> {
        let limit = try req.query.get(Int.self, at: "limit")
        let info = Conference.query(on: req.db).field(\.$name).field(\.$imagePaths).first().unwrap(or: Abort(.notFound))
        let authors = Author.query(on: req.db).limit(limit).all().flatMapThrowing { authors in
            authors.map { author in
                LightAuthor(id: author.id ?? UUID(), name: author.name, imagePath: author.imagePath)
            }
        }
        let papers = Paper.query(on: req.db).with(\.$authors).limit(limit).all().flatMapThrowing { papers in
            papers.map { paper in
                LightPaper(id: paper.id ?? UUID(), title: paper.title, authorNames: paper.authors.map {$0.name})
            }
        }
        let rooms = Room.query(on: req.db).limit(limit).all().flatMapThrowing { rooms in
            rooms.map { room in
                LightRoom(id: room.id ?? UUID(), name: room.name)
            }
        }
        return info.and(authors).and(papers).and(rooms).map { (arguments) -> (HomeData) in
            let (((conference, authors), papers), rooms) = arguments
            return HomeData(name: conference.name, imagePath: conference.imagePaths,
                            authors: authors, papers: papers, rooms: rooms)
        }
    }

    func getInfo(req: Request) throws -> EventLoopFuture<Conference> {
        return Conference.query(on: req.db).first().unwrap(or: Abort(.notFound))
    }
    
    func createConference(req: Request) throws -> EventLoopFuture<Conference> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let conference = try req.content.decode(Conference.self, using: decoder)
        return conference.save(on: req.db).map { conference }
    }
}
