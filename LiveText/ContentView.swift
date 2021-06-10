//
//  ContentView.swift
//  LiveText
//
//  Created by Vidu Glöck on 09.06.21.
//

import SwiftUI


struct Model: Equatable {
    var results: [DisplayResult]? = []
    var revision: Int = OCR.revisions.last!
    var textRecognitionLevel: TextRecognitionLevel = .accurate
}

extension Model {
    var ocrRequest: OCRRequest {
        OCRRequest(revision: revision, textRecognitionLevel: textRecognitionLevel)
    }
}

struct ContentView: View {
    let image = UIImage(named: "TestImage")!
    @State var model = Model()
    @State var edit: EditType? = nil
    var text: String {
        if let results = model.results, results.count > 0 {
            return results.map(\.text).joined(separator: " ")
        }
        return "Processing"
    }
    var body: some View {
        VStack {
            VisionView(image: image, ocrResults: model.results)
            HStack {
                Button(action: { edit = .revision($model.revision) }) { text(for: "Revision") }
                Button(action: { edit = .accuracy($model.textRecognitionLevel) }) { text(for: "Accuracy") }
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
        OCR.recognize(image: image.cgImage!, request: model.ocrRequest) { result in
            model.results = result
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
