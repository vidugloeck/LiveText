//
//  EditView.swift
//  LiveText
//
//  Created by Vidu Glöck on 10.06.21.
//

import SwiftUI

enum EditType {
    case revision(Binding<Int>)
    case accuracy(Binding<TextRecognitionLevel>)
    case minHeight(Binding<Float>)
    case language(LanguageViewModel)
}

extension EditType: Identifiable {
    var id: Int {
        switch self {
        case .revision:
            return 0
        case .accuracy:
            return 1
        case .minHeight:
            return 2
        case .language:
            return 3
        }
    }
}

struct EditView: View {
    let editType: EditType
    var body: some View {
        switch editType {
        case .revision(current: let revision):
            RevisionView(revision: revision)
        case .accuracy(let level):
            AccuracyView(level: level)
        case .minHeight(let minHeight):
            MinHeightView(minHeight: minHeight)
        case .language(let model):
            if #available(iOS 15.0, *) {
                LanguageView(model: model)
            } else {
                Text("Not available in iOS 14")
            }
        }
    }
}

struct RevisionView: View {
    var revision: Binding<Int>
    
    var body: some View {
        Picker("", selection: revision) {
            ForEach(OCR.revisions, id: \.self) {
                Text("Version \($0)")
            }
        }
    }
}

struct AccuracyView: View {
    let level: Binding<TextRecognitionLevel>
    
    var body: some View {
        Picker("", selection: level) {
            ForEach(TextRecognitionLevel.allCases, id: \.self) {
                Text($0.rawValue)
            }
        }
    }
}

struct MinHeightView: View {
    let minHeight: Binding<Float>
    
    var body: some View {
        VStack {
            // FIXME: Use new formatter
            Text("\(minHeight.wrappedValue * 100.0, specifier: "%.1f") %")
            Slider(value: minHeight, in: 0...1)
        }
    }
}

struct LanguageViewModel {
    let availableLanguages: [String]
    let languages: Binding<String>
}

struct LanguageView: View {
    let model: LanguageViewModel
    
    var body: some View {
        VStack {
            Picker("", selection: model.languages) {
                ForEach(model.availableLanguages, id: \.self) {
                    Text($0)
                }
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(editType: .revision(.constant(0)))
    }
}
