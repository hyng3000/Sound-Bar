//
//  SoundsStudio.swift
//  WaveForm
//
//  Created by Hamish Young on 31/3/2023.
//

import Foundation
import AVFoundation

class SoundStudio: NSObject, ObservableObject, AVAudioPlayerDelegate {
     
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var numberOfSamples: Int = 10
    var currentSample: Int = 0
    var timer: Timer? = nil

    @Published var lastRecordedUrl: URL? = nil
    @Published var isRecording: Bool = false
    @Published var isPlaying: Bool = false
    @Published var records: [Recording] = [] {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var samples: [Float]
    
    
    
    let RecordsDir: String = "Records"
    
        override init() {
            self.samples = [Float](repeating: .zero, count: numberOfSamples)
            super.init()
        }
    
    func record() {
        let session = AVAudioSession.sharedInstance()
        checkRecordingPermissions(session: session)
        
        do {
            try session.setActive(false)
            try session.setCategory(.playAndRecord, mode: .default) // Configure / Set Up recording session
            try session.setActive(true) // activatesession
        } catch  {
            print("recording config error")
        }
        
        guard let fileName = AppFileManager.instance.getPathFor_m4a(recordName: "Recording-\(Date())", directoryName: RecordsDir) else { return }
        
        let setting = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: setting)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
            startMonitoring()
            lastRecordedUrl = fileName
            print(lastRecordedUrl!)
            print("Recording")
        } catch {
            print("recording init error")
        }
        
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        Task {await getPreviousRecords()}
        print("Stopped Recording")
    }
    
    func getPreviousRecords() async {
    
        guard let recordsDirectory = AppFileManager.instance.getUrlForDirectory(directoryName: RecordsDir) else { return }
        guard let allRecordingFiles = try? FileManager.default.contentsOfDirectory(at: recordsDirectory, includingPropertiesForKeys: nil) else { return }
        
        if allRecordingFiles.count != records.count {
            await MainActor.run {
                records.removeAll(keepingCapacity: true)
                for file in allRecordingFiles {
                    self.records.append(
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
        
    func playLast() {
        if let lastRecordedUrl {
            play(url: lastRecordedUrl)
        }
    }
    
    func play(url: URL) {
        print("Play")
        if !isRecording {
            let session = AVAudioSession.sharedInstance()
            
            do {
                try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } catch {
                print("Error play set up")
            }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
                guard let currentIndex = records.firstIndex(where: { $0.url.path() == url.path() }) else {return}
                records[currentIndex].playing = true
                
            } catch {
                print("Play back error")
            }
        }
    }
    
    func stopPlayBack() {
        audioPlayer?.stop()
        records.indices.forEach({ records[$0].playing = false })
    }
    
    
    func deleteRecording(url : URL){
    
        guard let currentIndex = records.firstIndex(where: { $0.url.path() == url.path() }) else { return }
        if records[currentIndex].playing == true {
            stopPlayBack()
        }
    
        do {
            try FileManager.default.removeItem(at : url)
            records.remove(at: currentIndex)
        } catch {
            print("Can't delete")
        }
    }

    func checkRecordingPermissions(session: AVAudioSession) {
           if session.recordPermission != .granted {
            session.requestRecordPermission { (permission) in
                if !permission {
                    return
                }
            }
        }
    }

    func setSamples(numberOfSamples: Int) -> Int {
        if numberOfSamples > 0 {
            return numberOfSamples
        } else {
            return 10
        }
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            self.audioRecorder.updateMeters()
            
            self.samples[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        })
    }
    
}
