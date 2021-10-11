//
//  FilterViewController.swift
//  New Places
//
//  Created by Егор Янкович on 22.09.21.
//

import UIKit

class FilterViewController: UIViewController {
    
    //MARK:- IB Variables
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var filtertitle: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var moneySlider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var sortByTableView: UITableView!
    @IBOutlet weak var filterTable: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- UI Variables
    let maxDimmedAlpha: CGFloat = 0.6
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    let borderView: UIView = {
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .black
        borderView.alpha = 0.3
        return borderView
    }()
    
    let borderLine: UIView = {
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .black
        borderView.alpha = 0.2
        return borderView
    }()
    
    //MARK:- Variables
    private let sortByTableCells = ["Top Rated", "Nearest Me", "Cost Hight to Low", "Cost Low to Hight"]
    private let filterTableCells = ["Open Now", "Credit Cards", "Free Delivery"]
    private let collectionViewCell = ["American", "Turkish", "Asia", "Fast Food", "Pizza", "Desserds", "Mexican" ]
    // Constants
    private let defaultHeight: CGFloat = 500
    private let dismissibleHeight: CGFloat = 200
    private let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height
    private var currentContainerHeight: CGFloat = 500
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupPanGesture()
        setupGesture()
        sortByTableView.delegate = self
        sortByTableView.dataSource = self
        filterTable.delegate = self
        filterTable.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    //MARK:- Action Methods
    
    @IBAction func resetButton(_ sender: Any) {
        animateDismissView()
    }
    
    @IBAction func doneButton(_ sender: Any) {
        animateDismissView()
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        let value = sender.value
        sliderLabel.text = "$\(value.rounded())"
    }
    
    //MARK:- Private Methods
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    private func setupView() {
        view.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        containerView.addSubview(borderView)
        containerView.addSubview(borderLine)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            borderView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            borderView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            borderView.heightAnchor.constraint(equalToConstant: 4),
            borderView.widthAnchor.constraint(equalToConstant: 50),
            borderLine.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            borderLine.topAnchor.constraint(equalTo: filtertitle.topAnchor, constant: 40),
            borderLine.heightAnchor.constraint(equalToConstant: 1),
            borderLine.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.height)
        ])
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    private func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    
    private func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    private func animateDismissView() {
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.currentContainerHeight
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK:- ObjC Methods
    
    // Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let isDraggingDown = translation.y > 0
        let newHeight = currentContainerHeight - translation.y
        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
}

//MARK:- Extention Table View

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = Int()
        if tableView == self.sortByTableView {
            count = sortByTableCells.count
        } else if tableView == self.filterTable {
            count = filterTableCells.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellToReturn = UITableViewCell()
        if tableView == self.sortByTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sortCell", for: indexPath)
            cell.textLabel?.text = sortByTableCells[indexPath.row]
            cellToReturn = cell
        } else if tableView == self.filterTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
            cell.textLabel?.text = filterTableCells[indexPath.row]
            cellToReturn = cell
        }
        cellToReturn.textLabel?.textColor = UIColor(named: "Dark blue")
        return cellToReturn
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor.white
        selectedCell?.selectionStyle = UITableViewCell.SelectionStyle.none
        if selectedCell?.accessoryType == .checkmark {
            selectedCell?.accessoryType = .none
            selectedCell?.textLabel?.textColor = UIColor(named: "Dark blue")
        } else {
            selectedCell?.accessoryType = .checkmark
            selectedCell?.textLabel?.textColor = UIColor(named: "Custom Pink")
        }
    }
}

//MARK:- Collection View

extension FilterViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CuisinesCollectionViewCell
        cell.cuisinesLabel.text = collectionViewCell[indexPath.row]
        return cell
    }
}
