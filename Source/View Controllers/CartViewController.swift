//
//  CartViewController.swift
//
// MIT License
//
// Copyright (c) 2016 Chris Voss
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import UIKit

/// A view controller that displays the contents of a shopping basket and allows it to be edited
final public class CartViewController: UIViewController {
    
    public let cart: Cart
    
    // MARK: - Initialization
    
    /// Returns a new cart view controller
    init(cart: Cart) {
        self.cart = cart
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Controller
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        view.addSubview(gradientView)
        view.addSubview(checkoutButton)
        
        NSLayoutConstraint.activate([
            checkoutButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            checkoutButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            checkoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            gradientView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            gradientView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            gradientView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 80)) // padding for floating check out button
        
        
        setBarButtonItems()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTotals()
    }
    
    // MARK: - Private
    
    fileprivate let checkoutButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.green.withAlphaComponent(0.9) // TODO: placeholder
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5

        button.accessibilityHint = NSLocalizedString("Purchase the items in the cart", comment: "Hint for check out button")
        button.accessibilityIdentifier = "checkout"
        return button
    }()
    
    @objc fileprivate func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func didTapEditButton(_ sender: UIBarButtonItem) {
        let newMode = !tableView.isEditing
        
        tableView.setEditing(newMode, animated: true)
        navigationItem.rightBarButtonItem = newMode ? doneButton : editButton
    }
    
    lazy var doneButton: UIBarButtonItem? = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapEditButton(_:)))
    }()
    
    lazy var editButton: UIBarButtonItem? = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditButton(_:)))
    }()
    
    fileprivate let gradientView: GradientView = {
        let view = GradientView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        
        view.startPoint = 0.9
        view.endPoint = 1.0
        view.from = .clear
        view.to = UIColor.black.withAlphaComponent(0.4)
        
        return view
    }()

    /// Used to format the price into a string for display
    fileprivate let priceFormatter = PriceFormatter()

    fileprivate func setBarButtonItems() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))
        navigationItem.leftBarButtonItem = cancelButton
        
        navigationItem.rightBarButtonItem = editButton
    }
    
    fileprivate let tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.estimatedRowHeight = 60
        view.rowHeight = UITableViewAutomaticDimension
        
        view.register(ProductTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        return view
    }()
    
    fileprivate func updateTotals() {
        let countString = String(format: NSLocalizedString("Cart (%d)", comment: "Cart title with item count"), cart.count)
        self.title = countString
        
        let totalString = priceFormatter.formattedPrice(for: cart.totalPrice) ?? ""
        let checkoutString = String(format: NSLocalizedString("Check out (%@)", comment: "Check out button title with cart total"), totalString)
        checkoutButton.setTitle(checkoutString, for: .normal)
    }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ProductTableViewCell
        
        let product = cart.product(at: indexPath.row)
        let priceString = priceFormatter.formattedPrice(for: product.price) ?? ""
        cell.configure(name: product.name, details: priceString)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            cart.remove(at: indexPath.row)
            updateTotals()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}