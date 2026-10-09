//
//  NewsFeedCell.swift
//  NewsFeed
//
//  Created by Timur  on 08.10.2026.
//

import Common
import DesignSystem
import UIKit
import News

final public class NewsFeedCell: UICollectionViewCell {

    public static let reuseIdentifier = String(describing: NewsFeedCell.self)

    // MARK: - Public properties

    public var titleText: String = "" {
        didSet {
            let style = NSMutableParagraphStyle()
            style.firstLineHeadIndent = 12
            style.headIndent = 12
            style.tailIndent = -12

            titleLabel.attributedText = NSAttributedString(
                string: titleText,
                attributes: [.paragraphStyle: style, .font: UIFont.preferredFont(forTextStyle: .title2)]
            )
        }
    }

    // MARK: - Private properties

    private var imageLoadTask: Task<Void, Never>?
    private let imageLoader: LoadImageActor = .shared

    // MARK: - UI Components

    private lazy var activityindicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)

        indicator.hidesWhenStopped = true
        indicator.color = .secondaryLabel
        indicator.translatesAutoresizingMaskIntoConstraints = false

        return indicator
    }()

    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true

        return imageView
    }()

    public private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.textColor = .label
        label.numberOfLines = 0

        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])

        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .secondarySystemBackground
        stack.layer.cornerRadius = 16
        stack.clipsToBounds = true
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = .init(top: 0, leading: 0, bottom: 12, trailing: 0)

        return stack
    }()

    // MARK: - Public Methods

    public override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .systemBackground

        contentView.addSubview(stackView)
        contentView.addSubview(activityindicator)

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with item: NewsFeedItem) {
        titleText = item.title

        guard
            let titleImageUrl = item.titleImageUrl,
            let url = URL(string: titleImageUrl)
        else {
            imageView.image = Images.autodoc
            return
        }

        activityindicator.startAnimating()

        imageLoadTask?.cancel()
        imageLoadTask = Task { [weak self, imageLoader] in
            guard let self else { return }

            let image: UIImage

            do {
                image = try await imageLoader.loadImage(from: url)
            } catch {
                image = Images.autodoc
                print("Get error when load image in \(#file) \(#function)")
            }

            guard !Task.isCancelled else { return }
            imageView.image = image
            activityindicator.stopAnimating()
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageView.image = nil
        titleLabel.attributedText = nil
        activityindicator.stopAnimating()
    }

    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: [.allowUserInteraction, .beginFromCurrentState]
            ) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            }
        }
    }

    // MARK: - Private methods

    private func setupConstraints() {
        let bottom = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        bottom.priority = .init(999)

        let imageAspect = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.9)
        imageAspect.priority = .init(999)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottom,
            imageAspect,
            activityindicator.widthAnchor.constraint(equalToConstant: 56),
            activityindicator.widthAnchor.constraint(equalToConstant: 56),
            activityindicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            activityindicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

    }
}
