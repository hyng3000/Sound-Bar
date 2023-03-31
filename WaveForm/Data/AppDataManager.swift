//
//  AppDataManager.swift
//  WaveForm
//
//  Created by Hamish Young on 30/3/2023.
//

import Foundation

class AppFileManager {
    
    static let instance = AppFileManager()
    private init() {}
    
//    func saveUIImage(_ image: UIImage, as name: String, in directoryName: String) {
//
//        createDirectoryIfNeeded(directoryName: directoryName)
//
//        guard
//            let data = image.pngData(),
//            let url = getPathForPNGImage(imageName: name, directoryName: directoryName)
//            else { return }
//
//        do {
//            try data.write(to: url)
//        } catch let error {
//            print("Error saving image: '\(name)' \(error)")
//        }
//    }
    
//    func getRecording(recordName: String, directoryName: String) -> Recording? {
//        guard let
//            url = getPathFor_m4a(recordName: recordName, directoryName: directoryName),
//            FileManager.default.fileExists(atPath: url.path)
//        else { return nil }
//
//        return Recording()
//    }





    
    func createDirectoryIfNeeded(directoryName: String) {
        guard let url = getUrlForDirectory(directoryName: directoryName) else { return }
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do { try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil) }
            catch let e {
                print("Error creating directory: '\(directoryName)' -> \(e)")
            }
        }
    }
    
    func getUrlForDirectory(directoryName: String) -> URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return url.appendingPathComponent(directoryName)
    }
    
    func getPathFor_m4a(recordName: String, directoryName: String) -> URL? {
        createDirectoryIfNeeded(directoryName: directoryName)
        guard let parent = getUrlForDirectory(directoryName: directoryName) else { return nil }
        return parent.appendingPathComponent(recordName + ".m4a")
    }
    
    
    func getDate(for file: URL) -> Date? {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return nil
        }
    }
    
    func deleteRecord(at url: URL) {
        do {
            try FileManager.default.removeItem(at : url)
        } catch let e {
            print(e)
        }
    }
    
    func getAllFilesFromDir(name: String) -> [URL]? {
    
        guard let directory = AppFileManager.instance.getUrlForDirectory(directoryName: name) else { return nil }
        
        guard let allFiles = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return nil }
        
        return allFiles
        
    }
    
}
