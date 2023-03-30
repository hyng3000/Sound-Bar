//
//  Files.swift
//  WaveForm
//
//  Created by Hamish Young on 30/3/2023.
//

import SwiftUI

struct FilesView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var studio: SoundStudio


    var body: some View {
        VStack(alignment: .center){
            List{
                ForEach(studio.records) { record in
                    Text(record.stamp.formatted())
                    .onTapGesture {
                            studio.lastRecordedUrl = record.url
                            dismiss()
                    }
                }
            }
            .listStyle(.plain)
            .background(Color(UIColor.secondarySystemBackground))
            
            Spacer()
            exitButton
        }.task {
            await studio.getPreviousRecords()
        }
    }
    
}

extension FilesView {
    var exitButton: some View {
        Button(
            action: {
                dismiss()
                },
            label: {
                Image(systemName: "xmark")
                    .font(.headline)
            })
    }
}

struct Files_Previews: PreviewProvider {
    static var previews: some View {
        FilesView(studio: SoundStudio())
    }
}
