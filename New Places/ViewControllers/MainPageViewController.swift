//
//  ViewController.swift
//  New Places
//
//  Created by Егор Янкович on 19.09.21.
//

import UIKit

class MainPageViewController: UIViewController {
    
    //MARK:-   IBVariables
    @IBOutlet weak var placeCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    //MARK:- Private Variables
    private var placeCollection: [Places]?
    private var categoryCollection: [Categoies]?
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeCollectionView.delegate = self
        self.placeCollectionView.dataSource = self
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        placeCollection = setupCollection()
        categoryCollection = setupCategoriesCollection()
    }
    
    //MARK:- IBAction methods
    @IBAction func showFilter(_ sender: Any) {
        presentSecondViewController()
    }
    
    //MARK:- Private methods
    private func setupCollection() -> [Places] {
        var tempArray = [Places]()
        let place1 = Places(image: UIImage(named: "place01")!, placeName: "Rahat Brasserie")
        let place2 = Places(image: UIImage(named: "bar")!, placeName: "Garage Bar")
        tempArray.append(place1)
        tempArray.append(place2)
        return tempArray
    }
    
    private func setupCategoriesCollection() -> [Categoies] {
        var tempArray = [Categoies]()
        let category1 = Categoies(image: UIImage(named: "pizza")!, categoryLabel: "Pizza", placesLabel: "2350 places")
        let category2 = Categoies(image: UIImage(named: "hamburger")!, categoryLabel: "Burgers", placesLabel: "350 places")
        let category3 = Categoies(image: UIImage(named: "meat")!, categoryLabel: "Steak", placesLabel: "834 places")
        let category4 = Categoies(image: UIImage(named: "spaguetti")!, categoryLabel: "Pasta", placesLabel: "150 places")
        tempArray.append(category1)
        tempArray.append(category2)
        tempArray.append(category3)
        tempArray.append(category4)
        return tempArray
    }
    
    private func presentSecondViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "FilerViewController")
        secondVC.modalPresentationStyle = .overCurrentContext
        present(secondVC, animated: false, completion: nil)
    }
}

//MARK:- Extentions
extension MainPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = Int()
        if collectionView == self.placeCollectionView {
            count = placeCollection!.count
        } else if collectionView == self.categoryCollectionView {
            count = categoryCollection!.count
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellToReturn = UICollectionViewCell()
        
        if collectionView == placeCollectionView {
            let collection = placeCollection![indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlacesCollectionViewCell", for: indexPath) as! PlacesCollectionViewCell
            cell.placeImageView.image = collection.image
            cell.placeLabel.text = collection.placeName
            cellToReturn = cell
        } else {
            let collection = categoryCollection![indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollection", for: indexPath) as! CategoriesCollectionView
            cell.categoryLabel.text = collection.categoryLabel
            cell.categoryPlaces.text = collection.placesLabel
            cell.categotyImage.image = collection.image
            cellToReturn = cell
        }
        return cellToReturn
    }
}
