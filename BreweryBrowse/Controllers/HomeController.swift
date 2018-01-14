//
//  ViewController.swift
//  BreweryBrowse
//
//  Created by Next on 29/12/17.
//  Copyright © 2017 Next. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class HomeController: UIViewController {
    
    @IBOutlet weak var mNoInternetLabel: UILabel!
    @IBOutlet weak var mNoNetworkImage: UIImageView!
    @IBOutlet weak var mErrorLabel: UILabel!
    @IBOutlet weak var mActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mTableView: UITableView!
    private var filterOrSortButton:UIBarButtonItem!
    private var isLoading = false{
        didSet{
            if isLoading{
                mTableView.alpha = 0.3
                mActivityIndicator.startAnimating()
                view.isUserInteractionEnabled = false
            }
            else{
                mTableView.alpha = 1
                mActivityIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
            }
        }
    }
    private var fetchingDataFromWeb = false
    
    var listOfBeerObjects = [Beer]()
    //sortable objects
    lazy var alphabeticalSort = Sort(withName: "Alphabetical", propertyNameInCoreData: "nameDisplay", ascending: true)
    lazy var createDateSort = Sort(withName: "Date of creation", propertyNameInCoreData: "createDate", ascending: true)
    lazy var bitternessSort = Sort(withName: "Bitterness", propertyNameInCoreData: "bitterness", ascending: true)
    
    //filterable objects
    lazy var filterableOrganicNature = OrganicNature()
    lazy var filterableBitternessNature = Bitterness()
    lazy var filterableCategories = FilterableCategories()
    
    //selected Sort parameter. Default is Alphabetical Sort
    var sortedParameter:Sort = Sort(withName: "Alphabetical", propertyNameInCoreData: "nameDisplay", ascending: true){
        didSet{
            switch sortedParameter {
            case alphabeticalSort:
                alphabeticalSort = sortedParameter
                resetSortData([createDateSort,bitternessSort])
            case createDateSort:
                createDateSort = sortedParameter
                resetSortData([alphabeticalSort,bitternessSort])
            case bitternessSort:
                bitternessSort = sortedParameter
                resetSortData([alphabeticalSort,createDateSort])
            default:
                break
            }
        }
    }
    private var pageNo = 1
    var filteredData:[Filterable]?
    let persistenceContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    let beerEntityName = "Beer"
    private var currentNoOfBeerObjectsInStore = 0
    private var selectedIndexPath:IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        persistenceContainer.viewContext.automaticallyMergesChangesFromParent = true
        alphabeticalSort.isSelected = true
        setUpViews()
        let fetchRequest = NSFetchRequest<Beer>(entityName: beerEntityName)
        if let count = try? persistenceContainer.viewContext.count(for: fetchRequest){
            currentNoOfBeerObjectsInStore = count
        }
        makeNetworkCallIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Home"
    }
    
    private func setUpViews(){
        mTableView.delegate = self
        mTableView.dataSource = self
        if let navigationBar = navigationController?.navigationBar{
            removeNavigationBarShadow(fromView: navigationBar)?.isHidden = true
        }
        filterOrSortButton = UIBarButtonItem(image: #imageLiteral(resourceName: "FilterIcon"), style: .plain, target: self, action: #selector(filterOrSortList))
        navigationItem.rightBarButtonItem = filterOrSortButton
    }
    
    //Pushing SortOrFilter controller
    @objc private func filterOrSortList(){
        performSegue(withIdentifier: "sortFilterController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sortFilterController"{
            let sortOrFilterController = segue.destination as! SortOrFilterController
            sortOrFilterController.delegate = self
            sortOrFilterController.sortCells = [alphabeticalSort,createDateSort,bitternessSort]
            sortOrFilterController.filterCells = [filterableOrganicNature,filterableBitternessNature,filterableCategories]
        }
        else if segue.identifier == "beerDetail"{
            let beerDetailController = segue.destination as! BeerDetailController
            beerDetailController.beerData = listOfBeerObjects[selectedIndexPath.row]
        }
    }
    
    //To remove the shadow of the navigation bar
    private func removeNavigationBarShadow(fromView view:UIView)->UIImageView?{
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = removeNavigationBarShadow(fromView: subview) {
                return imageView
            }
        }
        return nil
    }
    
    //Resetting sort Data to default values
    private func resetSortData(_ sortData:[Sort]){
        for sort in sortData{
            sort.isSelected = false
            sort.isAscending = true
        }
    }
    
    //Fetching beer data from coredata if available, if not, making a webcall and fetching it afterwards
    private func makeNetworkCallIfNeeded(){
        let context = persistenceContainer.viewContext
        guard let sortDescriptor = getSortDescriptor(sortedParameter) else {return}
        let fetchRequest = NSFetchRequest<Beer>.init(entityName: self.beerEntityName)
        if let beerList = try? context.fetch(fetchRequest){
            if beerList.count > 0{
                fetchBeerList(offsetBy: 0, withSortDescriptors: sortDescriptor, withPredicate: nil, withLimit: Constants.DEFAULT_LOAD_ITEMS, completion: { (beerObjects) in
                    self.loadBeerObjects(beerObjects: beerObjects)
                    self.fetchCategories()
                })
                return
            }else{
                if Reachability.isConnectedToNetwork(){
                    getBeerDataFromWeb(pageNo: pageNo, abvNo: Constants.ABV_NO){
                        self.fetchBeerList(offsetBy: 0, withSortDescriptors: sortDescriptor, withPredicate: nil, withLimit: Constants.DEFAULT_LOAD_ITEMS, completion: { (beerObjects) in
                            self.loadBeerObjects(beerObjects: beerObjects)
                            self.fetchCategories()
                        })
                        
                    }
                }
                else{
                    mTableView.isHidden = true
                    mNoNetworkImage.isHidden = false
                    mNoInternetLabel.isHidden = false
                }
                
            }
            
        }
        
    }
    
    private func fetchCategories(){
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        if let categoryObjects = try? persistenceContainer.viewContext.fetch(fetchRequest){
            for category in categoryObjects{
                if filterableCategories.categories == nil{
                    filterableCategories.categories = [(category,false)]
                }
                else{
                    if !(filterableCategories.categories!.contains(where: { (categoryData) -> Bool in
                        return categoryData.0.name == category.name
                    })){
                        filterableCategories.categories!.append((category,false))
                    }
                }
            }
        }
    }
    
    //Fetching more beer data incase all the data is already shown
    private func fetchMoreBeerDataFomWebAndShow(withOffset offset:Int){
        if Reachability.isConnectedToNetwork(){
            if isLoading && fetchingDataFromWeb{
                pageNo += 1
                if let sortDescriptor = getSortDescriptor(sortedParameter){
                    var filterPredicate:NSPredicate?
                    if let filterData = filteredData{
                        filterPredicate = getFilterPredicates(filterData)
                    }
                    getBeerDataFromWeb(pageNo: pageNo, abvNo: Constants.ABV_NO, completion: {
                        self.fetchingDataFromWeb = false
                        self.fetchBeerList(offsetBy: offset, withSortDescriptors: sortDescriptor, withPredicate: filterPredicate, withLimit: Constants.DEFAULT_LOAD_ITEMS, completion: { (beerObjects) in
                            self.isLoading = false
                            self.loadBeerObjects(beerObjects: beerObjects)
                        })
                    })
                }
            }
        }
        else{
            mTableView.isHidden = true
            mNoNetworkImage.isHidden = false
            mNoInternetLabel.isHidden = false
        }
        
    }
    
    private func loadBeerObjects(beerObjects:[Beer]?){
        guard let beerObjects = beerObjects else {return}
        if beerObjects.count > 0{
            self.listOfBeerObjects += beerObjects
            self.mTableView.reloadData()
        }
    }
    
    private func handleErrorAppropriately(message:String){
        mTableView.isHidden = true
        mErrorLabel.text = "Error while fetching the data"
        let alertController = UIAlertController.init(title: "Error", message: "Error while fetching the data", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: TableView Delegate and DataSource Methods
extension HomeController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeerListCell", for: indexPath) as! BeerListCell
        cell.selectionStyle = .none
        let beerModel = listOfBeerObjects[indexPath.row]
        cell.beerModel = beerModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfBeerObjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "beerDetail", sender: nil)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        if listOfBeerObjects.count > 0 && contentOffset + mTableView.bounds.height >= mTableView.contentSize.height && !isLoading{
            isLoading = true
            guard let sortDescriptor = getSortDescriptor(sortedParameter) else {
                isLoading = false
                return
            }
            var filterPredicate:NSPredicate? = nil
            if let filterData = filteredData{
                filterPredicate = getFilterPredicates(filterData)
            }
            if currentNoOfBeerObjectsInStore == listOfBeerObjects.count{
                fetchingDataFromWeb = true
                fetchMoreBeerDataFomWebAndShow(withOffset: listOfBeerObjects.count)
                return
            }
            self.fetchBeerList(offsetBy: listOfBeerObjects.count, withSortDescriptors: sortDescriptor, withPredicate: filterPredicate, withLimit: Constants.DEFAULT_LOAD_ITEMS, completion: { (beerObjects) in
                self.isLoading = false
                self.loadBeerObjects(beerObjects: beerObjects)
            })
        }
    }
}

//MARK: Extension to parse data into objects and store them
extension HomeController:Parsable{
    private func getBeerDataFromWeb(pageNo:Int,abvNo:Int,completion: @escaping ()->()){
        NetworkManager.sharedInstance.getData(fromURL: Constants.URLConstants.fetchBeerList.replacingOccurrences(of: "{abvNo}", with: "\(abvNo)").replacingOccurrences(of: "{pageNO}", with: "\(pageNo)"), HTTPMethod.get, URLEncoding.default) { (data, error) in
            
            guard let data = data else{
                if let _ = error{
                    self.handleErrorAppropriately(message: "")
                }
                return
            }
            self.parseData(from: data){
                completion()
            }
        }
    }
    
    private func fetchBeerList(offsetBy offset:Int,withSortDescriptors descriptors:NSSortDescriptor,withPredicate predicate:NSPredicate?,withLimit limit:Int,completion:@escaping ([Beer]?)->()){
        let fetchRequest = NSFetchRequest<Beer>.init(entityName: self.beerEntityName)
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = offset
        fetchRequest.sortDescriptors = [descriptors]
        fetchRequest.predicate = predicate
        let beerObjects = try! self.persistenceContainer.viewContext.fetch(fetchRequest)
        completion(beerObjects)
    }
    
    //Parsing Data into Beer Objects and storing them to store
    func parseData(from data: Data,completion: @escaping ()->()) {
        if let jsonObject = try! JSONSerialization.jsonObject(with: data) as? [String:Any],let beerObjects = jsonObject["data"] as? [Any]{
            let jsonDecoder = JSONDecoder()
            //let backgroundContext = persistenceContainer.newBackgroundContext()
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            persistenceContainer.performBackgroundTask({ (context) in
                jsonDecoder.userInfo[CodingUserInfoKey.context!] = context
                
                for beerObject in beerObjects{
                    if let data = try? JSONSerialization.data(withJSONObject: beerObject), let _ = try? jsonDecoder.decode(Beer.self, from: data){
                        context.performAndWait {
                            do{
                                try context.save()
                            }
                            catch{
                                self.handleErrorAppropriately(message: "")
                            }
                        }
                    }
                    else{
                        self.handleErrorAppropriately(message: "")
                    }
                }
                self.currentNoOfBeerObjectsInStore += beerObjects.count
                dispatchGroup.leave()
            })
            dispatchGroup.notify(queue: .main, work: DispatchWorkItem.init(block: {
                DispatchQueue.main.async {
                    completion()
                }
            }))
        }
    }
}


//MARK: Extension implementing SortFilterProtocol and support methods for fetching sort descriptors and filter predicates
extension HomeController:SortFilterProtocol{
    
    func sortAndFilter(sortedParameter: Sort, filteredData: [Filterable]?) {
        listOfBeerObjects = []
        self.sortedParameter = sortedParameter
        self.filteredData = filteredData
        guard let descriptor = getSortDescriptor(sortedParameter) else {return}
        var filterPredicate:NSPredicate?
        if let filterData = filteredData{
            filterPredicate = getFilterPredicates(filterData)
            for filterObject in filterData{
                if filterObject is OrganicNature{
                    self.filterableOrganicNature = filterObject as! OrganicNature
                }
                else if filterObject is Bitterness{
                    self.filterableBitternessNature = filterObject as! Bitterness
                }
                else if filterObject is FilterableCategories{
                    self.filterableCategories = filterObject as! FilterableCategories
                }
            }
        }
        fetchBeerList(offsetBy: 0, withSortDescriptors: descriptor, withPredicate: filterPredicate, withLimit: Constants.DEFAULT_LOAD_ITEMS) { (beerList) in
            self.loadBeerObjects(beerObjects: beerList)
        }
    }
    
    //Getting Sort Descriptors for the beer fetch
    private func getSortDescriptor(_ sortParameter:Sort)->NSSortDescriptor?{
        
        var sortDescriptor:NSSortDescriptor! = NSSortDescriptor()
        switch sortParameter{
        case alphabeticalSort:
            sortDescriptor = NSSortDescriptor(key: sortParameter.propertyNameInCoreData, ascending: sortParameter.isAscending)
        case createDateSort:
            sortDescriptor = NSSortDescriptor(key: sortParameter.propertyNameInCoreData, ascending: sortParameter.isAscending)
        case bitternessSort:
            sortDescriptor = NSSortDescriptor(key: sortParameter.propertyNameInCoreData, ascending: sortParameter.isAscending)
        default:
            return nil
        }
        return sortDescriptor
    }
    
    //Getting predicates for the beer fetch
    private func getFilterPredicates(_ filterableDataArray:[Filterable])->NSPredicate?{
        var predicateString = ""
        var parameters:[Any] = []
        for filterData in filterableDataArray{
            if filterData is OrganicNature{
                let organicData = filterData as! OrganicNature
                if organicData.isSelected{
                    predicateString += "organic == %@"
                    parameters.append(organicData.organicNature ? "Y" : "N")
                }
            }
            else if filterData is Bitterness{
                let bitternessData = filterData as! Bitterness
                if bitternessData.isSelected{
                    if predicateString == ""{
                        predicateString = "bitterness <= %d AND bitterness >= %d"
                    }
                    else{
                        predicateString += " AND bitterness <= %d AND bitterness >= %d"
                    }
                    
                    parameters.append(bitternessData.upperLimit!)
                    parameters.append(bitternessData.lowerLimit!)
                }
            }
            else if filterData is FilterableCategories{
                let categoryData = filterData as! FilterableCategories
                if let categories = categoryData.categories{
                    var atleastOneisSelected = false
                    for category in categories{
                        if category.1{
                            atleastOneisSelected = true
                            break
                        }
                    }
                    if atleastOneisSelected{
                        if predicateString == ""{
                            predicateString = "("
                        }
                        else{
                            predicateString += " AND ("
                        }
                        var formatString = ""
                        for category in categories{
                            let name = category.0.name
                            let isSelected = category.1
                            if isSelected{
                                if formatString != ""{
                                    formatString += " || "
                                }
                                formatString += "style.category.name == %@"
                                parameters.append(name ?? "")
                            }
                        }
                        predicateString += formatString + ")"
                    }
                }
            }
        }
        return predicateString == "" ? nil : NSPredicate(format: predicateString, argumentArray: parameters)
    }
}

