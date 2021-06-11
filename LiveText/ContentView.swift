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
    var minTextHeight: Float = 0
    var language: String = ""
}

extension Model {
    var ocrRequest: OCRRequest {
        return OCRRequest(revision: revision, textRecognitionLevel: textRecognitionLevel, minTextHeight: minTextHeight, languages: ocrLanguages)
    }
    
    var ocrLanguages: [String] {
        if language.isEmpty || language == "None" { return [] }
        if language == "All" {
            if #available(iOS 15.0, *) {
                return OCR.availableLanguages(revision: revision, accuracy: textRecognitionLevel) ?? []
            } else {
                return []
            }
        }
        return [language]
        
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
    
    @available(iOS 15.0, *)
    var languageViewModel: LanguageViewModel {
        LanguageViewModel(availableLanguages: availableLanguages, languages: $model.language)
    }
    
    @available(iOS 15.0, *)
    var availableLanguages: [String] {
        ["All", "None"] + (OCR.availableLanguages(revision: model.revision, accuracy: model.textRecognitionLevel) ?? [])
    }

    var body: some View {
        VStack {
            VisionView(image: image, ocrResults: model.results)
            HStack {
                Button(action: { edit = .revision($model.revision) }) { text(for: "Revision") }
                Button(action: { edit = .accuracy($model.textRecognitionLevel) }) { text(for: "Accuracy") }
                Button(action: { edit = .minHeight($model.minTextHeight) }) { text(for: "Height") }
                if #available(iOS 15.0, *) {
                    Button(action: { edit = .language(languageViewModel) }) { text(for: "Language") }
                } else {
                    Button(action: {}) { text(for: "Language") }
                    .disabled(true)
                }
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
