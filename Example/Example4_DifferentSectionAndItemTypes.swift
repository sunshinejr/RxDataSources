//
//  MultipleSectionModelViewController.swift
//  RxDataSources
//
//  Created by Segii Shulga on 4/26/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

// the trick is to just use enum for different section types
class MultipleSectionModelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    let dataSource = RxTableViewSectionedAnimatedDataSource<MultipleSectionModel>()
    let sections = PublishSubject<[MultipleSectionModel]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        skinTableViewDataSource(dataSource)
        
        sections
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        sections.onNext([
            .ImageProvidableSection(title: "Section 1",
                items: [.ImageSectionItem(image: UIImage(named: "settings")!, title: "General")]),
            .ToggleableSection(title: "Section 2",
                items: [.ToggleableSectionItem(title: "On", enabled: true)]),
            .StepperableSection(title: "Section 3",
                items: [.StepperSectionItem(title: "1")])
            ])
        
        performSelector(#selector(test), withObject: nil, afterDelay: 2.0)
    }
    
    func test() {
        sections.onNext([
            .ImageProvidableSection(title: "Section 1",
                items: []),
            .ToggleableSection(title: "Section 2",
                items: [.ToggleableSectionItem(title: "On", enabled: true)]),
            .StepperableSection(title: "Section 3",
                items: [.StepperSectionItem(title: "1")])
            ])
    }
    
    func skinTableViewDataSource(dataSource: RxTableViewSectionedAnimatedDataSource<MultipleSectionModel>) {
        dataSource.configureCell = { (dataSource, table, idxPath, _) in
            switch dataSource.itemAtIndexPath(idxPath) {
            case let .ImageSectionItem(image, title):
                let cell: ImageTitleTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.titleLabel.text = title
                cell.cellImageView.image = image
                
                return cell
            case let .StepperSectionItem(title):
                let cell: TitleSteperTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.titleLabel.text = title
                
                return cell
            case let .ToggleableSectionItem(title, enabled):
                let cell: TitleSwitchTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.switchControl.on = enabled
                cell.titleLabel.text = title
                
                return cell
            }
        }

        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource.sectionAtIndex(index)
            
            return section.title
        }
    }
}

enum MultipleSectionModel {
    case ImageProvidableSection(title: String, items: [SectionItem])
    case ToggleableSection(title: String, items: [SectionItem])
    case StepperableSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case ImageSectionItem(image: UIImage, title: String)
    case ToggleableSectionItem(title: String, enabled: Bool)
    case StepperSectionItem(title: String)
}

extension SectionItem: IdentifiableType, Equatable {
    var identity: String {
        return "\(self)"
    }
}

func ==(lhs: SectionItem, rhs: SectionItem) -> Bool {
    switch (lhs, rhs) {
    case (.ImageSectionItem, .ImageSectionItem): return true
    case (.ToggleableSectionItem, .ToggleableSectionItem): return true
    case (.StepperSectionItem, .StepperSectionItem): return true
    default: return false
    }
}

extension MultipleSectionModel: AnimatableSectionModelType {
    typealias Item = SectionItem
    typealias Identity = String
    
    var items: [SectionItem] {
        switch  self {
        case .ImageProvidableSection(title: _, items: let items):
            return items.map {$0}
        case .StepperableSection(title: _, items: let items):
            return items.map {$0}
        case .ToggleableSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: MultipleSectionModel, items: [Item]) {
        self = original
    }
    
    var identity: String {
        return title
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .ImageProvidableSection(title: let title, items: _):
            return title
        case .StepperableSection(title: let title, items: _):
            return title
        case .ToggleableSection(title: let title, items: _):
            return title
        }
    }
}
