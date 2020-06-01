//
//  AppDelegate.swift
//  VisilabsIOS
//
//  Created by egemen@visilabs.com on 03/30/2020.
//  Copyright (c) 2020 egemen@visilabs.com. All rights reserved.
//

import Eureka

enum RowType {
    case textRow
    case urlRow
    case pickerInputRow
    case switchRow
    case buttonRow
}

class FormRow <Element> {
    var rowType: RowType
    var tag: String
    var title: String?
    var placeholder: String?
    var options: [Element]?
    var value: Element?
    var rules = [BaseRuleType]()
    init(rowType: RowType, tag: String, title: String?, placeholder: String?, options: [Element]?, value: Element?){
        self.rowType = rowType
        self.tag = tag
        self.title = title
        self.placeholder = placeholder
        self.options = options
        self.value = value
    }
}

class FormSection {
    var header: String?
    var formRows: [FormRow<Any>]
    init(header: String?, formRows: [FormRow<Any>]){
        self.header = header
        self.formRows = formRows
    }
    
}



class FormHelper{

    func createForm(_ formSections: [FormSection]) -> Form {
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        let form = Form()
        
        for formSection in formSections{
            let section = Section(formSection.header)
            
            for formRow in formSection.formRows {
                var baseRow: BaseRow?
                if formRow.rowType == .textRow {
                    baseRow = TextRow(formRow.tag) { (row) in
                        row.placeholder = formRow.placeholder
                        row.value = formRow.value as? String
                    }
                }
                if formRow.rowType == .urlRow {
                    baseRow = URLRow(formRow.tag) { (row) in
                        row.placeholder = formRow.placeholder
                        row.value = formRow.value as? URL
                    }
                }
                
                baseRow?.title = formRow.title
                section.append(baseRow!)
                
            
            
                
            }
            form.append(section)
            
        }
        
        
        return form
        
    }
}

