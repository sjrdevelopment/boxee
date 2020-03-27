//
//  ViewController.swift
//  Boxee
//
//  Created by Stuart Robinson on 27/03/2020.
//  Copyright © 2020 Stuart Robinson. All rights reserved.
//

import UIKit
import CoreNFC
import VYNFCKit

class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?
    
    @IBOutlet weak var tagTextLabel: UILabel!
    
    
    @IBAction func scanForNFC(_ sender: Any) {
        guard session == nil else {
           return
       }
       session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
       session?.alertMessage = "Hold the NFC chip up to the iPhone."
       session?.begin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
   
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
        guard
            let ndefMessage = messages.first,
            let record = ndefMessage.records.first,
        
            record.typeNameFormat == .absoluteURI || record.typeNameFormat == .nfcWellKnown else {
                return
            }
    
        
        guard let parsedPayload = VYNFCNDEFPayloadParser.parse(record) else {
            return
        }
       
        var tagText = ""
        
        if let parsedPayload = parsedPayload as? VYNFCNDEFTextPayload {
            tagText = String(format: "%@%@", tagText, parsedPayload.text)
            
            print("parsed: \(tagText)")
            
            DispatchQueue.main.async {
                self.tagTextLabel.text = tagText
            }

        }
        
        self.session = nil
        
    }

    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
        if let readerError = error as? NFCReaderError {
            // errors on successful tag read as session ends (error code 204)
            // other errors can be handled
            
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
             
                let alert = UIAlertController(title: "Did you bring your towel?", message: "It's recommended you bring your towel before continuing.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
              
                self.present(alert, animated: true)
            }
        }
        
        // A new session instance is required to read new tags.
        self.session = nil
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("Reader session active")
    }

}
