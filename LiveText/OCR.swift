import Foundation
import Vision

struct OCR {
    static var revisions: [Int] {
        Array(VNRecognizeTextRequest.supportedRevisions)
    }
    
    @available(iOS 15.0, *)
    static func availableLanguages(revision: Int, accuracy: TextRecognitionLevel) -> [String]? {
        let request = VNRecognizeTextRequest(completionHandler: nil)
        request.revision = revision
        request.recognitionLevel = accuracy.vnTextRecognitionLevel
        return try? request.supportedRecognitionLanguages()
    }
    private static var currentRequest: VNRecognizeTextRequest?
    static func recognize(image: CGImage, request: OCRRequest, completion: @escaping ([OCRResult]?) -> Void) {
        currentRequest?.cancel()
        let requestHandler = VNImageRequestHandler(cgImage: image)
        let textRecognitionRequest = createRequest(ocrRequest: request, completion: completion)
        DispatchQueue.global(qos: .userInteractive).async  {
            do {
                try requestHandler.perform([textRecognitionRequest])
            } catch {
                completion(nil)
            }
        }
        currentRequest = textRecognitionRequest
        
    }
    
    private static func createRequest(ocrRequest: OCRRequest, completion: @escaping ([OCRResult]?) -> Void) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                if let request = request as? VNRecognizeTextRequest, let results = request.results {
                    completion(results.map(OCRResult.init))
                } else {
                    completion(nil)
                }
            }
        }
        request.revision = ocrRequest.revision
        request.recognitionLevel = ocrRequest.textRecognitionLevel.vnTextRecognitionLevel
        request.minimumTextHeight = ocrRequest.minTextHeight
        if ocrRequest.languages.count > 0 {
            request.recognitionLanguages = ocrRequest.languages
        }
        
        return request
    }
        
}

struct OCRRequest {
    let revision: Int
    let textRecognitionLevel: TextRecognitionLevel
    let minTextHeight: Float
    let languages: [String]
}

struct OCRResult: Equatable {
    let text: String
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
    let topLeft: CGPoint
    let topRight: CGPoint
}

extension OCRResult {
    init(observation: VNRecognizedTextObservation) {
        bottomLeft = observation.bottomLeft
        bottomRight = observation.bottomRight
        topLeft = observation.topLeft
        topRight = observation.topRight
        text = observation.topCandidates(1)[0].string
    }
}

enum TextRecognitionLevel: String, CaseIterable {
    case fast
    case accurate
}

extension TextRecognitionLevel {
    var vnTextRecognitionLevel: VNRequestTextRecognitionLevel {
        switch self {
        case .fast:
            return .fast
        case .accurate:
            return .accurate
        }
    }
}
