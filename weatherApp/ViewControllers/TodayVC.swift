//
//  TodayVC.swift
//  weatherApp
//
//  Created by dato on 1/27/21.
//

import UIKit
import CoreLocation
import UPCarouselFlowLayout

public var CurrentCity: String = ""

class TodayVC: UIViewController,CLLocationManagerDelegate,UICollectionViewDelegate, UICollectionViewDataSource, collectionCellDelegate  {
    

    private var locationManager:CLLocationManager?
    @IBOutlet weak var days: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var weatherCollection: UICollectionView!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var addCityButton: UIButton!
    
    @IBOutlet var addView: UIView!
    @IBOutlet var cityName: UITextField!
    @IBOutlet var addViewButton: UIButton!
    
    @IBOutlet var errorView: UIView!
    
    @IBOutlet var errorOnAdding: UIView!
    
    var weatherMassive = [Weather]()
    private let service = Service()
    public var LocationCity: String = ""
    
    var isPort: Bool = true
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
        
        
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
        
        addView.isHidden = true
        addView.clipsToBounds = true
        addView.layer.cornerRadius = 10
        errorOnAdding.clipsToBounds = true
        errorOnAdding.layer.cornerRadius = 10
        errorView.isHidden = true
        errorOnAdding.isHidden = true
        days.isHidden = true
        pageControl.isHidden = true
        //addCityButton.isHidden = true
        loader.startAnimating()
        
        weatherCollection.register(UINib.init(nibName: "collectionCell", bundle: nil), forCellWithReuseIdentifier: "collectionCell")
        
        let layout = UPCarouselFlowLayout()
        print(weatherCollection.frame.size.height)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 60, height: 650)
        //layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 60, height: 200)
        layout.scrollDirection = .horizontal
        layout.spacingMode = .fixed(spacing: 5.0)
        layout.sideItemScale = 0.8
        layout.sideItemAlpha = 1.0
        
        
        weatherCollection.collectionViewLayout = layout
       
        weatherCollection.delegate = self
        weatherCollection.dataSource = self
        
        
        updateInfo()
        
        
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        /*
         
         ლოქეიშენი როდესაც არ აჩვენებს, ბოლო ქალაქი მაინც იხსება, უფრო იუზერ-ფრენდლად ჩავთვალე
         
            ადგილმდებარეობის შეცვლისას, თუ ინტერნეტთან კავშირი დაკარგა, ჯობს არ შევიმჩნიოთ და უკვე ჩატვირთული ინფო დავუტოვოთ
        */
        
        if let location = locations.last{
            
            let coorde = coord(lon: location.coordinate.longitude, lat: location.coordinate.latitude)

            service.loadTodayWeatherByCoordinats(for: coorde) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let Weather):
                        print(Weather.name)
                        if self?.LocationCity != Weather.name {
                            CurrentCity = Weather.name
                            self?.LocationCity = Weather.name
                            self?.updateInfo()
                        }
                    case .failure(_):
                        
                        return
                        
                    }
                }
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        isPort = !UIDevice.current.orientation.isLandscape
      
        if weatherMassive.count == 0 {
            return
        }
        
        if isPort {
            let layout = UPCarouselFlowLayout()
            //layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 60, height: weatherCollection.frame.size.height)
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 60, height: 650)
            layout.scrollDirection = .horizontal
            layout.spacingMode = .fixed(spacing: 5.0)
            layout.sideItemScale = 0.8
            layout.sideItemAlpha = 1.0
            
            weatherCollection.collectionViewLayout = layout
            weatherCollection.reloadData()
        } else {
            
            let layout = UPCarouselFlowLayout()
            layout.itemSize = CGSize(width: weatherCollection.frame.size.width-100, height: 350)
            
            layout.scrollDirection = .horizontal
            layout.spacingMode = .fixed(spacing: 5.0)
            layout.sideItemScale = 0.8
            layout.sideItemAlpha = 1.0
            
            weatherCollection.collectionViewLayout = layout
            weatherCollection.reloadData()
         
        }
 
    }
   
    
    private func updateInfo(){
        days.isHidden = true
        pageControl.isHidden = true
       // addCityButton.isHidden = true
        
        weatherMassive.removeAll()
        let savedArray = UserDefaults.standard.object(forKey: "SavedCitys") as? [String] ?? [String]()
        if LocationCity != "" && !savedArray.contains(LocationCity){
            loader.startAnimating()
            loadWeather(city: self.LocationCity)
        }
        for city in savedArray{
            loader.startAnimating()
            loadWeather(city: city)
        }
        
    }
    
    private func loadWeather(city: String) {
        
        service.loadTodayWeatherByCity(for: city) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                switch result {
                case .success(let Weather):
                    self.weatherMassive.append(Weather)
                    self.weatherCollection.reloadData()
                case .failure(let error):
                    self.loader.stopAnimating()
                    self.errorView.isHidden = false
                    self.view.addSubview(self.errorView)
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                      self.errorView.transform = .identity
                    })
                }
            }
        }
    }
    
    func removeCity(_ sended: collectionCell) {
        let alert = UIAlertController(
            title: "Remove City",
            message: "Remove City",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertAction.Style.default, handler: { [unowned self](_) in
            
            
            if weatherMassive.count == 0 {
                return
            }
            var savedArray = UserDefaults.standard.object(forKey: "SavedCitys") as? [String] ?? [String]()
            
            if !savedArray.contains(self.weatherMassive[currentPage2].name){
                return
            }
            
            savedArray = savedArray.filter { $0 != self.weatherMassive[currentPage2].name}
            UserDefaults.standard.set(savedArray, forKey: "SavedCitys")
            if weatherMassive.count > 0 {
                CurrentCity = self.weatherMassive[0].name
            } else {
                CurrentCity = ""
            }
            updateInfo()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addCityInBase(_ sender: Any) {
        let text: String = self.cityName.text ?? ""
        let savedArray = UserDefaults.standard.object(forKey: "SavedCitys") as? [String] ?? [String]()
        if savedArray.contains(text) {
            self.addView.isHidden = true
            self.errorOnAdding.isHidden = true
            for subview in self.view.subviews {
                if subview is UIVisualEffectView {
                    subview.removeFromSuperview()
                }
            }
            return
        }
        self.addViewButton.loadingIndicator(true)
        service.loadTodayWeatherByCity(for: text) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let Weather):
                    self.addViewButton.loadingIndicator(false)
                    let defaults = UserDefaults.standard
                    var savedArray = defaults.object(forKey: "SavedCitys") as? [String] ?? [String]()
                    savedArray.append(Weather.name)
                    defaults.set(savedArray, forKey: "SavedCitys")
                    
                    self.addView.isHidden = true
                    self.errorOnAdding.isHidden = true
                    for subview in self.view.subviews {
                        if subview is UIVisualEffectView {
                            subview.removeFromSuperview()
                        }
                    }
                    self.updateInfo()
                    self.addViewButton.loadingIndicator(false)
                    
                case .failure(_):
                    self.addViewButton.loadingIndicator(false)
                    self.errorOnAdding.isHidden = false
                    self.view.addSubview(self.errorOnAdding)
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                      self.errorOnAdding.transform = .identity
                    })
                }
            }
        }
    }
    
 
    
    @IBAction func addCity(_ sender: Any) {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        
        
        errorOnAdding.isHidden = true
        addView.isHidden = false
        addView.center = view.center
        addView.alpha = 1
        addView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)

         self.view.addSubview(addView)
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            self.addView.transform = .identity
         })
        
        
    }
    
    @objc func keyboardWillChange(notification: Notification) {
       
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        if notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillChangeFrameNotification{
            view.frame.origin.y = -keyboardFrame.cgRectValue.height / 2
        } else {
            view.frame.origin.y = 0
        }
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        addView.isHidden = true
        errorView.isHidden = true
        errorOnAdding.isHidden = true
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        updateInfo()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view == errorOnAdding {
            errorOnAdding.isHidden = true
        } else if touch?.view != addView {
            addView.isHidden = true
            errorOnAdding.isHidden = true
            for subview in self.view.subviews {
                if subview is UIVisualEffectView {
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = weatherMassive.count
        pageControl.numberOfPages = count
        pageControl.isHidden = !(count > 1)
        //addCityButton.isHidden = false
        self.days.isHidden = false
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = weatherCollection.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        if let collectionCell = cell as? collectionCell {
            collectionCell.conf(with: weatherMassive[indexPath.row])
            collectionCell.delegate = self
            if CurrentCity == "" {
                CurrentCity = self.weatherMassive[indexPath.row].name
            }
            if isPort {
                //ჩვეულებრიბი
                collectionCell.makePortrait()
            } else {
                collectionCell.makeLandScape()
            }
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.weatherCollection.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage2 = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }

    fileprivate var currentPage2: Int = 0 {
        didSet {
            pageControl.currentPage = currentPage2
            CurrentCity = self.weatherMassive[self.currentPage2].name
        }
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.weatherCollection.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
}




extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            self.alpha = 0.5
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}
