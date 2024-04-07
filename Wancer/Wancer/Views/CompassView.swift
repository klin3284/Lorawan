////
////  CompassView.swift
////  Wancer
////
////  Created by Kenny Lin on 4/7/24.
////
//
//import SwiftUI
//import CoreLocation
//
//struct CompassView: View {
//    @EnvironmentObject var locationManager: LocationManager
//    @State private var heading: Double = 0.0
//    
//    var body: some View {
//        VStack {
//            Text("Heading: \(heading.formatted(.number.precision(.fractionLength(2))))°")
//            
//            ZStack {
//                Circle()
//                    .stroke(Color.gray, lineWidth: 2)
//                    .frame(width: 200, height: 200)
//                
//                PointerView(heading: $heading)
//                
//                Circle()
//                    .fill(Color.blue)
//                    .frame(width: 10, height: 10)
//                    .offset(y: -90)
//                
//                Text("N")
//                    .foregroundColor(.black)
//                    .font(.caption)
//                    .offset(y: -100)
//            }
//        }
//        .onReceive(locationManager.$currentHeading) { newHeading in
//            heading = newHeading?.trueHeading ?? 0
//        }
//    }
//}
//
//struct PointerView: View {
//    @Binding var heading: Double
//    
//    var body: some View {
//        Rectangle()
//            .fill(Color.red)
//            .frame(width: 4, height: 40)
//            .offset(y: -70)
//            .rotationEffect(Angle(degrees: heading))
//    }
//}
