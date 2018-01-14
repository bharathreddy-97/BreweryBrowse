//
//  SortOrFilterController.swift
//  BreweryBrowse
//
//  Created by Next on 06/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import UIKit

//MARK: Helper protocol and Classes
//protocol to send sort and filter data back to Home controller
protocol SortFilterProtocol:class {
    func sortAndFilter(sortedParameter:Sort,filteredData:[Filterable]?)
}

//protocol implemented by classes which pass Filterable Data
protocol Filterable{
}

class OrganicNature: Filterable {
    var organicNature = true
    var isSelected = false
}

class Bitterness:Filterable{
    var lowerLimit:Int? = 0
    var upperLimit:Int? = 0
    var isSelected = false
}

class FilterableCategories: Filterable {
    var categories:[(Category,Bool)]?
}


//Class used to pass Sortable data
class Sort:Equatable{
    private(set) var name:String
    private(set) var propertyNameInCoreData:String
    var isAscending:Bool
    var isSelected = false
    
    init(withName parametername:String,propertyNameInCoreData propertyName:String,ascending:Bool) {
        name = parametername
        propertyNameInCoreData = propertyName
        isAscending = ascending
    }
    
    static func ==(lhs: Sort, rhs: Sort) -> Bool {
        return lhs.name == rhs.name
    }
}

//MARK: Sort & Filter Controller. Used to display the sortable, filterable data.
class SortOrFilterController: UIViewController {

    @IBOutlet weak var mTableView: UITableView!
    weak var delegate:SortFilterProtocol?
    
    var sortCells:[Sort] = []
    var filterCells:[Filterable] = []
    
    
    private var sections:[sectionType] = [.sort,.filter]
    private var doneBarButton:UIBarButtonItem!
    private enum sectionType:String{
        case sort = "Sort"
        case filter = "Filter"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mTableView.estimatedRowHeight = 60
        mTableView.rowHeight = UITableViewAutomaticDimension
        mTableView.delegate = self
        mTableView.dataSource = self
        mTableView.reloadData()
        
        doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClicked))
        navigationItem.rightBarButtonItem = doneBarButton
        //adding Observers for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyBoardWillShow(_ notification:NSNotification){
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let height = keyboardFrame.size.height
        let cell = mTableView.cellForRow(at: IndexPath.init(row: 1, section: 1))
        if cell!.frame.intersects(keyboardFrame){
            mTableView.contentOffset.y += height
        }
    }
    
    @objc private func keyBoardWillHide(_ notification:NSNotification){
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let height = keyboardFrame.size.height
        let cell = mTableView.cellForRow(at: IndexPath.init(row: 1, section: 1))
        if cell!.frame.intersects(keyboardFrame){
            mTableView.contentOffset.y -= height
        }
    }
    
    @objc private func doneClicked(){
        var sortedParameter:Sort!
        for sort in sortCells{
            if sort.isSelected{
                sortedParameter = sort
            }
        }
        for filterCell in filterCells{
            if filterCell is Bitterness{
                let bitternessCell  = filterCell as! Bitterness
                if let lowerLimit = bitternessCell.lowerLimit, let upperLimit = bitternessCell.upperLimit{
                    if lowerLimit > upperLimit{
                        let alert = UIAlertController.init(title: "Error", message: "Lower limit must be smaller than upper limit", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                        })
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }else if lowerLimit == 0 && upperLimit == 0{
                        bitternessCell.isSelected = false
                    }
                    else{
                        bitternessCell.isSelected = true
                    }
                }
                
            }
        }
        delegate?.sortAndFilter(sortedParameter: sortedParameter, filteredData: self.filterCells)
        navigationController?.popViewController(animated: true)
    }
}

//MARK: TableView Delegate and DataSource methods
extension SortOrFilterController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sections[indexPath.section] == .sort{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sortTypeCell", for: indexPath) as! SortByOrderCell
            let sortData = sortCells[indexPath.row]
            cell.setData(titleName: sortData.name, parameterName: "Ascending", isAscending: sortData.isAscending)
            cell.sortData = sortData
            if sortData.isSelected{
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
            return cell
        }
        else if sections[indexPath.section] == .filter{
            switch indexPath.row{
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "sortTypeCell", for: indexPath) as! SortByOrderCell
                let filterData = filterCells[0] as! OrganicNature
                cell.setData(titleName: "Organic Nature", parameterName: "isOrganic", isAscending: filterData.organicNature)
                cell.organicData = filterData
                if filterData.isSelected{
                    cell.accessoryType = .checkmark
                }
                else{
                    cell.accessoryType = .none
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "lowerAndUpperLimitCell", for: indexPath) as! FilterByLimitsCell
                let filterData = filterCells[1] as! Bitterness
                cell.bitternessModel = filterData
                cell.mFilterTitle.text = "Bitterness"
                cell.mLowerLimit.text = "\(filterData.lowerLimit ?? 0)"
                cell.mUpperLimit.text = "\(filterData.upperLimit ?? 0)"
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "collectionTypeCell", for: indexPath) as! FilterByCategories
                let categoryCell = filterCells[2] as! FilterableCategories
                cell.filterData = categoryCell
                return cell
            default:
                return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].rawValue
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section] == .sort{
            return sortCells.count
        }
        else if sections[section] == .filter{
            return filterCells.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sections[indexPath.section] == .sort{
            let selectedSortParameter = sortCells[indexPath.row]
            for sort in sortCells{
                if sort == selectedSortParameter{
                    sort.isSelected = true
                }
                else{
                    sort.isSelected = false
                }
            }
            tableView.reloadData()
        }
        else if sections[indexPath.section] == .filter{
            let selectedcell = filterCells[indexPath.row]
            if selectedcell is OrganicNature{
                let organicCell = selectedcell as! OrganicNature
                organicCell.isSelected = !organicCell.isSelected
                mTableView.reloadData()
            }
            else if selectedcell is Bitterness{
                return
            }
            else{
                return
            }
        }
    }
}
