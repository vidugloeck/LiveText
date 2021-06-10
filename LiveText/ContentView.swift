//
//  ContentView.swift
//  LiveText
//
//  Created by Vidu Glöck on 09.06.21.
//

import SwiftUI

struct ContentView: View {
    let image = UIImage(named: "TestImage")!
    @State var results: [DisplayResult]? = []
    var text: String {
        if let results = results, results.count > 0 {
            return results.map(\.text).joined(separator: " ")
        }
        return "Processing"
    }
    var body: some View {
        VStack {
            VisionView(image: image, ocrResults: results)
            ScrollView(.horizontal) {
               Text(text)
                    .padding()
            }
            .background(Color.gray)
            
        }
            .onAppear {
                OCR.recognize(image: image.cgImage!) { result in
                    results = result
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
