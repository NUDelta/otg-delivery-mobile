import UIKit

class RequestTableViewCell: UITableViewCell {
    static let reuseIdentifier = "helperStatusReuseIdentifier"

    let statusLabel = UILabel()
    let itemDetailsLabel = UILabel()
    let locationDetailsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.isUserInteractionEnabled = false
        self.clipsToBounds = true

        let subtitleTitleColor = UIColor.darkGray
        let subtitleTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)

        let labels = [
            statusLabel,
            itemDetailsLabel,
            locationDetailsLabel
        ]

        labels.forEach { label in
            label.font = subtitleTitleFont
            label.textColor = subtitleTitleColor
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            addSubview(label)
        }
        addConstraints()
    }

    func addConstraints() {
        let topMarginConstraint = NSLayoutConstraint(item: statusLabel,
                                                     attribute: .top,
                                                     relatedBy: .equal,
                                                     toItem: self,
                                                     attribute: .topMargin,
                                                     multiplier: 1.0,
                                                     constant: 0.0)

        let leftMarginConstraint = NSLayoutConstraint(item: statusLabel,
                                                      attribute: .left,
                                                      relatedBy: .equal,
                                                      toItem: self,
                                                      attribute: .leftMargin,
                                                      multiplier: 1.0,
                                                      constant: 0.0)

        let bottomMarginConstraint = NSLayoutConstraint(item: locationDetailsLabel,
                                                        attribute: .bottom,
                                                        relatedBy: .equal,
                                                        toItem: self,
                                                        attribute: .bottomMargin,
                                                        multiplier: 1.0,
                                                        constant: 0.0)

        let rightMarginConstraint = NSLayoutConstraint(item: statusLabel,
                                                       attribute: .right,
                                                       relatedBy: .lessThanOrEqual,
                                                       toItem: self,
                                                       attribute: .rightMargin,
                                                       multiplier: 1.0,
                                                       constant: 1.0)

        let constraints = [
            topMarginConstraint,
            leftMarginConstraint,
            bottomMarginConstraint,
            rightMarginConstraint,

            itemDetailsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            itemDetailsLabel.leftAnchor.constraint(equalTo: statusLabel.leftAnchor),

            locationDetailsLabel.topAnchor.constraint(equalTo: itemDetailsLabel.bottomAnchor),
            locationDetailsLabel.leftAnchor.constraint(equalTo: itemDetailsLabel.leftAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
