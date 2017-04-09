//
//  Connection.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/29/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Foundation
import MultipeerConnectivity


struct Peer {
    var letter: String
    var color: NSColor
    
    init(displayName: String) {
        letter = displayName.substringToIndex(displayName.startIndex.successor())
        let colorString = displayName.substringFromIndex(displayName.startIndex.successor())
        switch colorString {
        case "r":
            color = NSColor(colorLiteralRed: 233 / 255, green: 99 / 255, blue: 99 / 255, alpha: 1)
        case "g":
            color = NSColor(colorLiteralRed: 92 / 255, green: 217 / 255, blue: 170 / 255, alpha: 1)
        case "b":
            color = NSColor(colorLiteralRed: 99 / 255, green: 187 / 255, blue: 233 / 255, alpha: 1)
        case "y":
            color = NSColor(colorLiteralRed: 229 / 255, green: 208 / 255, blue: 150 / 255, alpha: 1)
        case "p":
            color = NSColor(colorLiteralRed: 216 / 255, green: 111 / 255, blue: 173 / 255, alpha: 1)
        case "u":
            color = NSColor(colorLiteralRed: 174 / 255, green: 150 / 255, blue: 229 / 255, alpha: 1)

        default:
            color = NSColor.whiteColor()
        }
    }
}

protocol ConnectorDelegate {
    
    func peersDidChange(peers: [Peer])
    func peerDidRespondWith(peer: Peer, response: Response)
}

final class Connector: NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    // MARK: Properties
    
    private let localPeerID = MCPeerID(displayName: "Quizzify")
    private var advertiser: MCNearbyServiceAdvertiser?
    private var sessions: [MCSession] = []
    var lastName: String!
    var onStateChange: stateChange?
    typealias stateChange = ((state: MCSessionState) -> ())?
    var session: MCSession?
    var delegate: ConnectorDelegate?
    var name: String!
    var names: [String] = []
    var displayString: String {
        get {
            var str = ""
            for i in 0..<names.count {
                
                str += names[i]
            }
        
            return str
        }
    }
    
    var connectedPeers: [Peer] {
        var peers: [Peer] = []
        for name in names {
            peers.append(Peer(displayName: name))
        }
        return peers
    }
    
    // MARK: Lifecycle
    
    override init() {
        let dvc = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("m") as! Mediator
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: ["connected":"", "name": dvc.name],
                                               serviceType: "quizzify")
        super.init()
        advertiser?.delegate = self
    }
    
    func start() {
        
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: ["connected":"", "name": name],
                                               serviceType: "quizzify")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()

    }
    
    func stop() {
        advertiser?.stopAdvertisingPeer()
        for session in sessions {
            session.disconnect()
        }
        sessions = []
    }
    
    // MARK: MCNearbyServiceAdvertiserDelegate
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer
        peerID: MCPeerID, withContext context: NSData?,
        invitationHandler: (Bool, MCSession) -> Void) {
        // ERROR IS CAUSED BY NON GLOBAL SESSION
        let name = NSKeyedUnarchiver.unarchiveObjectWithData(context!) as! String
        
        session = MCSession(peer: localPeerID, securityIdentity: nil,
                            encryptionPreference: .Required)
        lastName = name
        guard let session = session else { return }
        session.delegate = self
        invitationHandler(true, session)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Error advertising self!")
    }
    
    // MARK: MCSessionDelegate
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        onStateChange??(state: state)
        if state == .Connected {
            sessions.append(session)
            names.append(lastName)
            advertiser?.stopAdvertisingPeer()
            self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: ["connected":displayString, "name": name ?? "Untitled"],
                                                   serviceType: "quizzify")
            advertiser?.delegate = self
            advertiser?.startAdvertisingPeer()
            delegate?.peersDidChange(connectedPeers)
            
        } else if state == .NotConnected {
            for i in 0..<sessions.count {
                if i < sessions.count {
                if sessions[i] == session {
                    sessions.removeAtIndex(i)
                    names.removeAtIndex(i)
                    break
                }
                }
            }
            advertiser?.stopAdvertisingPeer()
            self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: ["connected":displayString, "name": name ?? "Untitled"],
                                                        serviceType: "quizzify")
            advertiser?.delegate = self
            advertiser?.startAdvertisingPeer()

            delegate?.peersDidChange(connectedPeers)
        }
    }
    
    func sendData(data: NSData) {
        for session in sessions {
            do {
                try session.sendData(data, toPeers: session.connectedPeers, withMode: .Reliable)
            } catch {
                print("Error sending data")
            }
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let response = Response(archive: data)
        print(response)
        let peer: Peer = Peer(displayName:session.connectedPeers[0].displayName)
        delegate?.peerDidRespondWith(peer, response: response)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream,
                 withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
    }
}