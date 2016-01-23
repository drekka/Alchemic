//
//  AppDelegate.swift
//  SwiftDemo
//
//  Created by Derek Clarkson on 2/11/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

import AlchemicSwift
import UIKit

import StoryTeller

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var dataSource:DataSource?

    var window: UIWindow?

    @objc static func alchemic(cb:ALCBuilder) {

        STStoryTeller().startLogging("LogAll")

        AcInject(cb, variable: "dataSource", type:NSObject.self, source: AcProtocol(DataSource.self))

        AcExecuteWhenStarted { () -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.dataSource!.start()
        }

    }

}

