//
//  NewsFeedDetailInfoViewController.swift
//  NewsFeedDetailInfo
//
//  Created by Timur  on 09.10.2026.
//

import Combine
import UIKit
import WebKit

final public class NewsFeedDetailInfoViewController: UIViewController {

    // MARK: - Private properties

    private let viewModel: NewsFeedDetailInfoViewModel

    private lazy var baseView = NewsFeedDetailInfoView()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    public init(viewModel: NewsFeedDetailInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    public override func loadView() {
        view = baseView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()

        baseView.webView.navigationDelegate = self

        bind()

        baseView.webView.load(URLRequest(url: viewModel.url))
    }

    // MARK: - Private methods

    private func configureNavigationBar() {
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = .never

        if presentingViewController != nil, navigationController?.viewControllers.first === self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                systemItem: .close,
                primaryAction: UIAction { [weak self] _ in
                    self?.dismiss(animated: true)
                }
            )
        }
    }

    private func bind() {
        viewModel.$state
            .removeDuplicates()
            .sink { [weak self] state in
                self?.configureUI(state)
            }
            .store(in: &cancellables)

        baseView.webView.publisher(for: \.estimatedProgress)
            .sink { [weak self] progress in
                self?.baseView.setProgress(Float(progress))
            }
            .store(in: &cancellables)
    }

    private func configureUI(_ state: NewsFeedDetailInfoViewModel.State) {
        switch state {
        case .loading:
            baseView.setProgressHidden(false)
        case .loaded:
            baseView.setProgressHidden(true)
        case .error(let message):
            baseView.setProgressHidden(true)
            showError(message)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Не удалось загрузить", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.baseView.webView.reload()
        })

        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })

        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension NewsFeedDetailInfoViewController: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        viewModel.didStartLoading()
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.didFinishLoading()
    }

    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        guard error is URLError else { return }
        viewModel.didFailLoading(with: error)
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        guard error is URLError else { return }
        viewModel.didFailLoading(with: error)
    }
}
