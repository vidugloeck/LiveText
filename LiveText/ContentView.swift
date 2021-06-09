//
//  ContentView.swift
//  LiveText
//
//  Created by Vidu Glöck on 09.06.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Image("TestImage")
            .resizable()
            .padding()
            .onAppear {
                OCR.recognize(image: UIImage(named: "TestImage")!.cgImage!) { result in
                    print(result)
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
