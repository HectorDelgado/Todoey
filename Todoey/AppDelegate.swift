//
//  AppDelegate.swift
//  Todoey
//
//  Created by Hector Delgado on 6/6/19.
//  Copyright © 2019 Hector Delgado. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        migrateDB()
        
        do {
            _ = try Realm()
        } catch {
            print("Error initializing new realm. \(error)")
        }
        
        return true
    }
    
    // Used to convert data model from previous schema to new schema
    func migrateDB() {
        let config = Realm.Configuration(
            // Set the name schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0)
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a RealmDB with
            // a schema version lower than the one set above
            migrationBlock: {migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    migration.enumerateObjects(ofType: Item.className()) { (oldObject, newObject) in
                        newObject?["dateCreated"] = Date()
                    }
                    migration.enumerateObjects(ofType: Category.className()) { oldObject, newObject in
                        newObject!["color"] = UIColor.randomFlat
                    }
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
}

