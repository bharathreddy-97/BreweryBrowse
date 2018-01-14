//
//  BeerDetailController.swift
//  BreweryBrowse
//
//  Created by Next on 14/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import UIKit
import CoreData

class BeerDetailController: UIViewController {

    @IBOutlet weak var mFoodPairingsLabel: UILabel!
    @IBOutlet weak var mBeerCategory: UILabel!
    @IBOutlet weak var mBeerImage:UIImageView!
    @IBOutlet weak var mBeerName:UILabel!
    @IBOutlet weak var mBeerDescription:UILabel!
    @IBOutlet weak var mBeerFoodPairings:UILabel!
    @IBOutlet weak var mRelatedBeerCollectionView: UICollectionView!
    
    private var listOfRelatedBeers:[Beer] = []
    
    var beerData:Beer?
    let persistenceContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Details"
    }
    
    private func setUpData(){
        guard let beerData = beerData else {return}
        setBeerImage()
        mBeerName.text = beerData.nameDisplay
        mBeerCategory.text = (beerData.style?.category?.name) ?? ""
        fetchCategoryBeers()
        setBeerDescription()
        setFoodPairings()
    }
    
    //fetching Related Beers
    private func fetchCategoryBeers(){
        if let categoryName = beerData!.style?.category?.name{
            let predicate = NSPredicate(format: "style.category.name == %@", categoryName)
            let fetchRequest = NSFetchRequest<Beer>(entityName: "Beer")
            fetchRequest.predicate = predicate
            fetchRequest.fetchLimit = 6
            
            if let beerObjects = try? persistenceContainer.viewContext.fetch(fetchRequest){
                listOfRelatedBeers = []
                for beer in beerObjects{
                    if beer != beerData!{
                        listOfRelatedBeers.append(beer)
                    }
                }
                mRelatedBeerCollectionView.delegate = self
                mRelatedBeerCollectionView.dataSource = self
                mRelatedBeerCollectionView.reloadData()
            }
        }
        else{
            
        }
    }
    private func setBeerImage(){
        guard let images = beerData!.images else {
            mBeerImage.image = #imageLiteral(resourceName: "beerHolder")
            return
        }
        if let largeImage = images.largeImage,let url = URL.init(string: largeImage){
            mBeerImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "beerHolder"), options: [], completed: nil)
        }
        else if let mediumImage = images.mediumImage, let url = URL.init(string: mediumImage){
            mBeerImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "beerHolder"), options: [], completed: nil)
        }
        else{
            mBeerImage.image = #imageLiteral(resourceName: "beerHolder")
        }
    }
    
    
    private func setBeerDescription(){
        let attributableString = NSMutableAttributedString(string: "Description \n\n", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15, weight: .semibold),NSAttributedStringKey.foregroundColor:UIColor.black])
        if beerData!.beerDescription == nil || beerData!.beerDescription! == ""{
            attributableString.append(NSAttributedString.init(string: "-"))
        }
        else{
            let attributedString = NSAttributedString(string: beerData!.beerDescription!, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 13),NSAttributedStringKey.foregroundColor:UIColor.black])
            attributableString.append(attributedString)
        }
        mBeerDescription.attributedText = attributableString
    }
    
    private func setFoodPairings(){
        guard let foodPairings = beerData!.foodPairings else{
            mFoodPairingsLabel.text = ""
            mBeerFoodPairings.text = ""
            mFoodPairingsLabel.isHidden = true
            mBeerFoodPairings.isHidden = true
            return
        }
        mBeerFoodPairings.text = foodPairings
    }
}

//MARK: extension for handling UICollectionViewDelegate and UICollectionViewDataSource methods
extension BeerDetailController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "relatedBeerCell", for: indexPath) as! RelatedBeerCell
        cell.beerData = listOfRelatedBeers[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let beerData = listOfRelatedBeers[indexPath.row]
        self.beerData = beerData
        setUpData()
    }
    
}


