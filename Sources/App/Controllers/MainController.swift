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
    let id: UUID
    let title: String
    let authorNames: [String]?
}

struct LightAuthor: Content {
    let id: UUID
    let name: String
    let imagePath: String?
}

struct LightRoom: Content {
    let id: UUID
    let name: String
}

struct HomeData: Content {
    let imagePath: String
    let authors: [LightAuthor]
    let papers: [LightPaper]
    let rooms: [LightRoom]
}

final class MainController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let mainRoutes = routes.grouped("api", "u")
        mainRoutes.get("home", "getAll", use: getAll)
//        mainRoutes.get("moreInfo", use: getMoreInfo)
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<HomeData> {
        let limit = try req.query.get(Int.self, at: "limit")
        let authors = Author.query(on: req.db).limit(limit).all().flatMapThrowing { authors in
            authors.map { author in
                LightAuthor(id: author.id ?? UUID(), name: author.name, imagePath: author.imagePath)
            }
        }
        let papers = Paper.query(on: req.db).with(\.$authors).limit(limit)
            .all().flatMapThrowing { papers in
        papers.map { paper in
            LightPaper(id: paper.id ?? UUID(), title: paper.title, authorNames: paper.authors.map {$0.name})
            }
        }
        let rooms = Room.query(on: req.db).limit(limit).all().flatMapThrowing { rooms in
        rooms.map { room in
            LightRoom(id: room.id ?? UUID(), name: room.name)
            }
        }
        return authors.and(papers).and(rooms).map { (authorAndPapers, rooms) -> (HomeData) in
            let (authors, papers) = authorAndPapers
            return HomeData(imagePath: "https://i.imgur.com/mc9EqKh.jpeg",
                            authors: authors, papers: papers, rooms: rooms)
        }
    }
}

//    func getMoreInfo(req: Request) throws -> EventLoopFuture<[Room]> {
//        return Paper.query(on: req.db).all()
//    }
