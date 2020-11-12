//
//  RecordButton.swift
//  Maskif.ai
//
//  Created by Matthew Shu on 11/10/20.
//

import UIKit

protocol RecordButtonDelegate: AnyObject {
    func recordButtonTapped(_ button: RecordButton)
}

class RecordButton: UIButton {
    weak var delegate: RecordButtonDelegate?
    open override var isSelected: Bool {
        didSet {
            tintColor = isSelected ? .systemRed : .systemGray
        }
    }
    
    init() {
        super.init(frame: .zero)
        setUpButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
    }
    
    func setUpButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .bold, scale: .large)
        let notRecordingImage = UIImage(systemName: "record.circle", withConfiguration: largeConfig)
        let isRecordingImage = UIImage(systemName: "record.circle.fill", withConfiguration: largeConfig)
        setImage(notRecordingImage, for: .normal)
        setImage(isRecordingImage, for: .selected)
        tintColor = isSelected ? .systemRed : .systemGray
        addTarget(self, action: #selector(setSelected), for: .touchUpInside)
    }
  
    @objc func setSelected() {
        isSelected = !isSelected
        delegate?.recordButtonTapped(self)
        
    }
}
