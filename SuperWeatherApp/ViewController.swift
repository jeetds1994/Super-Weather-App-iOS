//
//  ViewController.swift
//  SuperWeatherApp
//
//  Created by DJ on 10/5/17.
//  Copyright © 2017 DJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var searchCityLabel: UITextField!
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var directionSegment: UISegmentedControl!
    @IBOutlet weak var distanceLabel: UILabel!
    var locationData: [AnyObject?]!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var slider: Double = 0.0
    
    var segmentIndex = 0
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        
        pageControl.currentPage = Int(pageNumber)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchRequest(city: "New York")
    }
    
    
    func fetchRequest(city: String){
        let updatedCity = city.replacingOccurrences(of: " ", with: "+")
        print(updatedCity)
        let session = URLSession.shared
        let url = URL(string: "https://api.aerisapi.com/places/search?query=name:\(updatedCity),country:us&limit=10&client_id=OotpWAGbWVCd6dsDPxkbG&client_secret=YIBo2h6KDfURQdrs83NYZAIvKgcj0YyGrEnRBgYp")!
        let task = session.dataTask(with: url) { (data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                let resp = json!["response"] as! [AnyObject]
                
                print(json)

                if resp.count != 0 {
                    
                    //getting data out of json
                    let info = resp[0] as! [String: AnyObject]
                    let place = info["place"] as! NSDictionary
                    let name = place["name"] as? String
                    let updatedName = name?.replacingOccurrences(of: " ", with: "+")
                    let state = place["state"] as? String
                    
                    let cord = info["loc"] as! [String: Double]
                    print(cord)
                    var lat = cord["lat"] as! Double
                    var long = cord["long"] as! Double
                    
                    
                    // Fixes bug stating UILabel must be updated in main queue.
                    DispatchQueue.main.async() {self.locationLabel.text = name}
                    print(updatedName)
                    if self.slider == 0.0 {
                        self.fetchWeatherData(cityName: updatedName!, state: state!)
                    }else{
                        self.generateNewCord(lat: &lat, long: &long)
                        print("long is \(long)")
                        print("lat is \(lat)")
                        self.fetchCityWithLatLong(lat: lat, long: long)
                    }
                    
                }
                
            }
        }
        task.resume()
    }
    
    func generateNewCord(lat: inout Double, long: inout Double){

        switch self.segmentIndex{
        //North
            case 0:
                lat = lat + Double(self.slider) > 180 ? 180 : lat + Double(self.slider)
        //East
            case 1:
                long = long - Double(self.slider) < -180 ? -180 : long - Double(self.slider)
        //South
            case 2:
                lat = lat - Double(self.slider) < -180 ? -180 : lat - Double(self.slider)
        //West
            case 3:
                long = long + Double(self.slider) > 180 ? 180 : long + Double(self.slider)
            default:
                print("default")
        }
    }
    
    func fetchWeatherData(cityName: String, state: String){
        let session = URLSession.shared
        let url2 = URL(string: "https://api.aerisapi.com/forecasts/\(cityName),\(state)?client_id=OotpWAGbWVCd6dsDPxkbG&client_secret=YIBo2h6KDfURQdrs83NYZAIvKgcj0YyGrEnRBgYp")!
        let task2 = session.dataTask(with: url2) { (data2, response2, error2) -> Void in
            if let data2 = data2 {
                let json2 = try? JSONSerialization.jsonObject(with: data2, options: []) as! [String: AnyObject]
                let resp2 = json2!["response"] as! [AnyObject]
                let info2 = resp2[0] as! [String: AnyObject]
                //                        let periods = info2["periods"] as! [NSDictionary]]
                self.locationData = info2["periods"]! as! [AnyObject?]
                print(self.locationData.count)
                DispatchQueue.main.async() {
                    for index in 0..<7{
                        //set frame for scrollable
                        self.frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
                        self.frame.size = self.scrollView.frame.size
                        
                        let view = UIView(frame: self.frame)
                        
                        //set date
                        let dayOfTheWeek = UILabel(frame: self.dayLabel.frame)
                        var date = self.locationData[index]!["validTime"] as! String
                        dayOfTheWeek.text = date
                        view.addSubview(dayOfTheWeek)
                        
                        //set high
                        let highOfTheDay = UILabel(frame: self.highLabel.frame)
                        var highTemp = self.locationData[index]!["maxTempF"] as! Double
                        highOfTheDay.text = "High: \(highTemp)"
                        view.addSubview(highOfTheDay)
                        
                        //set low
                        let lowOfTheDay = UILabel(frame: self.lowLabel.frame)
                        var lowTemp = self.locationData[index]!["minTempF"] as! Double
                        lowOfTheDay.text = "Low: \(lowTemp)"
                        view.addSubview(lowOfTheDay)
                        
                        
                        //set feels like
                        let feelOfTheDay = UILabel(frame: self.feelsLikeLabel.frame)
                        var feelTemp = self.locationData[index]!["feelslikeF"] as! Double
                        feelOfTheDay.text = "Feels Like: \(feelTemp)"
                        view.addSubview(feelOfTheDay)
                        
                        //set weather icon
                        let icon = self.locationData[index]!["icon"] as! String
                        let weatherImage = UIImageView(frame: self.weatherIcon.frame)
                        weatherImage.image = UIImage(named: icon)
                        view.addSubview(weatherImage)
                        
                        
                        self.scrollView.addSubview(view)
                        self.scrollView.contentSize = CGSize(width: (self.scrollView.frame.size.width * CGFloat(7)), height: (self.scrollView.frame.size.height))
                        self.scrollView.delegate = self
                        
                    }
                }
            }
        }
        task2.resume()
    }
    
    func fetchCityWithLatLong(lat: Double, long: Double){
        
        let updatedLat = String(format: "%.1f", lat)
        let updatedLong = String(format: "%.1f", long)
        let session = URLSession.shared
        let url = URL(string: "https://api.aerisapi.com/places/closest?p=\(updatedLat),\(updatedLong)&client_id=OotpWAGbWVCd6dsDPxkbG&client_secret=YIBo2h6KDfURQdrs83NYZAIvKgcj0YyGrEnRBgYp")!
        let task = session.dataTask(with: url) { (data, response, error) -> Void in
            print(response)
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                let resp = json!["response"] as! [AnyObject]
                if resp.count != 0 {
                    let info = resp[0] as! [String: AnyObject]
                
                }else{
                    print("no good")

                }
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pageControl(_ sender: UIPageControl) {
        
        let x = CGFloat(sender.currentPage) * scrollView.frame.size.width
        scrollView.contentOffset = CGPoint(x: x, y: 0)
    }
    
    @IBAction func onSubmit(_ sender: Any) {

        fetchRequest(city: searchCityLabel.text!)

    }
    @IBAction func distanceSlider(_ sender: UISlider) {
        distanceLabel.text = "Distance from Current Position \(sender.value)"
        slider = Double(sender.value)
    }
    
    @IBAction func changingSegment(_ sender: UISegmentedControl) {
        self.segmentIndex = sender.selectedSegmentIndex
    }
    
}

