import Kitura
import HeliumLogger
import KituraStencil

import Foundation

import SwiftKueryORM
import SwiftKuerySQLite

HeliumLogger.use()

let router = Router()

router.all(middleware: BodyParser())
router.all(middleware: [BodyParser(), StaticFileServer(path: "./Public")])
router.add(templateEngine: StencilTemplateEngine())


let pool = SQLiteConnection.createPool(filename: "datatabase.db", poolOptions: ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 30))
Database.default = Database(pool)
pool.getConnection() { connection, error in
    guard let connection = connection else {
        // Handle error
        return
    }
    // Use connection
}


struct Topic: Codable {
  var name: String
  var tags: String
  var urls: String
}
extension Topic: Model { }

router.get("/") { request, response, next in
    var myTopic: Topic;
    var myResult: [Topic] = [];
    do {
        Topic.findAll { (result: [Topic]?, error: RequestError?) in
            print("Result en vrac: \(result)")
            myResult = result!;
            // for topic in result! {
            //     print("Result",topic)
            // }
        print("MY INNER\(myResult)")
        try response.render("Home.stencil", context: ["greeting" : "Bienvenue dans la bibliographie", "list": "myResult"])
        }
    } catch let error {
        print("Il y a un erreur : \(error)")
    }
    print("MY Out\(myResult)")
    next()
}
router.post("/") { request, response, next in
    if let body = request.body?.asURLEncoded { 
        if let sujet = body["sujet"]{
        let myTag: String = body["tag"] ?? ""
        do {
            let topic = try Topic(name: sujet, tags: myTag, urls:"Urls")
            topic.save { topic, error in
            }
        } catch let error {
            print("Il y a un erreur : \(error)")
        }
        try response.render("Home.stencil", context: ["sujet" : sujet, "tags": myTag])
        }
    next()
    }
    else {
       response.status(.notFound)
    }
    next()
    
}

router.post("/topic") { request, response, next in
    if let body = request.body?.asURLEncoded { 
        if let sujet = body["sujet"]{
        try response.render("Sujet.stencil", context: ["sujet" : sujet])
        }
    next()
    }
    else {
       response.status(.notFound)
    }
    next()
}

router.get("/create") { request, response, next in
    try response.render("Create.stencil", context: ["title" : "Creez un sujet"])
    next()
}


router.get("/eleves/:name") { request, response, next in


    if let name = request.parameters["name"]{

    }
}

Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
