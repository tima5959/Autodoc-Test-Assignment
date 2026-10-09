//
//  NewsFeedDetailInfoView.swift
//  NewsFeedDetailInfo
//
//  Created by Timur  on 09.10.2026.
//

import UIKit
import WebKit

final public class NewsFeedDetailInfoView: UIView {

    // MARK: - UI Components

    public private(set) lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false

        return webView
    }()

    public private(set) lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)

        progressView.translatesAutoresizingMaskIntoConstraints = false

        return progressView
    }()

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground

        addSubview(webView)
        addSubview(progressView)

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    public func setProgress(_ progress: Float) {
        progressView.setProgress(progress, animated: progress > progressView.progress)
    }

    public func setProgressHidden(_ isHidden: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.progressView.alpha = isHidden ? 0 : 1
        } completion: { _ in
            if isHidden { self.progressView.progress = 0 }
        }
    }

    // MARK: - Private methods

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),

            progressView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
