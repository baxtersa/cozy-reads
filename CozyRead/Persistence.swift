//
//  Persistence.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/1/23.
//

import CoreData
import struct SwiftUI.Color

struct PersistenceController {
    private func populateStore() {
        print("Populating")
        let viewContext = container.viewContext

        // Fake some reading dates
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: .now)),
           let dayBefore = Calendar.current.date(byAdding: .day, value: -2, to: Calendar.current.startOfDay(for: .now)) {
            for day in [yesterday, dayBefore] {
                let entry = ReadingTrackerEntity(context: viewContext)
                entry.date = day
            }
        }

        let profile = ProfileEntity(context: viewContext)
        profile.uuid = UUID()
        profile.name = "Sam"
        UserDefaults.standard.setValue(profile.uuid.uuidString, forKey: Onboarding.Constants.defaultProfile)
        UserDefaults.standard.setValue(true, forKey: Onboarding.Constants.onboardingVersion)

        let goal = YearlyGoalEntity(context: viewContext)
        goal.setYear(year: 2023)
        goal.goal = 45
        goal.profile = profile

        let books: [BookCSVData] = CSVReader.readCSV(inputFile: "data.csv", context: viewContext)
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            books.forEach{ book in
                book.profile = profile
            }
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        result.populateStore()
        return result
    }()

    let container: NSPersistentCloudKitContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "CozyRead")
        
        // Only initialize the schema when building the app with the
        // Debug build configuration.
        #if DEBUG
        do {
            // Use the container to initialize the development schema.
            try container.initializeCloudKitSchema(options: [])
        } catch {
            // Handle any errors.
        }
        #endif

        if inMemory || UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
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

        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            populateStore()
//            let _: [BookCSVData] = CSVReader.readCSV(inputFile: "data.csv", context: container.viewContext)
        }
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
}
