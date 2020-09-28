import Fluent
import Vapor
import FluentPostgresDriver

final class AuthorController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userAuthorRoutes = routes.grouped("api", "u", "author")
        let adminAuthorRoutes = routes.grouped("api", "a", "author")
        userAuthorRoutes.get("getAll", use: index)
        adminAuthorRoutes.post("add", use: create)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Author> {
        let author = try req.content.decode(Author.self)
        return author.save(on: req.db).map { author }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Author]> {
        return Author.query(on: req.db).all()
    }
    
}

//struct AuthorController: RouteCollection {
//    func boot(routes: RoutesBuilder) throws {
//        let todos = routes.grouped("author")
//        todos.get(use: index)
//        todos.post(use: create)
//        todos.group(":todoID") { todo in
//            todo.delete(use: delete)
//        }
//    }
//
//    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        return Todo.find(req.parameters.get("todoID"), on: req.db)
//            .unwrap(or: Abort(.notFound))
//            .flatMap { $0.delete(on: req.db) }
//            .transform(to: .ok)
//    }
//}
