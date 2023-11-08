//
//  main.swift
//
//
//  Created by Mafalda on 11/8/23.
//

import ArgumentParser
import NIO

/// Basic Echo Server Implementation using swift-nio
struct EchoServer: ParsableCommand
{
    @Option(name: .shortAndLong, help: "Specifies the <ip_address> of the server.")
    var host: String
    
    @Option(name: .shortAndLong, help: "Specifies the <port> the server should listen on.")
    var port: UInt16
    
    /// This is a basic server implementation using swift-nio as seen in the Swift Documentation for ServerBootstrap
    func run() throws
    {
        let eventGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        defer {
             try! eventGroup.syncShutdownGracefully()
         }

        /// A ServerBootstrap is an easy way to bootstrap a ServerSocketChannel when creating network servers.
        let serverBootstrap = ServerBootstrap(group: eventGroup)
            // Specify backlog and enable SO_REUSEADDR for the server itself
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)

            // Set the handlers that are applied to the accepted child `Channel`s.
            .childChannelInitializer { channel in
                // Ensure we don't read faster then we can write by adding the BackPressureHandler into the pipeline.
                channel.pipeline.addHandler(BackPressureHandler()).flatMap { () in
                    // make sure to instantiate your `ChannelHandlers` inside of
                    // the closure as it will be invoked once per connection.
                    channel.pipeline.addHandler(ConnectionHandler())
                }
            }

            // Enable SO_REUSEADDR for the accepted Channels
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

        let channel = try! serverBootstrap.bind(host: host, port: Int(port)).wait()
        /* the server will now be accepting connections */

        print("Echo server is now listening on \(host):\(port)")

        try! channel.closeFuture.wait() // wait forever as we never close the Channel
    }
    
}

EchoServer.main()

