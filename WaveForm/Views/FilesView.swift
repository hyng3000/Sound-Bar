//
//  Files.swift
//  WaveForm
//
//  Created by Hamish Young on 30/3/2023.
//

import SwiftUI

struct FilesView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: HomeViewModel


    var body: some View {
        VStack(alignment: .center){
            List{
                ForEach(viewModel.records) { record in
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .foregroundColor(Color.white)
                                .shadow(radius: 15.0)
                            HStack {
                            Text(record.stamp.formatted())
                                    .onTapGesture {
                                        viewModel.selectRecord(record)
                                        dismiss()
                                    }
                            .padding(.horizontal)
                            Spacer()
                            exitButton
                                    .onTapGesture {
                                        viewModel.deleteRecording(record)
                                    }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .background(Color(UIColor.secondarySystemBackground))
            
            Spacer()
            exitButton
        }.task {
            await viewModel.getPreviousRecords()
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
        FilesView(viewModel: HomeViewModel())
    }
}
