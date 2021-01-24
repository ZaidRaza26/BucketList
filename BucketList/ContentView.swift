//
//  ContentView.swift
//  BucketList
//
//  Created by Zaid Raza on 03/12/2020.
//  Copyright © 2020 Zaid Raza. All rights reserved.
//

import SwiftUI
import LocalAuthentication
import MapKit

struct ContentView: View {
    
    enum AlertCases {
        case placesAlert, biometricAlert
    }
    
    @State private var activeAlert = AlertCases.placesAlert
    
    @State private var loadingState = LoadingState.loading
    
    @State private var isUnlocked = false
    @State private var showingEditScreen = false
    @State private var showingPlaceDetails = false
    
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [CodableMKPointAnnotation]()
    
    @State private var selectedPlace: MKPointAnnotation?
    
    @State var tempTitle = ""
    
    var body: some View {
        
        ZStack{
            //if isUnlocked {
                
                MapView(centerCoordinate: $centerCoordinate, selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, annotations: locations)
                    
                    .edgesIgnoringSafeArea(.all)
                
                Circle()
                    .fill(Color.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
                
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            let newLocation = CodableMKPointAnnotation()
                            newLocation.coordinate = self.centerCoordinate
                            newLocation.title = "Example Location"
                            self.locations.append(newLocation)
                            self.selectedPlace = newLocation
                            self.showingEditScreen = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .foregroundColor(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                    }
                }
          //  }
//            else {
//                //button here
//                Button("Unlock Places") {
//                    self.authenticate()
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .clipShape(Capsule())
//            }
        }
        .onAppear(perform: loadData)
        .alert(isPresented: $showingPlaceDetails){
            
            switch activeAlert{
            case .placesAlert:
                return Alert(title: Text(selectedPlace?.title ?? "Unknown"), message: Text(selectedPlace?.subtitle ?? "Missing Place Information"), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                    self.showingEditScreen = true
                    })
            case .biometricAlert:
                return
                    Alert(title: Text("Authentication Erorr"), message: Text("Please try again"), dismissButton: .default(Text("OK")))
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData){
            if  self.selectedPlace != nil{
                EditView(placemark: self.selectedPlace!)
            }
        }
    }
    
    enum LoadingState {
        case loading, success , failed
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func authenticate(){
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "Please authenticate yourself to unlock your places"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){ success, authenticateError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    }
                    else{
                        //error
                        self.activeAlert = .biometricAlert
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
    
    func loadData(){
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
        
        do{
            let data = try Data(contentsOf: filename)
            
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        }
        catch {
            print("unable to load saved data")
        }
    }
    
    func saveData(){
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        }
            
        catch {
            print("Unable to write data")
        }
    }
}



struct LoadingView: View {
    var body: some View {
        Text("Loading...")
    }
}

struct SuccessView: View {
    var body: some View {
        Text("Success!")
    }
}

struct FailedView: View {
    var body: some View {
        Text("Failed.")
    }
}

struct User: Identifiable, Comparable {
    let id = UUID()
    let firstName: String
    let lastName: String
    
    static func < (lhs: User, rhs: User) -> Bool{
        lhs.lastName < rhs.lastName
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
