import Foundation
import Vision

struct OCR {
    private static var currentRequest: VNRecognizeTextRequest?
    static func recognize(image: CGImage, completion: @escaping ([DisplayResult]?) -> Void) {
        currentRequest?.cancel()
        let requestHandler = VNImageRequestHandler(cgImage: image)
        let textRecognitionRequest = createRequest(completion)
        DispatchQueue.global(qos: .userInteractive).async  {
            do {
                try requestHandler.perform([textRecognitionRequest])
            } catch {
                completion(nil)
            }
        }
        currentRequest = textRecognitionRequest
        
    }
    
    private static func createRequest(_ completion: @escaping ([DisplayResult]?) -> Void) -> VNRecognizeTextRequest {
        VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                if let request = request as? VNRecognizeTextRequest, let results = request.results {
                    completion(results.map(DisplayResult.init))
                } else {
                    completion(nil)
                }
            }
        }
    }
        
}

struct DisplayResult {
    let text: String
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
    let topLeft: CGPoint
    let topRight: CGPoint
}

extension DisplayResult {
    init(observation: VNRecognizedTextObservation) {
        bottomLeft = observation.bottomLeft
        bottomRight = observation.bottomRight
        topLeft = observation.topLeft
        topRight = observation.topRight
        text = observation.topCandidates(1)[0].string
    }
}
