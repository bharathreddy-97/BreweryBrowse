//
//  FilterByCategories.swift
//  BreweryBrowse
//
//  Created by Next on 07/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import UIKit

class FilterByCategories: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var mCollectionViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var mCollectionView:UICollectionView!
    private var categoryData:[(Category,Bool)] = []
    var filterData:FilterableCategories? = nil{
        didSet{
            guard let filterData = filterData else {return}
            if let categories =  filterData.categories{
                categoryData = categories
                mCollectionView.delegate = self
                mCollectionView.dataSource = self
                mCollectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoriesCell
        cell.categoryData = categoryData[indexPath.row]
        if filterData!.categories![indexPath.row].1{
            cell.backgroundColor = UIColor.init(red: 25/255, green: 133/255, blue: 255/255, alpha: 1)
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = categoryData.count
        mCollectionViewHeightContraint.constant = CGFloat(count) * 30
        mCollectionView.layoutIfNeeded()
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width/2) - 10, height: 30)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterData!.categories![indexPath.row].1 = !(filterData!.categories![indexPath.row].1)
        mCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
