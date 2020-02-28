//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import PerfectHTTPServer
import PerfectWebSockets
import PerfectLib

let server = HTTPServer()
server.serverPort = 8181
server.documentRoot = "webroot"

func makeRoutes() -> Routes {
    var routes = Routes()
    
//    routes.add(method: .get, uri: "/game") { (request, response) in
//
//        WebSocketHandler { (request, protocols) -> WebSocketSessionHandler? in
//            return GameHandler()
//        }.handleRequest(request: request, response: response)
//
//
//    }
    
    routes.add(method: .get, uri: "/game", handler: {
        request, response in
        
        // To add a WebSocket service, set the handler to WebSocketHandler.
        // Provide your closure which will return your service handler.
        WebSocketHandler(handlerProducer: {
            (request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in
            
            // Check to make sure the client is requesting our "echo" service.
            guard protocols.contains("echo") else {
                return nil
            }
            
            // Return our service handler.
            return GameHandler()
        }).handleRequest(request: request, response: response)
    })
    return routes
}

server.addRoutes(makeRoutes())


////
var routes = Routes()
routes.add(method: .get, uri: "/") { (request, response) in
    response.setBody(string: "Hello, Perfect!")
    .completed()
}
func returnJSONMessage(message: String, response: HTTPResponse) {
    do {
        try response.setBody(json: ["status": message])
            .setHeader(.contentType, value: "application/json")
            .completed()
    } catch {
        response.setBody(string: "Error handling request: \(error)")
            .completed(status: .internalServerError)
    }
}

routes.add(method: .get, uri: "/hello") { (request, response) in
    returnJSONMessage(message: "Hello, JSON!", response: response)
}
server.addRoutes(routes)

///



do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
 
