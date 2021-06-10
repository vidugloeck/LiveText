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
}

extension EditType: Identifiable {
    var id: Int {
        switch self {
        case .revision:
            return 0
        case .accuracy:
            return 1
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

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(editType: .revision(.constant(0)))
    }
}
