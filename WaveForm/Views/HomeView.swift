import SwiftUI


struct HomeView: View {

    @StateObject var vm = HomeViewModel()
    @StateObject var studio: SoundStudio = SoundStudio()
    
    @State var showFiles: Bool = false
    
    
    var body: some View {
    
        VStack(alignment: .center) {
            Spacer()
            
            SoundBarsDisplay(samples: studio.samples, vm: vm)
            
            Spacer()
            
            if !studio.samples.isEmpty {
                if let date = studio.records.first?.stamp {
                Text("\(date.formatted())")
                }
            }
            
            HStack(alignment: .center){
                Spacer()
                record
                Spacer()
                play
                Spacer()
                stop
                Spacer()
            }
            Spacer()
        }
        .navigationTitle("Listen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: { fileButton })
        .sheet(isPresented: $showFiles, content: {FilesView(studio: studio)})
    }
}



extension HomeView {

    var stop: some View {
        Button(action: {studio.stopRecording()}, label: {
                    Image(systemName: "stop" )
                        .font(.system(size: 50))
                })
                .padding()
    }
    
    var record: some View {
        Button(
        action: {
            if studio.isRecording {
                studio.stopRecording()
            } else {
                studio.record()
            }
        },
        label: {
            Image(systemName: "record.circle").foregroundColor(studio.isRecording ? Color.red : Color.secondary)
                .font(.system(size: 50))
            })
            .padding()
    }
    
    var play: some View {
        Button(action: {studio.playLast()}, label: {
                    Image(systemName: "play" )
                        .font(.system(size: 50))
                })
                .padding()
    }

    
    var textFieldFiller: some View {
         Rectangle().frame(height: 70).foregroundColor(.clear).padding()
    }
    
    var fileButton: some View {
        Button(action: {showFiles.toggle()}) {
            Image(systemName: "folder.circle").font(.system(size: 30))
        }
    }
    
}
