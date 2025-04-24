import SwiftData
import Foundation

actor BackgroundImporter {
    var modelContainer: ModelContainer
    var updateImportProgress: (DataImportState, Int) -> Void
    
    init(modelContainer: ModelContainer, updateImportProgress: @escaping (DataImportState, Int) -> Void) {
        self.modelContainer = modelContainer
        self.updateImportProgress = updateImportProgress
    }

    func backgroundInsert() async throws {
        let modelContext = ModelContext(modelContainer)
        
        print("Loading techniques...")
        guard let techniquesUrl = Bundle.main.url(forResource: "techniques", withExtension: "json") else {
            fatalError("Failed to find techniques.json")
        }
        let techniquesData = try Data(contentsOf: techniquesUrl)
        let techniques = try JSONDecoder().decode([Technique].self, from: techniquesData)
        print("Inserting \(techniques.count) techniques...")
        for i in 0...(techniques.count - 1)  {
            let technique = techniques[i]
            modelContext.insert(technique)
        }
        try modelContext.save()
        
        print("Loading works...")
        updateImportProgress(.loadingWorks, 0)
        guard let worksUrl = Bundle.main.url(forResource: "works", withExtension: "lzfse") else {
            fatalError("Failed to find works.lzfse")
        }
        let compressedWorksData = try Data(contentsOf: worksUrl)
        let worksData = try (compressedWorksData as NSData).decompressed(using: .lzfse)
        
        print("Decoding works...")
        updateImportProgress(.decodingWorks, 0)
        let works = try JSONDecoder().decode([Work].self, from: worksData as Data)
        
        print("Inserting \(works.count) works...")
        updateImportProgress(.insertingWorks, 0)
        var loadedWorkCounter = 0
        for i in 0...(works.count - 1)  {
            loadedWorkCounter += 1
            let work = works[i]
            modelContext.insert(work)
            if i % 1000 == 0 {
                updateImportProgress(.insertingWorks, loadedWorkCounter)
                try modelContext.save()
            }
        }
        updateImportProgress(.insertingWorks, loadedWorkCounter)
        updateImportProgress(.completed, loadedWorkCounter)
        try modelContext.save()
        print("Saved")
    }
}
