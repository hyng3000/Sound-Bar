//
//  WaveformViewModel.swift
//  WaveForm
//
//  Created by Hamish Young on 28/3/2023.
//

import Foundation
import AVFoundation
import Combine

class HomeViewModel : ObservableObject {

    init() {
        studio = SoundStudio()
        studio.$samples.sink() {self.sample = $0 }.store(in: &cancellable)
    }
    
    var cancellable = Set<AnyCancellable>()
    var studio: SoundStudio
    @Published var sample: [Float] = []
    
    @Published var selectedRecord: Recording? = nil
    @Published var isRecording: Bool = false
    @Published var isPlaying: Bool = false
    @Published var records: [Recording] = [] {
        willSet {
            objectWillChange.send()
        }
    }
    
    
    let RecordsDir: String = "Records"
    
    func selectRecord(_ record: Recording) {
        selectedRecord = record
    }
    
    func selectRecord(url: URL) {
        selectedRecord =
        Recording(
            name: (url.formatted() as NSString).lastPathComponent,
            stamp: AppFileManager.instance.getDate(for: url) ?? Date(),
            playing: false,
            url: url
            )
    }

    func normalizeLevel(level: Float) -> CGFloat {
            if level == 0.0 {return 0.2}
            let level = max(0.2, CGFloat(level) + 50) / 2
            return CGFloat(level * (300 / 25))
        }
    
    func record() {
        isRecording = true
        guard let url = studio.record() else { return }
        selectRecord(url: url)
    }
    
    func stopRecording() {
        isRecording = false
        studio.stopRecording()
    }
    
    func play(){
        guard case let isRecording, isRecording == false else { return }
        guard let url = selectedRecord?.url else { return }
        isPlaying = true
        do {
            try studio.play(url: url)
        } catch let error {
            isPlaying = false
            print("PlayBack Error: \(error)")
        }
        
        guard let currentIndex = records.firstIndex(where: { $0.url.path() == url.path() }) else { return }
        records[currentIndex].playing = true
    }
    
    func stopPlayBack(){
        isPlaying = false
        studio.stopPlayBack()
        records.indices.forEach({ records[$0].playing = false })
    }
    
    func getPreviousRecords() async {
    
       guard let allRecordingFiles = AppFileManager.instance.getAllFilesFromDir(name: RecordsDir) else { return }
            
        if allRecordingFiles.count != records.count {
            await MainActor.run {
                records.removeAll(keepingCapacity: true)
                for file in allRecordingFiles {
                    records.append(
                        Recording(
                            name: (file.formatted() as NSString).lastPathComponent,
                            stamp: AppFileManager.instance.getDate(for: file) ?? Date(),
                            playing: false,
                            url: file
                            )
                        )
                    }
                    records.sort(by: {$0.stamp.compare($1.stamp) == .orderedDescending})
                }
            }
        }
        
    func deleteRecording(_ record: Recording) {
        guard let index = records.firstIndex(where: { $0.url == record.url }) else { return }
        selectedRecord = nil
        records.remove(at: index)
        deleteRecordingFile(url: record.url)
    }
        
    func deleteRecordingFile(url : URL){
        AppFileManager.instance.deleteRecord(at: url)
    }


}
