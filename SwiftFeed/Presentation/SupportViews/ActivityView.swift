//
//  ActivityView.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import UIKit

class ActivityView: UIView {
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let loadingLabel = UILabel
        .makeWithStyle(.subheadline, weight: .bold)
        .textAlignment(.center)
        .text(Localized.loading)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Style.cornerRadius
        layer.masksToBounds = true
        layoutView()
    }
    
    private func layoutView() {
        addSubview(loadingLabel)
        addSubview(activityIndicator)
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        let activityConstraints = [
            activityIndicator.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 3),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)]
        
        let labelConstraints = [
            loadingLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: activityIndicator.bottomAnchor, multiplier: 1),
            loadingLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            trailingAnchor.constraint(equalToSystemSpacingAfter: loadingLabel.trailingAnchor, multiplier: 2),
            bottomAnchor.constraint(equalToSystemSpacingBelow: loadingLabel.lastBaselineAnchor, multiplier: 2)]
        
        NSLayoutConstraint.activate([
            activityConstraints,
            labelConstraints
        ].flatMap {$0})
    }
    
    func hide() {
        isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func show() {
        isHidden = false
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
