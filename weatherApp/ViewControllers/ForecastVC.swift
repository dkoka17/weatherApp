//
//  ForecastVC.swift
//  weatherApp
//
//  Created by dato on 1/27/21.
//

import UIKit


class ForecastVC: UIViewController{
   
    
    
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet var errorView: UIView!
    var refresher: UIRefreshControl!
    
    private let service = Service()
    var weatherMassive = [list]()
    
    var startHor: Int = 0
    
    var cityName:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ForecastVC.refresh(_:)), for: .valueChanged)
        table.addSubview(refresher)
        
        table.delegate = self
        table.dataSource = self
        
        table.frame = table.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        table.register(UINib(nibName: "tableCell", bundle: nil), forCellReuseIdentifier: "tableCell")
        errorView.isHidden = true
        table.isHidden = true
        
        loadWeather()
        
    }
    
    private func loadWeather() {
        table.isHidden = true
        loader.startAnimating()
        service.loadFiveDayWeatherByCity(for: CurrentCity) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                switch result {
                case .success(let FiveDayWeather):
                    self.weatherMassive = FiveDayWeather.list
                    self.table.isHidden = false
                    self.table.reloadData()
                case .failure(let error):
                    self.errorView.isHidden = false
                    self.view.addSubview(self.errorView)
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                      self.errorView.transform = .identity
                    })
                }
            }
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        errorView.isHidden = true
        loader.startAnimating()
        refresher.endRefreshing()
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        loadWeather()
    }

}



extension ForecastVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        if weatherMassive.count > 0 {
            
            let date = NSDate(timeIntervalSince1970: TimeInterval(weatherMassive[0].dt))
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.hour], from: date as Date)
            let hour = comp.hour ?? 0
            
            startHor = hour - 1
            if hour - 1 == 0 {
                return 5
            }
            
            return 6
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "bg-gradient-end")
        
        if weatherMassive.count == 0 {
            return label
        }
        
        var date :NSDate
        if section == 5 {
            date = NSDate(timeIntervalSince1970: TimeInterval(weatherMassive[weatherMassive.count-1].dt))
        } else {
            date = NSDate(timeIntervalSince1970: TimeInterval(weatherMassive[section*8].dt))
        }
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.weekday, ], from: date as Date) 
        let dateFormat = DateFormatter()
        let weekday = comp.weekday ?? 0
        let day = dateFormat.weekdaySymbols[weekday - 1]
        label.text = day
        label.textColor = UIColor(named: "accent")
        
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weatherMassive.count == 0 {
            return 0
        }
        if section == 0 {
            return (24 - startHor) / 3
        } else if section == 5 {
            return 8 - (24 - startHor) / 3
        } else {
            return weatherMassive.count/5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var ind = indexPath.row
        if indexPath.section > 0 {
            ind = ind + (24 - startHor) / 3
            if indexPath.section > 1 {
                ind = ind + 8 * (indexPath.section - 1)
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        if let tableCell = cell as? tableCell {
            tableCell.conf(with: weatherMassive[ind])
        }
        return cell
    }
    
}
