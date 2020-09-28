import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    try app.register(collection: MainController())
    try app.register(collection: AuthorController())
    try app.register(collection: PaperController())
    try app.register(collection: RoomController())
}
