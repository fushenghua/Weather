//
//  ViewController.swift
//  Weather
//
//  Created by fushenghua on 15/9/7.
//  Copyright © 2015年 fushenghua. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var weatherDesc: UILabel!
    @IBOutlet weak var loadding: UIActivityIndicatorView!
    @IBOutlet weak var imgWeather: UIImageView!
   
    @IBOutlet weak var tempLable: UILabel!
    @IBOutlet weak var cityLable: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
  

    private let locationManager=CLLocationManager();
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate=self;
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        var backgroundName:String="weather_bg.jpeg";
        
        let background=UIImage(named:backgroundName);
        self.view.backgroundColor=UIColor(patternImage: background!);
        locationManager.requestAlwaysAuthorization();
        locationManager.startUpdatingLocation();
        loadding.startAnimating();
        
    }
    
    //networking
    
    func updateWaterInfo(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
    let key="3fd9b57d51de42f2a257a1974fca5fa2";
    let url="http://apis.haoservice.com/weather/geo";
        let params=["lat":"\(latitude)","lon":"\(longitude)","key":key];
        print("params:\(params)");
        
        
         let  afManager = AFHTTPRequestOperationManager()
         let op=afManager.GET(url, parameters: params, success: { (operation:AFHTTPRequestOperation!, responseObject:AnyObject!) -> Void in

            let data:NSData=responseObject as!NSData;
            print(data.objectFromJSONData() as! NSDictionary);
            self.updateUISuccess(data);
            
            }) { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                self.cityLable.text="网络请求失败";
            
        }
            op.responseSerializer=AFHTTPResponseSerializer();
            op.start();
       
    }
    
    func updateUISuccess(data:NSData){
        self.loadding.stopAnimating();
        self.loadding.hidden=true;
        var maps=data.objectFromJSONData() as!NSDictionary;
        
        if maps["error_code"] as! Int != 10001{
            
            if let result=maps["result"]{
                var sk:NSDictionary=result["sk"] as! NSDictionary;
                if let temp:String=sk["temp"] as! String{
                    self.tempLable.text="\(temp)°";
                }
                var time:String=sk["time"] as! String;
                self.updateTimeLabel.text="更新时间:\(time)";
            
                
                if let today:NSDictionary=result["today"] as? NSDictionary{
                    let city:String = today["city"] as! String;
                    let weather:String = today["weather"] as! String;
                    
                    var fa:String = today["fa"] as! String;
                    self.cityLable.text=city;
                    self.weatherDesc.text=weather;
                     upadteWeatherIcon(fa);
                }
                
               
               
                
//
                
                
            }
            
            
        
        }else{
        self.cityLable.text="定位失败";
        
        }
        
        
    
    }
    
    
    func upadteWeatherIcon(fb:String){
        var imgName:String;
        switch fb{
        case "00":
           imgName="sunny.png";
            break
            
        case "01":
             imgName="tstorm1.png";
            break
            
        case "02":
             imgName="sunny.png";
            break
        default:
             imgName="snow5.png";
            break
        
        }
         imgWeather.image=UIImage(named: imgName);
    }
    
    
   //CLLocationManager Delegate
   
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count-1];
        if location.horizontalAccuracy>0{
            self.locationManager.stopUpdatingLocation();
            print("location:\(location.coordinate)");
            updateWaterInfo(location.coordinate.latitude, longitude: location.coordinate.longitude);
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("定位失败");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        locationManager.stopUpdatingLocation();
    }
    
    
    enum MyError:ErrorType{
        case JSONERROR
    }
    


}

