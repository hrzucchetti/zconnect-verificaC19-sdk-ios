/*
 *  license-start
 *
 *  Copyright (C) 2021 Ministero della Salute and all other contributors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

//
//  PickerView.swift
//  VerificaC19
//
//  Created by Johnny Bueti on 18/10/21.
//

import Foundation
import UIKit

class PickerViewController: UIViewController {
    
    @IBOutlet weak var pickerView:          UIView!
    @IBOutlet weak var pickerViewComponent: UIPickerView!
    @IBOutlet weak var itemDone:            UIBarButtonItem!
    @IBOutlet weak var itemCancel:          UIBarButtonItem!
    
    private lazy var content: PickerContent = .init(doneButtonTitle: "Done", cancelButtonTitle: "Cancel", pickerOptions: [])
    
    public struct PickerContent {
        var doneButtonTitle:    String
        var cancelButtonTitle:  String
        var pickerOptions:      [String]
        var selectedOption:     Int = 0
        var doneCallback:       ((PickerViewController) -> ())? = nil
        var cancelCallback:     (() -> ())? = nil
    }
    
    public static func present(for sender: UIViewController, with content: PickerContent) {
        let vc                      = PickerViewController(content: content)
        vc.modalPresentationStyle   = .overFullScreen
        sender.present(vc, animated: false, completion: nil)
    }
    
    init(content: PickerContent) {
        super.init(nibName: "PickerViewController", bundle: nil)
        self.content = content
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fillView(with: self.content)
        animatePresentingPicker()
    }
    
    private func fillView(with content: PickerContent) {
        self.initialize()
        
        self.itemDone.title     = content.doneButtonTitle
        self.itemCancel.title   = content.cancelButtonTitle
    }
    
    private func initialize() {
        self.pickerViewComponent.showsSelectionIndicator    = true
        self.pickerViewComponent.delegate                   = self
        self.pickerViewComponent.dataSource                 = self
        
        self.itemDone.action                                = #selector(self.didTapDone)
        self.itemCancel.action                              = #selector(self.didTapCancel)
        
        self.selectRow(self.content.selectedOption, animated: false)
    }
    
    public func selectRow(_ row: Int, animated: Bool) {
        self.pickerViewComponent.selectRow(row, inComponent: 0, animated: animated)
    }
    
    public func selectedRow() -> Int {
        return self.pickerViewComponent.selectedRow(inComponent: 0)
    }

    @objc private func didTapDone() {
        self.dismissPicker(completionHandler: nil)
        self.content.doneCallback?(self)
    }
    
    @objc private func didTapCancel() {
        self.dismissPicker(completionHandler: nil)
        self.content.cancelCallback?()
    }
}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.content.pickerOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.content.pickerOptions.count
        } else {
            return 0
        }
    }
}

extension PickerViewController {
    private func animatePresentingPicker() {
        animate(willAppear: false)
            
        UIView.animate (
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: .curveEaseIn,
            animations: { [weak self] in self?.animate(willAppear: true) })
        }
        
    private func dismissPicker(completionHandler: (()->())? = nil) {
        UIView.animate (
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: .curveEaseIn,
            animations: { [weak self] in self?.animate(willAppear: false) }
        ) { [weak self] _ in self?.dismiss(animated: false, completion: completionHandler) }
    }
    
    private func animate(willAppear: Bool) {
        self.pickerView.alpha = willAppear ? 1 : 0
        self.pickerView.backgroundColor = willAppear ? .white : .clear
        self.pickerView.transform = willAppear ? .identity : .init(scaleX: 0.85, y: 0.85)
        
        let alpha: CGFloat = willAppear ? 0.8 : 0
        view.backgroundColor = Palette.black.withAlphaComponent(alpha)
    }
}
