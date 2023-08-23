//
//  Persistence.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/1/23.
//

import CoreData

class CozyReadPersistentContainer : NSPersistentContainer {
    let profile = UserDefaults.standard.bool(forKey: Onboarding.Constants.defaultProfile)

    var backgroundContext: NSManagedObjectContext? = nil
}

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Fake some reading dates
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: .now))
        let dayBefore = Calendar.current.date(byAdding: .day, value: -2, to: Calendar.current.startOfDay(for: .now))
        for day in [yesterday, dayBefore] {
            let entry = ReadingTrackerEntity(context: viewContext)
            entry.date = day
        }
        
//        let profile = ProfileEntity(context: viewContext)
//        profile.uuid = UUID()
//        profile.name = "Sam"
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: CozyReadPersistentContainer

    private init(inMemory: Bool = false) {
        let persistance = CozyReadPersistentContainer(name: "CozyRead")
        container = persistance
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            let _: [BookCSVData] = CSVReader.readCSV(inputFile: "data.csv", context: container.viewContext)
        }
//        let _: [BookCSVData] = CSVReader.readCSV(inputFile: "data.csv", context: container.viewContext)

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
//
//        container.backgroundContext = container.newBackgroundContext()
    }

    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
                print(error.localizedDescription)
            }
        }
    }
//
//    func backgroundSave() {
//        if let context = container.backgroundContext {
//            context.perform {
//                if context.hasChanges {
//                    do {
//                        try context.save()
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }
//    }
}
