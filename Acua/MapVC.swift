//
//  MapVC.swift
//  Acua
//
//  Created by AHero on 6/9/18.
//  Copyright © 2018 AHero. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initMap()
    }

    private func initMap() -> Void {
        if let location = AppManager.shared.mapLocation {
            let coord = CLLocationCoordinate2D.init(latitude: location.latitude, longitude: location.longitude)
            let cameraPos = GMSCameraPosition.camera(withTarget: coord, zoom: 15)
            self.mapView.animate(to: cameraPos)
            let marker : GMSMarker = GMSMarker.init(position: coord)
            marker.map = self.mapView
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    

}
