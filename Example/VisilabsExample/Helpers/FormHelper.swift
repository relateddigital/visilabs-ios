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
    case colorRow
}

class FormRow {
    var rowType: RowType
    var rowValueType: Any.Type
    var tag: String
    var title: String?
    var placeholder: String?
    var options: [Any]
    var value: Any?
    var rules = [BaseRuleType]()
    init(rowType: RowType, rowValueType: Any.Type, tag: String,
         title: String?, placeholder: String? = nil, options: [Any] = [],
         value: Any? = nil, rules: [BaseRuleType]? = nil) {
        self.rowType = rowType
        self.rowValueType = rowValueType
        self.tag = tag
        self.title = title
        self.placeholder = placeholder
        self.options = options
        self.value = value
        if let rls = rules {
            self.rules = rls
        }
    }
}

class FormSection {
    var header: String?
    var sectionRows: [FormRow]
    init(_ header: String?, _ sectionRows: [FormRow]) {
        self.header = header
        self.sectionRows = sectionRows
    }

}

class FormHelper {

    func createForm(_ formSections: [FormSection]) -> Form {
        LabelRow.defaultCellUpdate = { cell, _ in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }

        let form = Form()

        for formSection in formSections {
            let section = Section(formSection.header)

            for formRow in formSection.sectionRows {
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
                if formRow.rowType == .pickerInputRow {
                    if formRow.rowValueType == String.self {
                        baseRow = PickerInputRow<String>(formRow.tag) { (row) in
                            row.value = formRow.value as? String
                            for option in formRow.options {
                                if let opt = option as? String {
                                    row.options.append(opt)
                                }
                            }
                        }
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
