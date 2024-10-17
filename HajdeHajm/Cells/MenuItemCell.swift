//
//  MenuItemCell.swift
//  HajdeHajm
//
//  Created by Kujtim Saliu on 17.10.24.
//

import UIKit


protocol MenuItemCellDelegate: AnyObject {
    func cell(_ cell: MenuItemCell, didUpdateQuantityFor menuItem: MenuItem, to quantity: Int)
}


class MenuItemCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let quantityStepper = UIStepper()
    private let quantityLabel = UILabel()
    
    weak var delegate: MenuItemCellDelegate?
    private var menuItem: MenuItem?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [nameLabel, descriptionLabel, priceLabel, quantityStepper, quantityLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            nameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
//            priceLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
//            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
//            quantityStepper.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            quantityStepper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quantityStepper.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            quantityStepper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            quantityLabel.centerYAnchor.constraint(equalTo: quantityStepper.centerYAnchor),
            quantityLabel.trailingAnchor.constraint(equalTo: quantityStepper.leadingAnchor, constant: -10)
        ])
        
        quantityStepper.addTarget(self, action: #selector(quantityChanged), for: .valueChanged)
    }
    
    func configure(with menuItem: MenuItem, quantity: Int) {
        self.menuItem = menuItem
        nameLabel.text = menuItem.name
        descriptionLabel.text = menuItem.description
        priceLabel.text = "\(menuItem.price) MKD"
        quantityStepper.value = Double(quantity)
        quantityLabel.text = "\(quantity)"
    }
    
    @objc private func quantityChanged() {
        guard let menuItem = menuItem else { return }
        let quantity = Int(quantityStepper.value)
        quantityLabel.text = "\(quantity)"
        delegate?.cell(self, didUpdateQuantityFor: menuItem, to: quantity)
    }
}
