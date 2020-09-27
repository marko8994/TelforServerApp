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
    let authorName: [String]
}

struct LightAuthor: Content {
    let id: UUID
    let name: String
    let imagePath: String
}

struct LightRoom: Content {
    let id: UUID
    let name: String
}

struct HomeData: Content {
    let authors: [Author]
    let papers: [Paper]
    let rooms: [Room]
}

final class MainController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let mainRoutes = routes.grouped("api", "u")
        mainRoutes.get("getAll", use: getAll)
//        mainRoutes.get("moreInfo", use: getMoreInfo)
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<HomeData> {
        let authors = Author.query(on: req.db).all()
        let papers = Paper.query(on: req.db).all()
        let rooms = Room.query(on: req.db).all()
//        let authors = Author.query(on: req.db).field(\.$id).field(\.$name).field(\.$imagePath).all()
//        let papers = Paper.query(on: req.db).field(\.$id).field(\.$title).all()
//        let rooms = Room.query(on: req.db).field(\.$id).field(\.$name).all()
        return authors.and(papers).and(rooms).map { (arg0, rooms) -> (HomeData) in
            let (authors, papers) = arg0
            return HomeData(authors: authors, papers: papers, rooms: rooms)
        }
    }
    
//    func getMoreInfo(req: Request) throws -> EventLoopFuture<[Room]> {
//        return Paper.query(on: req.db).all()
//    }
}
