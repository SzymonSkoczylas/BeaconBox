//
//  ViewController.swift
//  BeaconBox
//
//  Created by achim on 11/05/2024.
//

import UIKit
import EstimoteUWB
import SwiftUI

        //-----------------------------//
        //-----------------------------//
        //        Global vars          //
        //-----------------------------//
        //-----------------------------//

var trustedBeaconIDs = [String]()       // tu powinny sie znalesc id beaconow ktore moga przeprowadzic autoryzacje
var beaconsInRange = [(ID : String, distance : Float, inAuthRange : Bool)]()
var isAuthorizedByBeacon : Bool = false
        //-----------------------------//
        //-----------------------------//
        //        Controller code      //
        //-----------------------------//
        //-----------------------------//


class ViewController: UIViewController {
    
    let uwb = EstimoteUWBManagerExample()

    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var AuthorizeByBeaconButton: UIButton!
    
    @IBAction func AuthorizeByBeaconButtonClicked(_ sender: UIButton) {
        
        //sprawdz czy to dziala
       
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC2 = storyboard.instantiateViewController(identifier: "ViewController2")
        if isAuthorizedByBeacon == true{
            show(VC2, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}


        //-----------------------------//
        //-----------------------------//
        //  Estimote controller below  //
        //-----------------------------//
        //-----------------------------//

class EstimoteUWBManagerExample: NSObject, ObservableObject {
    private var uwbManager: EstimoteUWBManager?

    override init() {
        super.init()
        setupUWB()
    }

    private func setupUWB() {
        uwbManager = EstimoteUWBManager(delegate: self, options: EstimoteUWBOptions(shouldHandleConnectivity: true, isCameraAssisted: false))
        uwbManager?.startScanning()
    }
}


// REQUIRED PROTOCOL
extension EstimoteUWBManagerExample: EstimoteUWBManagerDelegate {
    func didUpdatePosition(for device: EstimoteUWBDevice) {
        //print("Position updated for device: \(device)")
        for (index, _) in beaconsInRange.enumerated() {
            
            if (beaconsInRange[index].ID == device.publicIdentifier){
                beaconsInRange[index].distance = device.distance
            }
            
            if(beaconsInRange[index].distance < 5.0){
                beaconsInRange[index].inAuthRange = true
            }
            else{
                beaconsInRange[index].inAuthRange = false
            }
            
        }
        Authorization()
    }
    
    // OPTIONAL
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        print("Discovered device: \(device.publicIdentifier) rssi: \(rssi)")
        // if shouldHandleConnectivity is set to true - then you could call manager.connect(to: device)
        // additionally you can globally call discoonect from the scope where you have inititated EstimoteUWBManager -> disconnect(from: device) or disconnect(from: publicId)
        
        trustedBeaconIDs.append(device.publicIdentifier)
        beaconsInRange.append((device.publicIdentifier,0.0,false))
    }
    
    // OPTIONAL
    func didConnect(to device: UWBIdentifiable) {
        print("Successfully connected to: \(device.publicIdentifier)")
    }
    
    // OPTIONAL
    func didDisconnect(from device: UWBIdentifiable, error: Error?) {
        print("Disconnected from device: \(device.publicIdentifier)- error: \(String(describing: error))")
    }
    
    // OPTIONAL
    func didFailToConnect(to device: UWBIdentifiable, error: Error?) {
        print("Failed to conenct to: \(device.publicIdentifier) - error: \(String(describing: error))")
    }
    
    func Authorization()
    {
        for id in trustedBeaconIDs
            { print("Trusted Beacon ID : " + id) }
        for beacon in beaconsInRange
            { print("Discovered Beacon ID : " + beacon.ID) }
        print("clicked")
        
        //jezeli tak to to powinno swapnac do view controllera 2
        
        
        
        for trustedBeaconID in trustedBeaconIDs {
            for discoveredBeacon in beaconsInRange {
                if discoveredBeacon.ID == trustedBeaconID && discoveredBeacon.inAuthRange == true {
                    isAuthorizedByBeacon = true
                }
                else{
                    isAuthorizedByBeacon = false
                }
            }
        }
    }
    // OPTIONAL PROTOCOL FOR BEACON BLE RANGING
//    func didRange(for beacon: EstimoteBLEDevice) {
//        print("Beacon did range: \(beacon)")
//    }
}
