//
//  collectionCell.swift
//  weatherApp
//
//  Created by dato on 2/7/21.
//

import UIKit

protocol collectionCellDelegate: AnyObject {
    func removeCity(_ sended: collectionCell)
}
class collectionCell: UICollectionViewCell {

    @IBOutlet var image: UIImageView!
    @IBOutlet var cityCountry: UILabel!
    @IBOutlet var temperature: UILabel!
    
    @IBOutlet var Cloudiness: UILabel!
    @IBOutlet var Cloudiness2: UILabel!
    @IBOutlet var Humidity: UILabel!
    @IBOutlet var Humidity2: UILabel!
    @IBOutlet var WindSpeed: UILabel!
    @IBOutlet var WindSpeed2: UILabel!
    @IBOutlet var WindDirection: UILabel!
    @IBOutlet var WindDirection2: UILabel!
    
    
    @IBOutlet var A: UIView!
    @IBOutlet var B: UIView!
    
    var landscape:[NSLayoutConstraint]?
    var portrait:[NSLayoutConstraint]?
    
    weak var delegate: collectionCellDelegate?{
        didSet{
            
        }
    }
    
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        addGestureRecognizer(longPress)
        
        
        var colors = [UIColor]()
        colors.append(UIColor(named: "green-gradient-start")!)
        colors.append(UIColor(named: "ochre-gradient-end")!)
        colors.append(UIColor(named: "ochre-gradient-start")!)
        colors.append(UIColor(named: "green-gradient-end")!)
        colors.append(UIColor(named: "blue-gradient-start")!)
        colors.append(UIColor(named: "blue-gradient-end")!)
        
        self.backgroundColor = colors[Int.random(in: 0...5)]
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 25
        self.contentView.layer.cornerRadius = 25
        constraitnts()
       
       // self.Cloudiness.font
        
        self.cityCountry.textColor = .white
        self.temperature.textColor = UIColor(named: "accent")
        self.Cloudiness.textColor = UIColor(named: "accent")
        self.Cloudiness2.textColor = UIColor(named: "accent")
        self.Humidity.textColor = UIColor(named: "accent")
        self.Humidity2.textColor = UIColor(named: "accent")
        self.WindSpeed.textColor = UIColor(named: "accent")
        self.WindSpeed2.textColor = UIColor(named: "accent")
        self.WindDirection.textColor = UIColor(named: "accent")
        self.WindDirection2.textColor = UIColor(named: "accent")
    }

    public func conf(with model: Weather){
        
        self.cityCountry.text = String(model.name) + ", " + String(countryName(countryCode: model.sys.country) ?? "")
        self.temperature.text = String(model.main.temp) + "°C| " + String(model.weather[0].main)
        
        self.Cloudiness2.text = String(model.clouds.all) + " %"
        self.Humidity2.text = String(model.main.humidity) + " mm"
        self.WindSpeed2.text = String(model.wind.speed) + "km/h"
        self.WindDirection2.text = String(model.wind.deg) + "W"
        
    }
    
    public func makeLandScape(){
        NSLayoutConstraint.deactivate(portrait!)
        NSLayoutConstraint.activate(landscape!)
        
       
    }
    
    public func makePortrait(){
        NSLayoutConstraint.deactivate(landscape!)
        NSLayoutConstraint.activate(portrait!)
        
        
    }
    
    func constraitnts(){
        
        A.translatesAutoresizingMaskIntoConstraints = false
        B.translatesAutoresizingMaskIntoConstraints = false
        
        portrait = [
            
            A.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            B.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            //A.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            B.topAnchor.constraint(equalTo: A.bottomAnchor)
            
        ]
        
        landscape = [
            A.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        //    A.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            B.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            B.leftAnchor.constraint(equalTo: A.rightAnchor),
            A.rightAnchor.constraint(equalTo: B.leftAnchor),
            B.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 65),
            A.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
    }
    
    func countryName(countryCode: String) -> String? {
        let current = Locale(identifier: "en_US")
        return current.localizedString(forRegionCode: countryCode)
    }
    
    override var canBecomeFirstResponder: Bool {
        
        return true
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            delegate?.removeCity(self)
        }
    }
    
}



extension UIView {
    func callRecursively(level: Int = 0, _ body: (_ subview: UIView, _ level: Int) -> Void) {
        body(self, level)
        subviews.forEach { $0.callRecursively(level: level + 1, body) }
    }
}
