import SwiftUI


struct ContentView: View {

    @ObservedObject private var microphone = AudioAnalyzer(numberOfSamples: 10)
    @StateObject var vm = WaveformViewModel()
    
    var body: some View {
        VStack {
            Text("Listen")
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.primary)
                    .frame(width: 350, height: 350)
                    .overlay(
                    HStack(spacing: 4) {
                    ForEach(microphone.soundSamples, id: \.self) { level in
                            SoundBar(value: vm.normalizeLevel(level: level), sampleSize: 10)
                    }
                })
            }
        }
    }
}

