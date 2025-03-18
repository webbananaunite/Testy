//
//  Map.swift
//  Testy
//
//  Created by よういち on 2023/10/11.
//  Copyright © 2023 WEB BANANA UNITE Tokyo-Yokohama LPC. All rights reserved.
//

#if os(macOS) || os(iOS)
import Foundation
import SwiftUI
import MapKit
import blocks

struct Map: UIViewRepresentable {
    let center: CLLocationCoordinate2D
    let map = MKMapView()
    let quadKey: QuadKey
    
    func makeCoordinator() -> QuadKey {
        self.quadKey
    }

    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<Map>) {
    }
    
    func makeUIView(context: UIViewRepresentableContext<Map>) -> MKMapView {
        let region = MKCoordinateRegion(center: self.center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        map.region = region
        let longPressed = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.longPressedAction(_:)))
        map.addGestureRecognizer(longPressed)
        return map
    }
}
#endif
