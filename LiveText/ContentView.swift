//
//  ContentView.swift
//  LiveText
//
//  Created by Vidu Glöck on 09.06.21.
//

import SwiftUI


struct Model: Equatable {
    var revision: Int = OCR.revisions.last!
    var textRecognitionLevel: TextRecognitionLevel = .accurate
    var minTextHeight: Float = 0
    var language: Language = .none
}

enum Language: Equatable, Hashable {
    case none
    case all
    case specific(String)
    
    init(text: String) {
        if text == "None" { self = .none }
        if text == "All" { self = .all }
        self = .specific(text)
    }
    
    var text: String {
        switch self {
        case .none:
            return "None"
        case .all:
            return "All"
        case .specific(let language):
            return language
        }
    }
}

struct ViewModel {
    init() {
        availableLanguages = updateAvailableLanguages()
    }
    var model = Model() {
        didSet {
            availableLanguages = updateAvailableLanguages()
        }
    }
    var results: [OCRResult] = []
    var revision: Int { get { model.revision } set { model.revision = newValue } }
    var textRecognitionLevel: TextRecognitionLevel { get { model.textRecognitionLevel } set { model.textRecognitionLevel = newValue } }
    var minTextHeight: Float { get { model.minTextHeight } set { model.minTextHeight = newValue } }
    var language: Language { get { model.language } set { model.language = newValue } }
    var editType: EditType? = nil
    var isProcessing: Bool = false
    var availableLanguages: [Language] = []
    
    func updateAvailableLanguages() -> [Language] {
        if #available(iOS 15.0, *) {
            return [.all, .none] + (OCR.availableLanguages(for: ocrRequest) ?? []).map(Language.init)
        } else {
            return [.none]
        }
    }
    
    var ocrRequest: OCRRequest {
        OCRRequest(revision: revision, textRecognitionLevel: textRecognitionLevel, minTextHeight: minTextHeight, languages: ocrLanguages)
    }
    
    private var ocrLanguages: [String] {
        switch language {
        case .none:
            return []
        case .all:
            if #available(iOS 15.0, *) {
                return OCR.availableLanguages(for: ocrRequest) ?? []
            } else {
                return []
            }
        case .specific(let string):
            return [string]
        }
    }
}

struct ContentView: View {
    let image = UIImage(named: "TestImage")!
    @State var viewModel = ViewModel()
    var text: String {
        if viewModel.isProcessing { return "Processing ..." }
        if viewModel.results.isEmpty { return "No Results" }
        return viewModel.results.map(\.text).joined(separator: " ")
    }
    
    @available(iOS 15.0, *)
    var languageViewModel: LanguageViewModel {
        LanguageViewModel(availableLanguages: viewModel.availableLanguages,
                          language: $viewModel.language)
    }

    var body: some View {
        VStack {
            VisionView(image: image, ocrResults: viewModel.results)
            HStack {
                Button(action: { viewModel.editType = .revision($viewModel.revision) }) { text(for: "Revision") }
                Button(action: { viewModel.editType = .accuracy($viewModel.textRecognitionLevel) }) { text(for: "Accuracy") }
                Button(action: { viewModel.editType = .minHeight($viewModel.minTextHeight) }) { text(for: "Height") }
                if #available(iOS 15.0, *) {
                    Button(action: { viewModel.editType = .language(languageViewModel) }) { text(for: "Language") }
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
        .sheet(item: $viewModel.editType, onDismiss: { viewModel.editType = nil }, content: { edit in
            EditView(editType: edit)
        })
        .onAppear { recognize() }
        .onChange(of: viewModel.model) { _ in recognize() }
    }
    
    func recognize() {
        viewModel.isProcessing = true
        OCR.recognize(image: image.cgImage!, request: viewModel.ocrRequest) { result in
            viewModel.results = result ?? []
            viewModel.isProcessing = false
        }
    }
    
    func text(for text: String) -> some View {
        Text(text)
            .padding()
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
