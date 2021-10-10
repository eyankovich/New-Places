//
//  FilterViewController.swift
//  New Places
//
//  Created by Егор Янкович on 22.09.21.
//

import UIKit
import SwiftRangeSlider

class FilterViewController: UIViewController {
    // define lazy views    
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var filtertitle: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var sortByTableView: UITableView!
    @IBOutlet weak var filterTable: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    var sortByTableCells = ["Top Rated", "Nearest Me", "Cost Hight to Low", "Cost Low to Hight"]
    var filterTableCells = ["Open Now", "Credit Cards", "Free Delivery"]
    var collectionViewCell = ["American", "Turkish", "Asia", "Fast Food", "Pizza", "Desserds", "Mexican" ]
    
    // Constants
    let defaultHeight: CGFloat = 500
    let dismissibleHeight: CGFloat = 200
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 300
    
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        setupPanGesture()
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
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        containerView.addSubview(borderView)
        containerView.addSubview(borderLine)

        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
    
        // Set static constraints
        NSLayoutConstraint.activate([
            // set dimmedView edges to superview
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
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
        // Set dynamic constraints
        // First, set container to default height
        // after panning, the height can expand
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        // By setting the height to default height, the container will be hide below the bottom anchor view
        // Later, will bring it up by set it to 0
        // set the constant to default height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        print("Pan gesture y offset: \(translation.y)")
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
}

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
















//@objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//    var startLocation = CGFloat()
//    guard let containerViewBottomConstraint = self.containerViewBottomConstraint,
//          let containerViewHeightConstraint = self.containerViewHeightConstraint
//    else { return }
//    /// Start gesture
//    switch gesture.state {
//    case .began:
//        startLocation = containerViewBottomConstraint.constant
//    /// Gesture changes
//    case .changed:
//        let translation = gesture.translation(in: view)
//        print(translation.y)
//        let newY = containerViewBottomConstraint.constant + translation.y
//        let newHight = containerViewHeightConstraint.constant - (translation.y)
//        guard newY >= 0 else { return
//            containerViewHeightConstraint.constant = newHight
//        }
//        containerViewBottomConstraint.constant = newY
//        gesture.setTranslation(.zero, in: view)
//    /// Stopping the gesture
//    case .ended:
//        let velocity = gesture.velocity(in: self.view)
//        /// Condition, if the gesture speed exceeds the set one, then the view is closed. Ignoring the conditions below
//        if velocity.y >= 1000 {
//            animateDismissView()
//            animateContainerHeight(containerViewHeightConstraint.constant)
//
//        } else {
//            /// Condition if the view has dropped below 25% of the screen height - then the view is closed. Ignoring the conditions below
//            if containerViewBottomConstraint.constant > view.frame.height * 0.3 {
//                animateDismissView()
//                animateContainerHeight(containerViewHeightConstraint.constant)
//            } else {
//                /// Animation of the return of the view to its original position. If the view is not closed
//                UIView.animate(withDuration: 0.5,
//                               delay: 0,
//                               options: .curveEaseOut,
//                               animations: { [weak self] in
//                                self?.view.transform = .identity
//                                containerViewBottomConstraint.constant = startLocation
//                               }, completion: nil)
//            }
//        }
//    default: break
//    }
//}
