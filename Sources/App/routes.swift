import Fluent
import Vapor

func routes(_ app: Application) throws {
    
//    app.post("authors") { (request) -> EventLoopFuture<Author> in
//        let author = try request.content.decode(Author.self)
//        return author.create(on: request.db).map { author }
//    }
//    
//    app.get("authors", "getAll") { (request) in
//        Author.query(on: request.db).all()
//    }

    try app.register(collection: MainController())
    try app.register(collection: AuthorController())
    try app.register(collection: PaperController())
    try app.register(collection: RoomController())
}
