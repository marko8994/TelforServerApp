import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    app.post("authors") { (request) -> EventLoopFuture<Author> in
        let author = try request.content.decode(Author.self)
        return author.create(on: request.db).map { author }
    }
    
    app.get("authors", "getAll") { (request) in
        Author.query(on: request.db).all()
    }
    
//    app.get { req in
//        return "It works!"
//    }
//
//    app.get("hello") { req -> String in
//        return "Hello, world!"
//    }

//    try app.register(collection: <#T##RouteCollection#>)
}
