//
//  ViewController.swift
//  Project3
//
//  Created by Sophia Amin on 4/17/18.
//  Copyright © 2018 Sophia Amin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

final class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
    
    //zoom into a coordinate
    var region: MKCoordinateRegion{
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}


class ViewController: UIViewController, UITableViewDataSource {
    
    

    
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    var latlonString:String? = " "
    var latitude:Double = 0
    var longitude:Double = 0
    private var latlon: [String] = [] //array of the combined latlon strings
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = (self as UITableViewDataSource)
        
        
        let selectedCoordinate = CLLocationCoordinate2D(latitude: 42, longitude: -71)
        let selectedAnnotation = LocationAnnotation(coordinate: selectedCoordinate, title: "Location", subtitle: "Selected location")
        
        mapView.addAnnotation(selectedAnnotation)
        mapView.setRegion(selectedAnnotation.region, animated: true)
    
        tableView.dataSource = self

    }
    
    //MARK: Actions
    @IBAction func enterLatLonPressed(_ sender: UIButton) {
        //process the lat and lon
        latlonString = getLatLon() //string
        latitude = getLat()
        longitude = getLon()
        latlon.append(getLatLon()) //adds message to an array of strings, and prints 
        
        //make an entry into coredata
       setUpData(inputLatitude: String(latitude), inputLongitude: String(longitude))
        
        tableView.reloadData()
        //TODO: Find place on the map, load into core data
        showCoordinatesOnMap(lat: latitude, lon: longitude)
        
    }
    
    //MARK: TableView
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latlon.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! //1.
        
        let text = latlon[indexPath.row] //2.
        
        cell.textLabel?.text = text //3.
        
        return cell
        
    }
    
    
    //MARK: Functions
    //get the lat and lon and add them into a string
    func getLatLon() -> String{
     
        let latitude:String = latitudeTextField.text!
        let longitude:String = longitudeTextField.text!
        
        let message = "Latitude: \(latitude) Longitude: \(longitude)"
        print(message)
        return message
    }
    
    func getLat() -> Double{
        let latitude = Int(latitudeTextField.text!) ?? 0
        return Double(latitude)
    }
    
    func getLon() -> Double{
        let longitude = Int(longitudeTextField.text!) ?? 0
        return Double(longitude)
    }
    
    //MARK: FIND LOCATION
    func showCoordinatesOnMap(lat: Double, lon: Double){
    
    mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    let selectedCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    let selectedAnnotation = LocationAnnotation(coordinate: selectedCoordinate, title: "Location", subtitle: "Selected location")
    
    mapView.addAnnotation(selectedAnnotation)
    mapView.setRegion(selectedAnnotation.region, animated: true)
    }
    
    
    //MARK: COREDATA

    func setUpData(inputLatitude:String, inputLongitude: String){
        
        //1.  Similar to Create Database and Create SQL Table named CarData
        // let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let coorinateContext = appDelegate.persistentContainer.viewContext
        let coorinateEntity  = NSEntityDescription.entity(forEntityName:"Coordinate", in: coorinateContext)
        
        //2.  Similar to INSERT INTO CarData(color, price, type) VALUES ( any, any, any)
        let newCoorinate = NSManagedObject(entity: coorinateEntity!, insertInto: coorinateContext)
        
        //        newCar.setValue("White", forKey: "color")
        //        newCar.setValue("1000", forKey: "price")
        //        newCar.setValue("4D", forKey: "type")
        
        
        newCoorinate.setValue(inputLatitude, forKey: "latitude")
        newCoorinate.setValue(inputLongitude, forKey: "longitude")
       
        
        
        saveDate(contextSaveObject: coorinateContext)
        loadData(contextLoadObject: coorinateContext)
    }
    
    func saveDate(contextSaveObject: AnyObject){
        do{
            try contextSaveObject.save()
        }
        catch{
            print("Error Saving")
        }
    }
    
    func loadData(contextLoadObject: AnyObject){
        let myRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Coordinate")
        myRequest.returnsObjectsAsFaults = false
        
        //3.  important part of CoreData to use the VALUES in the database
        do{
            let result = try contextLoadObject.fetch(myRequest)
            for data in result as! [NSManagedObject]{
                
                let latitudeCoordinate = data.value(forKey: "latitude")  as! String // Must cast object to String (or Int if needed)
                let longitudeCoordinate = data.value(forKey: "longitude")  as! String
                
                
                print("Here is my info from Coredata: latitude \(latitudeCoordinate), longitude \(longitudeCoordinate)")
            }
        }
        catch{
            print("Error Loading")
        }
    }
    
}


//MARK: enxtensions
extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let locationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView{
            locationAnnotationView.animatesWhenAdded = true
            locationAnnotationView.titleVisibility = .adaptive
            locationAnnotationView.titleVisibility = .adaptive
            
            return locationAnnotationView
        }
        return nil
    }
}
