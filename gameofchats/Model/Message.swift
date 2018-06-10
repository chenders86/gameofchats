//
//  Message.swift
//  gameofchats
//
//  Created by Casey Henderson on 6/8/18.
//  Copyright © 2018 Casey Henderson. All rights reserved.
//

import UIKit

class Message: NSObject {
    @objc var fromId: String?
    @objc var text: String?
    @objc var timestamp: NSNumber?
    @objc var toId: String?
}
