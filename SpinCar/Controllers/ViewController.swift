//
//  ViewController.swift
//  SpinCar
//
//  Created by Satya on 7/9/18.
//  Copyright © 2018 Satya. All rights reserved.
//

import UIKit

// MARK: MainViewController
class ViewController: UIViewController {
    
    // MARK: Input Errors
    // represents the error conditions that might occur with the user input
    private enum InputError: String {
        case invalidSearchTextError = "Please enter a valid, non-empty search text"
        case invalidMaxFieldError = "Please enter a valid, non-empty max value"
        case nonPositiveMaxFieldError = "Max Image Count should be greater than 0"
        case nonPrimeMaxFieldError = "Max Image Count should be a prime number"
    }
    
    // MARK: Constants
    private let collectionCellReuseIdentifier = "imageCell"
    private let noResultError = "No results matches the search criteria"
    private let collectionViewInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    private let cellsForRow: CGFloat = 8
    private let defaultPageCount = 100
    
    // MARK: Outlets
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var maxImagesField: UITextField!
    @IBOutlet private weak var imageCollectionView: UICollectionView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var searchButton: UIButton!
    
    // MARK: Properties
    private var collectionDataSource = [ImageData]()
    private var imagesToBeFetched: Int?
    private var currentSearchText: String?
    private var isFetchingNewPageData = false
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private
    // Initial UI setup
    private func setUpUI() {
        searchBar.delegate = self
        maxImagesField.delegate = self
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        errorLabel.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    // checks the validity of the input search text
    private func checkSearchTextValidity() -> Bool {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return false
        }
        currentSearchText = searchText
        return true
    }
    
    // checks the validity of the input maxField and returns the error status, if the input is invalid
    private func checkMaxFieldValidity() -> (Bool, InputError?) {
        guard let maxCountString = maxImagesField.text, !maxCountString.isEmpty, let maxCount = Int(maxCountString) else {
            return (false, InputError.invalidMaxFieldError)
        }
        guard maxCount > 0 else {
            return (false, InputError.nonPositiveMaxFieldError)
        }
        guard maxCount.isPrime() else {
            return (false, InputError.nonPrimeMaxFieldError)
        }
        imagesToBeFetched = maxCount
        return (true, nil)
    }
    
    // downloads the images for the current search criteria
    private func fetchImages(forPage page: Int, withPageCount pageCount: Int) {
        isFetchingNewPageData = true
        weak var weakSelf = self
        NetworkingClient.shared.fetchImageData(with: currentSearchText!, pageNum: page, pageCount: pageCount, completion: { networkResponse in
            DispatchQueue.main.async {
                guard let strongSelf = weakSelf else {
                    return
                }
                if let errorMessage = networkResponse.errorMessage {
                    strongSelf.isFetchingNewPageData = false
                    Utility.shared.showErrorAlert(on: strongSelf, message: errorMessage)
                } else if let dataArray = networkResponse.data {
                    for item in dataArray {
                        strongSelf.collectionDataSource.append(item)
                    }
                    if strongSelf.collectionDataSource.isEmpty {
                        strongSelf.imageCollectionView.isHidden = true
                        strongSelf.errorLabel.isHidden = false
                        strongSelf.errorLabel.text = strongSelf.noResultError
                    } else {
                        strongSelf.errorLabel.isHidden = true
                        strongSelf.imageCollectionView.isHidden = false
                        strongSelf.imageCollectionView.reloadData()
                    }
                    strongSelf.isFetchingNewPageData = false
                }
            }
        })
    }
    
    // MARK: Action methods
    @IBAction private func searchImages(_ sender: Any) {
        view.endEditing(true)
        if isFetchingNewPageData {
            return
        }
        // only proceed if the search text is valid
        if !checkSearchTextValidity() {
            Utility.shared.showErrorAlert(on: self, message: InputError.invalidSearchTextError.rawValue)
            return
        }
        // also the max count
        let maxCountValidity = checkMaxFieldValidity()
        if !maxCountValidity.0 {
            Utility.shared.showErrorAlert(on: self, message: maxCountValidity.1!.rawValue)
            return
        }
        
        //remove the existing data
        collectionDataSource.removeAll()
        imageCollectionView.reloadData()
        
        // calculates the pending downloads, using the current content and the max allowed
        let pendingDownloads = imagesToBeFetched! - collectionDataSource.count
        let pageCount = pendingDownloads > defaultPageCount ? defaultPageCount : pendingDownloads
        
        // always fetch the first page with a new search term
        fetchImages(forPage: 1, withPageCount: pageCount)
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if !checkSearchTextValidity() {
            Utility.shared.showErrorAlert(on: self, message: InputError.invalidSearchTextError.rawValue)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isMaxCountValid = checkMaxFieldValidity()
        if !isMaxCountValid.0 {
            Utility.shared.showErrorAlert(on: self, message: isMaxCountValid.1!.rawValue)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellReuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        imageCollectionCell.tag = indexPath.item
        imageCollectionCell.setUpCell(with: collectionDataSource[indexPath.item])
        return imageCollectionCell
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionViewInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewInsets.top
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionFrameWidth = collectionView.frame.width
        let availableWidth = collectionFrameWidth - (cellsForRow+1) * collectionViewInsets.left
        let cellDimension = availableWidth/cellsForRow
        return CGSize(width: cellDimension, height: cellDimension)
    }
}

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let imagesToBeFetched = self.imagesToBeFetched else {
            return
        }
        let pendingDownloads = imagesToBeFetched - collectionDataSource.count
        // exit if the pending downloads is 0
        if pendingDownloads == 0 {
            return
        }
        // exit if the previous search returned less than the default page count
        if collectionDataSource.count % defaultPageCount != 0 {
            return
        }
        // fetch data for new page, if the user has scrolled enough
        if scrollView.contentSize.height <= scrollView.contentOffset.y + scrollView.frame.height && !isFetchingNewPageData{
            let pageCount = pendingDownloads > defaultPageCount ? defaultPageCount : pendingDownloads
            let currentPage = collectionDataSource.count/defaultPageCount
            fetchImages(forPage: currentPage+1, withPageCount: pageCount)
        }
    }
}

