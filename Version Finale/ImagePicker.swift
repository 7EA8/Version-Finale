//
//  ImagePicker.swift
//  Version Finale
//
//  Created by Tiago Alves on 24.07.2024.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            PhotosPicker(
                selection: Binding(get: {
                    nil
                }, set: { newItem in
                    if let newItem = newItem {
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self) {
                                image = UIImage(data: data)
                                isPresented = false
                            }
                        }
                    }
                }),
                matching: .images,
                photoLibrary: .shared()) {
                Text("Select an Image")
            }
            .padding()
        }
        .navigationTitle("Choose Image")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
        }
    }
}
