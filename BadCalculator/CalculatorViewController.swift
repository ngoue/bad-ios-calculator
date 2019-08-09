//
//  CalculatorViewController.swift
//  BadCalculator
//
//  Created by Jordan Gardner on 8/5/19.
//  Copyright © 2019 jordanthomasg. All rights reserved.
//

import UIKit

// Buttons are defined by ``.tag``.  0-9 are numbers, and 10+ are control buttons.
enum CalculatorControlButton: Int {
    case clear = 11,
    sign,
    percent,
    divide,
    multiply,
    subtract,
    add,
    equals
}

class CalculatorViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    var operand: CalculatorControlButton?
    var enteringNumber = false {
        didSet {
            if !oldValue && enteringNumber {
                self.clearButton.setTitle("C", for: .normal)
            }
        }
    }
    var numberText = "" {
        didSet {
            if let value = Double(numberText) {
                self.currentValue = value
            }
        }
    }
    var previousValue: Double = 0.0
    var currentValue: Double = 0.0 {
        didSet {
            self.updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        // Round buttons
        for button in self.buttons {
            let height = button.frame.size.height
            button.layer.cornerRadius = height / 2.0
            // Adjust insets of "0" button
            if button.tag == 0 {
                button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (height*30.0/78.0), bottom: 0.0, right: 0.0)
            }
        }
    }
    
    func updateViews() {
        // Update label text
        var value = self.currentValue
        var decimalSuffix = false
        if self.enteringNumber {
            decimalSuffix = (self.numberText.suffix(1) == ".")
            if let newValue = Double(self.numberText) {
                value = newValue
            }
        }
        // Format number nicely
        let fmt = NumberFormatter()
        fmt.usesGroupingSeparator = true
        fmt.numberStyle = self.format(for: value)
        fmt.maximumFractionDigits = 8
        fmt.exponentSymbol = "e"
        self.label.text = fmt.string(from: NSNumber(value: value))
        // Append decimal if necessary
        if decimalSuffix {
            self.label.text! += "."
        }
    }
    
    func format(for value: Double) -> NumberFormatter.Style {
        let upper = Double("1e9")!
        let lower = Double("1e-8")!
        if value != 0.0 && (abs(value) < lower || value >= upper) {
            return .scientific
        } else {
            return .decimal
        }
    }
    
    @IBAction func controlButtonPressed(_ sender: UIButton) {
        if let controlButton = CalculatorControlButton(rawValue: sender.tag) {
            switch controlButton {
            case .clear:
                self.enteringNumber = false
                self.numberText = "0"
                if self.clearButton.currentTitle == "C" {
                    self.clearButton.setTitle("AC", for: .normal)
                } else {
                    self.operand = nil
                    self.previousValue = 0.0
                }
            case .sign:
                if self.enteringNumber {
                    if self.numberText.prefix(1) == "-" {
                        self.numberText = self.numberText.replacingOccurrences(of: "-", with: "")
                    } else {
                        self.numberText = "-\(self.numberText)"
                    }
                } else {
                    self.currentValue *= 1
                }
            case .percent:
                if self.enteringNumber {
                    self.enteringNumber = false
                    self.currentValue = Double(self.numberText)!
                }
                self.currentValue /= 100.0
            case .add, .subtract, .multiply, .divide:
                if self.enteringNumber {
                    self.enteringNumber = false
                    if self.operand != nil {
                        let result = calculate(x: self.previousValue, y: self.currentValue)
                        self.previousValue = self.currentValue
                        self.currentValue = result
                    } else {
                        self.previousValue = Double(self.numberText)!
                    }
                }
                self.operand = controlButton
            case .equals:
                if self.operand != nil {
                    let result = calculate(x: self.previousValue, y: self.currentValue)
                    if self.enteringNumber {
                        self.previousValue = self.currentValue
                        self.enteringNumber = false
                    }
                    self.currentValue = result
                }
            }
        }
    }
    
    func calculate(x: Double, y: Double) -> Double {
        let operands: [CalculatorControlButton] = [.add, .subtract, .multiply, .divide]
        switch operands.randomElement()! {
        case .add:
            return x + y
        case .subtract:
            return x - y
        case .multiply:
            return x * y
        case .divide:
            return x / y
        default:
            return 0.0
        }
    }
    
    @IBAction func numberButtonPressed(_ sender: UIButton) {
        let number = sender.tag
        if self.enteringNumber {
            // Prevent numbers larger than 9 digits
            if self.numberText.countDigits() >= 9 { return }
            self.numberText += "\(number)"
        } else {
            self.enteringNumber = true
            self.numberText = "\(number)"
        }
    }
    
    @IBAction func decimalButtonPressed(_ sender: UIButton) {
        if self.enteringNumber {
            // Only allow one "." at any given time
            if self.numberText.contains(".") { return }
            self.numberText += "."
        } else {
            self.enteringNumber = true
            self.numberText = "0."
        }
    }
}

