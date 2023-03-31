import SwiftUI


struct HomeView: View {

    @StateObject var vm = HomeViewModel()
    @State var showFiles: Bool = false
    
    
    var body: some View {
    
        VStack(alignment: .center) {
            Spacer()
            
            SoundBarsDisplay(samples: vm.sample, vm: vm)
            
            Spacer()
            
                
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(Color.white)
                    .shadow(radius: 15.0)
                    Text(vm.selectedRecord != nil ? "\(vm.selectedRecord?.stamp.formatted() ?? "")" : "  Record something...")
                        .padding(.horizontal)
                        .frame(alignment: .trailing)
                    }
                .padding()
            
            
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
        .sheet(isPresented: $showFiles, content: {FilesView(viewModel: vm)})
    }
}



extension HomeView {

    var stop: some View {
        Button(action: {
            if vm.isRecording {
                vm.stopRecording()
                }
            else if vm.isPlaying {
                vm.stopPlayBack()
            }
        }, label: {
                    Image(systemName: "stop" )
                        .font(.system(size: 50))
                        .foregroundColor(Color.purple)
                })
                .padding()
    }
    
    var record: some View {
        Button(
        action: {
            if vm.isRecording {
                vm.stopRecording()
            } else {
                vm.record()
            }
        },
        label: {
            Image(systemName: "record.circle").foregroundColor(vm.isRecording ? Color.red : Color.secondary)
                .font(.system(size: 50))
            })
            .padding()
    }
    
    var play: some View {
        Button(action: {vm.play()}, label: {
                    Image(systemName: "play" )
                        .font(.system(size: 50))
                        .foregroundColor(vm.isPlaying ? Color.green : Color.secondary)
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
