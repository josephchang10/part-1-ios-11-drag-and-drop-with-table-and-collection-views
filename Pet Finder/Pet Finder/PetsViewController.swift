//
//  PetsViewController.swift
//  Pet Finder
//
//  Created by 张嘉夫 on 2017/6/9.
//  Copyright © 2017年 张嘉夫. All rights reserved.
//

import UIKit
import Pets

class PetsViewController: UIViewController {
  
  @IBOutlet weak var petsTableView: UITableView!
  @IBOutlet weak var adoptedTableView: UITableView!

  let petsDataSource = PetsDataSource(pets:
    [Pet(name: "小麦", type: "金毛", image: UIImage(named: "pet0")),
     Pet(name: "阿默", type: "混血梗犬", image: UIImage(named: "pet1")),
     Pet(name: "卤煮", type: "胆小的", image: UIImage(named: "pet2")),
     Pet(name: "老虎", type: "敏感的胡须", image: UIImage(named: "pet3")),
     Pet(name: "年年", type: "老鼠捕手", image: UIImage(named: "pet4")),
     Pet(name: "七喜", type: "边牧", image: UIImage(named: "pet5")),
     Pet(name: "佑佑", type: "杂交", image: UIImage(named: "pet6"))])
  let adoptedDataSource = PetsDataSource(pets: [])

  override func viewDidLoad() {
    super.viewDidLoad()

    for tableView in [petsTableView, adoptedTableView] {
      if let tableView = tableView {
        tableView.dataSource = dataSourceForTableView(tableView)
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.reloadData()
      }
    }

  }

  func dataSourceForTableView(_ tableView: UITableView) -> PetsDataSource {
    if (tableView == petsTableView) {
      return petsDataSource
    } else {
      return adoptedDataSource
    }
  }

}

extension PetsViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dataSource = dataSourceForTableView(tableView)
        return dataSource.dragItems(for: indexPath)
    }
}

extension PetsViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return Pet.canHandle(session)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(dropOperation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(dropOperation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
        let dataSource = dataSourceForTableView(tableView)
        
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        for item in coordinator.items {
            
            // Item 来自同一个 App，同一个 table view
            if let sourceIndexPath = item.sourceIndexPath {
                print("同一个 App - 同一个 tableview")
                dataSource.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                    tableView.endUpdates()
                }
            }
            
            // TODO: Item 来自同一个 App，不同的 table view
            else if let pet = item.dragItem.localObject as? Pet {
                print("同一个 App - 不同的 tableview")
                dataSource.addPet(pet, at: destinationIndexPath.row)
                DispatchQueue.main.async {
                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                }
            }
            
            // Item 来自不同的 App
            else {
                print("不同的 App")
                
                let context = coordinator.drop(item.dragItem, toPlaceholderInsertedAt: destinationIndexPath, withReuseIdentifier: "PetCell", rowHeight: 110, cellUpdateHandler: { (cell) in
                    cell.textLabel?.text = "加载中..."
                })
                
                let itemProvider = item.dragItem.itemProvider
                itemProvider.loadObject(ofClass: NSString.self, completionHandler: { (string, error) in
                    if let string = string as? String {
                        let pet = Pet(name: string, type: "Unknown", image: nil)
                        DispatchQueue.main.async {
                            context.commitInsertion(dataSourceUpdates: { (indexPath) in
                                dataSource.addPet(pet, at: destinationIndexPath.row)
                            })
                        }
                    }
                })
            }
        }
        
    }
}
