//
//  EditView.swift
//  LiveText
//
//  Created by Vidu Glöck on 10.06.21.
//

import SwiftUI

enum EditType {
    case revision(Binding<Int>)
}

extension EditType: Identifiable {
    var id: Int {
        switch self {
        case .revision:
            return 0
        }
    }
}

struct EditView: View {
    let editType: EditType
    var body: some View {
        switch editType {
        case .revision(current: let revision):
            RevisionView(revision: revision)
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

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(editType: .revision(.constant(0)))
    }
}
