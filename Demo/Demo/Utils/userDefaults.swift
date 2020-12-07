//
//  userDefaults.swift
//  Demo
//
//  Created by Lshiva on 05/12/2020.
//

import UIKit

class userDefaults {
    static let userDefaults = UserDefaults.standard
    
    class public func hasValueForKey(key: String) -> Bool {
        let value = self.objectForKey(key: key)
        return value != nil
    }
    
    class public func objectForKey(key: String) -> AnyObject? {
        return self.userDefaults.object(forKey: key) as AnyObject?
    }
    
    class public func saveObject(value: Any!, forKey key: String) {
        self.userDefaults.set(value, forKey: key)
        self.userDefaults.synchronize()
    }
    
    class public func removeObjectForKey(key: String) {
        self.userDefaults.removeObject(forKey: key)
        self.userDefaults.synchronize()
    }
    
    class public func removeAllObjects() {
        let appDomain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: appDomain)
    }
    
    class public func saveBool(value: Bool, forKey key: String) {
        self.userDefaults.set(value, forKey: key)
        self.userDefaults.synchronize()
    }
    
    class public func boolForKey(key: String) -> Bool? {
        return self.userDefaults.bool(forKey: key) as Bool?
    }
}
