//
//  tableCell.swift
//  weatherApp
//
//  Created by dato on 2/7/21.
//

import UIKit
import SDWebImage

class tableCell: UITableViewCell {

    
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet var weatherImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func conf(with model: list){
       
        
        self.temperature.text = String(model.main.temp) + "°C"
        
        self.weather.textColor = .white
        self.temperature.textColor = .white
        
        
        let imageURL =  "https://openweathermap.org/img/wn/" + model.weather[0].icon + "@2x.png"
        
        guard let downloadURL = URL(string: imageURL) else { return }
        
        weatherImage.sd_setImage(with: downloadURL, placeholderImage: UIImage(named: "data_load_error.png"))
        
        let date = NSDate(timeIntervalSince1970: TimeInterval(model.dt))
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date as Date)
        let hour = comp.hour ?? 0
        let minute = comp.minute
        
        let second = String(hour - 1) + ":" + String(minute!) + "0"
        
        self.weather.numberOfLines = 2
        
        self.weather.text =  second  + "\n" + model.weather[0].description

        
        let buttonText: NSString = model.weather[0].description + "\n" + second as NSString

        //getting the range to separate the button title strings
        let newlineRange: NSRange = buttonText.range(of: "\n")
        //getting both substrings
        var substring1 = ""
        var substring2 = ""
        if(newlineRange.location != NSNotFound) {
            substring1 = buttonText.substring(to: newlineRange.location)
            substring2 = buttonText.substring(from: newlineRange.location)
        }
        //assigning diffrent fonts to both substrings
        let font1: UIFont = UIFont(name: "Arial", size: 28.0)!
        let attributes1 = [NSMutableAttributedString.Key.font: font1]
        let attrString1 = NSMutableAttributedString(string: substring1, attributes: attributes1)
        let font2: UIFont = UIFont(name: "Arial", size: 12.0)!
        let attributes2 = [NSMutableAttributedString.Key.font: font2]
        let attrString2 = NSMutableAttributedString(string: substring2, attributes: attributes2)
        //appending both attributed strings
        attrString1.append(attrString2)
        //assigning the resultant attributed strings to the button
        
        //self.weather.setAttributedTitle(attrString1, for: [])
 
    
    }
    
}
