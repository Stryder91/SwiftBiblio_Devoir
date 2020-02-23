import Kitura
import HeliumLogger
import KituraStencil

import Foundation

import SwiftKuery
import SwiftKueryORM
import SwiftKuerySQLite

HeliumLogger.use()

let router = Router()

router.all(middleware: [BodyParser(), StaticFileServer(path: "./Public")])
router.add(templateEngine: StencilTemplateEngine())

// SQL version qui marche pas ...
// let pool = SQLiteConnection.createPool(host: "localhost", port: 5432, options: [databaseName("database")], poolOptions: ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 50))

// ORM connexion à la BDD
let pool = SQLiteConnection.createPool(filename: "datatabase.db", poolOptions: ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 30))
Database.default = Database(pool)
pool.getConnection() { connection, error in
    guard let connection = connection else {
        // Handle error
        print("connection")
        return
    }
    // Use connection
}
struct Topic: Codable {
  var nameTopic: String
  var content: String

}
struct Tag: Codable {
    var nameTag: String
    var refTopic: String
}
struct Url: Codable {
    var nameUrl: String
    var refTopic: String
}
extension Topic: Model { 
    
    // Fonction sensé nous permettre de récupérer un topic avec un "where" SQL, dont le nom vaut == "Python" par exemple, mais pas réussi.
    // Le problème vient de "Table", nous retourne la variable qui est utilisé avant d'être instancié.
     public static func getTopic() -> [Topic]? {
        let wait = DispatchSemaphore(value: 0)
        // First get the table
        var table: Table
        do {
            table = try Topic.getTable()
        } catch {
            // Handle error
        }
        // Define result, query and execute
        var myResult: [Topic]? = nil
        let query = Select(from: table).where("nameTopic == Python")

        Topic.executeQuery(query: query, parameters: nil) { results, error in
            guard let results = results else {
                // Handle error
            }
            myResult = results
            wait.signal()
            return
        }
        wait.wait()
        return myResult
    }
}
extension Tag: Model { }
extension Url: Model { }

router.get("/") { request, response, next in
    
    //On crée nos tables, ne s'écrasent pas.
    do {
        try Topic.createTableSync()
        try Tag.createTableSync()
        try Url.createTableSync()
    } catch let error {
        // Error
    }
                 
    //Détruire une table
    // Tag.deleteAll { error in
    // print("ERREUR DELETING", error)
    // }
    // Tag.delete(id: 1) { error in
    // print("DELETING BY ID", error)
    // }
    
    //Bloc d'instanciation en dur
    // let tag = Tag(nameTag: "ML", refTopic: "Python")
    // tag.save { tag, error in
    //     print("save \(tag), \(error)")
    // }
    // let topic = Topic(nameTopic: "Swift", content: "Swift is a powerful and intuitive programming language for macOS, iOS, watchOS, tvOS and beyond. Writing Swift code is interactive and fun, the syntax is concise yet expressive, and Swift includes modern features developers love. Swift code is safe by design, yet also produces software that runs lightning-fast.")
    // topic.save { topic, error in
    //     print("save, \(error)")
    // }

    //Pour tout prendre et vérifier les manip Query en dur
    // do {
    //     Tag.findAll { (result: [Tag]?, error: RequestError?) in
    //         print("Result find : \(result)")
    //         for element in result! {
    //             print("LOOP", element)
    //         }
    //     }
    // }   

    ///////// Query sur la liste des topics
    do {
        Topic.findAll { (result: [Topic]?, error: RequestError?) in

            print("Result find : \(result)")
            for element in result! {
                print("LOOP", element.nameTopic)
            }
            do {
                try response.render("Home.stencil", 
                    context: ["greeting" : "Bienvenue dans la bibliographie", "list":result ?? [] ])
            } catch {
                print("le render n'a pas marche")
            }
        }
    }   
    next()
}

router.get("/topic/:myTopic") { request, response, next in
    if let topic = request.parameters["myTopic"]{
        
        // On chercher à récuperer des tags en fonction du nom du topic passé en paramètre
        // Tag.findAll() { result, error in
        //     print("Result find : \(result)")
        //     for element in result! {
        //         print("LOOP II", element)
        //     }
        //     do {
        //         try response.render("Sujet.stencil", 
        //             context: ["topic": topic , "list":result ?? "" ])
        //     } catch {
        //         print("le render n'a pas marche")
        //     }
        // }
        
    //Appel de la méthode de l'extension du Topic 
    var myTest = Topic.getTopic() 
    print("MY TEST", myTest)
    try response.render("Sujet.stencil", 
                        context: ["topic": topic ])
    }
    else {
        response.status(.notFound)
    }
    next()
}

// router.get("/create") { request, response, next in
//     try response.render("Create.stencil", context: ["title" : "Creez un sujet"])
//     next()
// }


// router.post("/") { request, response, next in
//     if let body = request.body?.asURLEncoded { 
//      //
//     }
//     else {
//        response.status(.notFound)
//     }
//     next()
// }


Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
