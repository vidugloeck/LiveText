//
//  ContentView.swift
//  LiveText
//
//  Created by Vidu Glöck on 09.06.21.
//

import SwiftUI


struct Model: Equatable {
    var results: [OCRResult] = []
    var revision: Int = OCR.revisions.last!
    var textRecognitionLevel: TextRecognitionLevel = .accurate
    var minTextHeight: Float = 1/32
}

extension Model {
    var ocrRequest: OCRRequest {
        OCRRequest(revision: revision, textRecognitionLevel: textRecognitionLevel, minTextHeight: minTextHeight)
    }
}

struct ContentView: View {
    let image = UIImage(named: "TestImage")!
    @State var model = Model()
    @State var edit: EditType? = nil
    @State var isProcessing: Bool = false
    var text: String {
        if isProcessing { return "Processing ..." }
        if model.results.isEmpty { return "No Results" }
        return model.results.map(\.text).joined(separator: " ")
    }

    var body: some View {
        VStack {
            VisionView(image: image, ocrResults: model.results)
            HStack {
                Button(action: { edit = .revision($model.revision) }) { text(for: "Revision") }
                Button(action: { edit = .accuracy($model.textRecognitionLevel) }) { text(for: "Accuracy") }
                Button(action: { edit = .minHeight($model.minTextHeight) }) { text(for: "Height") }
            }
            ScrollView(.horizontal) {
               Text(text)
                    .padding()
            }
            .background(Color.gray)
            
        }
        .sheet(item: $edit, onDismiss: { edit = nil }, content: { edit in
            EditView(editType: edit)
        })
        .onAppear { recognize() }
        .onChange(of: model) { _ in recognize() }
    }
    
    func text(for text: String) -> some View {
        Text(text)
            .padding()
            .buttonStyle(.bordered)
    }
    
    func recognize() {
        isProcessing = true
        OCR.recognize(image: image.cgImage!, request: model.ocrRequest) { result in
            model.results = result ?? []
            isProcessing = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
