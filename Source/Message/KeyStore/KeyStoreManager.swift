// Copyright 2016-2017 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import CoreData

class KeyStoreManager: NSObject {

    static let shared = KeyStoreManager()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelUrl = Bundle.main.url(forResource: "KeyStore", withExtension: "momd")
        let managedObjectModel = NSManagedObjectModel.init(contentsOf: modelUrl!)
        return managedObjectModel!
    }()
    
    lazy var documentDir : URL = {
        let documentDir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        return documentDir!
    }()

    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let sqliteUrl = self.documentDir.appendingPathComponent("KeyStore.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption: true]
        var failureReason = "There was an error occured when creating or loading key store."
        do{
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteUrl, options: options)
        }catch let error{
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the key store" as Any?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as Any?
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "KeyStoreError", code: 10000, userInfo: dict)
            SDKLogger.shared.error(wrappedError.description)
            abort()
        }
        return persistentStoreCoordinator
    }()
    
    lazy var context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
    
    
    public func saveContext(){
        do{
            try self.context.save()
        }catch let error as NSError{
             SDKLogger.shared.error(error.description)
        }
    }
    
    // MARK: KeyInfo Manage Funtions
    public func saveUserWith(userId: String){
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "KeyInfo", into: context) as! KeyInfo
        newUser.userId = userId
        saveContext()
    }
    
    public func getAllKeyInfo()->[KeyInfo]?{
        let fetchRequest: NSFetchRequest = KeyInfo.fetchRequest()
        do{
            let result = try context.fetch(fetchRequest)
            return result
        }catch let error as NSError{
            SDKLogger.shared.error(error.description)
            return nil
        }
    }
    
    public func getKeyInfoWith(userId: String)->KeyInfo?{
        let fetchRequest: NSFetchRequest = KeyInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId==%@", userId)
        do{
            let result: KeyInfo? = try context.fetch(fetchRequest).first
            return result
        }catch{
            return nil
        }
    }
    
    public func updateKeyInfoWith(userId: String, cluster: String, rsa: String){
        let fetchRequest: NSFetchRequest = KeyInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId==%@", userId)
        do{
            if let result: KeyInfo = try context.fetch(fetchRequest).first{
                result.kmsCluster = cluster
                result.rsaPublicKey = rsa
                saveContext()
            }
        }catch let error as NSError{
            SDKLogger.shared.error(error.description)
        }
    }
    
    public func deleteUserInfoWith(userId: String){
        let fetchRequest: NSFetchRequest = KeyInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId==%@", userId)
        do{
            if let result: KeyInfo = try context.fetch(fetchRequest).first{
                context.delete(result)
            }
        }catch let error as NSError{
            SDKLogger.shared.error(error.description)
        }
    }
    
    public func deleteAllKeyInfo(){
        if let result = getAllKeyInfo(){
            for keyInfo in result{
                context.delete(keyInfo)
            }
            saveContext()
        }
    }
    
    // MARK: RoomResource Manage Funtions
    
    
}
