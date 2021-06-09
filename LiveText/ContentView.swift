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
    var body: some View {
        VisionView(image: image, ocrResults: results)
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
