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

    @Published var samples: [Float]
    
    
    let RECORDS_DIR: String = "Records"
    
    override init() {
        self.samples = [Float](repeating: .zero, count: numberOfSamples)
        super.init()
        let session = AVAudioSession.sharedInstance()
        checkRecordingPermissions(session: session)
        
        do {
            try session.setActive(false)
            try session.setCategory(.playAndRecord, mode: .default) // Configure / Set Up recording session
            try session.setActive(true) // activatesession
        } catch  {
            print("recording config error")
        }
    }
    
    func record() -> URL? {
        
        guard let fileName = AppFileManager.instance.getPathFor_m4a(recordName: "Recording-\(Date())", directoryName: RECORDS_DIR) else { return nil }
        
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
            startMonitoring()
            print("Recording")
        } catch {
            print("recording init error")
        }
        return fileName
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        print("Stopped Recording")
    }
    
    
    func play(url: URL) throws {
        print("Play")
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
            } 
    }
    
    func stopPlayBack() {
        audioPlayer?.stop()
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
