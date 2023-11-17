//
//  ConnectionHandler.swift
//
//
//  Created by Mafalda on 11/8/23.
//

import Foundation
import NIO

class ConnectionHandler: ChannelInboundHandler
{
    typealias InboundIn = ByteBuffer
    
    /// Number of messages received in this session for this connection
    var messageCount = 0
    
    /// Called when there is a client connection
    public func channelRegistered(context: ChannelHandlerContext)
    {
        print("A new client connection has been registered from \(context.remoteAddress?.ipAddress ?? "unknown address")")
    }
    
    /// Called when data has been received from the client
    public func channelRead(context: ChannelHandlerContext, data: NIOAny)
    {
        print("ConnectionHandler.channelRead")

        print("Data received from the client. Echoing received message back.")
        
        context.write(data, promise: nil)

        print("ConnectionHandler.channelRead")

        messageCount += 1
    }
    
    public func channelReadComplete(context: ChannelHandlerContext) 
    {
        print("ConnectionHandler.channelReadComplete")
        context.flush()
    }
    
    /// Called when the client disconnects
    public func channelUnregistered(context: ChannelHandlerContext)
    {
        print("Client \(context.remoteAddress?.ipAddress ?? "unknown address") has disconnected. \(messageCount) messages were processed this session.")
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) 
    {
        print("Received a client connection error. Hanging up.")
        print("Error: \(error)")
        
        context.close(promise: nil)
    }
}
