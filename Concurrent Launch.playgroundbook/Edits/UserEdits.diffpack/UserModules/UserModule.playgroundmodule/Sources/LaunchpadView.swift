
import UIKit

/// Errors specialized for the launchpad view
public enum LaunchPadError: Error {
    case launchPadNotReadyForLaunch
    case launchPadAlreadyLaunched
}

/// The view presenting and creating the rockets
public class LaunchpadView: UIView {
    /// A typealias for representing a rocket
    private typealias Rocket = (imageView: UIImageView, topConstraint: NSLayoutConstraint, bottomConstraint: NSLayoutConstraint)
    
    
    // MARK: Private Constants
    
    /// The Height for the launch pad
    private let LAUNCH_PAD_VIEW_HEIGHT: CGFloat = 100
    
    /// The minimum spacing between the rockets on the launch pad
    private let ROCKET_SPACING: CGFloat = 5.0
    
    /// The duration of sleep in the launch sequence
    private let EXTEND_FUNC_SLEEP_DURATION: UInt32 = 4
    
    // Animation Durations
    /// The duration of the complete launch animation
    private let LAUNCH_ANIMATION_DURATION: TimeInterval = 3.0
    
    /// The duration of the rocket rotation animation
    private let LAUNCH_ROTATION_DURATION: TimeInterval = 1.5
    
    /// The duration of a rocket fade animation
    private let ROCKET_FADE_DURATION: TimeInterval = 1.0
    
    
    // MARK: - Private Properties
    
    /// A computed value returning a new rocket image view
    private var rocketView: UIImageView {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "rocket_off.png")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    /// Value indicating if the rockets/view is ready for a launch
    private var readyForLaunch: Bool = false
    
    /// Value indicating if the rockets have launched
    private var rocketsLaunched: Bool = false 
    
    /// Array holding the current available rockets
    private var rockets = [Rocket]()


    // MARK: - Initialization
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    // MARK: - View UI Functions
    
    /// Sets up the rockets in the view
    /// - Parameters:
    ///   - rocketCount: The number of rockets added to the launch pad
    ///   - completion: Completion called after the rocket views are added to the launch pad
    private func setupRockets(rocketCount: Int, completion: @escaping () -> Void) {
        // Calculate the width for each rocket
        let rocketWidth = (self.frame.width - (self.ROCKET_SPACING * CGFloat(rocketCount - 1))) / CGFloat(rocketCount)
        
        // Set the current leading anchor on the view's leading anchor
        var anchoringLeading: NSLayoutXAxisAnchor = self.leadingAnchor
        
        for _ in 0..<rocketCount {
            // Create a new rocket and add it to the view
            let newRocket = self.rocketView
            newRocket.alpha = 0.0
            self.addSubview(newRocket)
            
            // Add and activate the width and leading anchors
            newRocket.widthAnchor.constraint(equalToConstant: rocketWidth).isActive = true
            newRocket.leadingAnchor.constraint(equalTo: anchoringLeading, constant: self.ROCKET_SPACING).isActive = true
            
            // Add and activate the rocket bottom constraint
            let rocketBottomConstraint = newRocket.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            rocketBottomConstraint.isActive = true
            
            // Add the rocket top constraint (not yet activated)
            let rocketTopConstraint = newRocket.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
            rocketTopConstraint.isActive = false
            
            // Add the rocket to the rockets array (as a Rocket type)
            self.rockets.append((
                    imageView: newRocket, 
                    topConstraint: rocketTopConstraint, 
                    bottomConstraint: rocketBottomConstraint
                ))
            
            // Set the leading achor for next rocket
            anchoringLeading = newRocket.trailingAnchor
        }
        
        completion()
    }
    
    /// Launches a single rocket with a translate and rotate animation
    /// - Parameter index: The index of the rocket in the rockets array which has to be launched
    private func launchRocket(index: Int) {
        // Check if the given index is within bounds
        guard index >= 0 && index < self.rockets.count else { return }
        
        // Get the rocket
        let rocket = rockets[index]
        
        // Make sure the animation runs on the main thread 
        DispatchQueue.main.async {
            // Change the rocket image to an active rocket image
            UIView.transition(with: rocket.imageView, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                rocket.imageView.image = #imageLiteral(resourceName: "rocket_on.png")
            }) { (_) in
                // Disable/Enable bottom and top constraints
                rocket.bottomConstraint.isActive = false
                rocket.topConstraint.isActive = true
                
                // Animate the constraint change
                UIView.animate(withDuration: self.LAUNCH_ANIMATION_DURATION, delay: 0, options: .curveEaseInOut, animations: {
                    self.layoutIfNeeded()
                }) { (_) in
                    // Transition the active rocket image back to an inactive one
                    UIView.transition(with: rocket.imageView, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                        rocket.imageView.image = #imageLiteral(resourceName: "rocket_off.png")
                    })
                }
                
                // Animate the rotation of the rocket
                UIView.animate(withDuration: self.LAUNCH_ROTATION_DURATION, delay: (self.LAUNCH_ANIMATION_DURATION - self.LAUNCH_ROTATION_DURATION) / 2, options: .curveEaseInOut, animations: {
                    rocket.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                })
            }
        }
    }
    
    
    // MARK: - Public Launch Pad Controls
    
    /// Public declaration to reset the rockets. All rockets will be removed from the view
    public func resetRockets() {
        self.resetCurrentRockets()
        self.readyForLaunch = false
        self.rocketsLaunched = false
    }
    
    /// First reset the rockets, after which new rockets are added to the view
    /// Parameter rocketCount: The number of rockets which should be added to the launchpad view
    public func prepareRockets(rocketCount: Int) {
        self.resetCurrentRockets { 
            self.setupAllRockets(rocketCount: rocketCount)
            self.readyForLaunch = true
            self.rocketsLaunched = false
        }
    }
    
    /// Checks if the view is ready for launch and launches the rockets using a *LaunchType*
    /// - Parameter type: The launch type used to launch the rockets
    public func launchRocketsWithType(_ type: LaunchType) throws {
        // Check if the rockets are ready for launch
        guard self.readyForLaunch else {
            throw LaunchPadError.launchPadNotReadyForLaunch
        }
        
        guard !self.rocketsLaunched else {
            throw LaunchPadError.launchPadAlreadyLaunched
        }
        
        // Create the correct queue for the given *type*
        let queue: DispatchQueue
        switch type {
        case .concurrent:
            queue = DispatchQueue(label: "playground.serial", attributes: .concurrent)
        case .serial:
            queue = DispatchQueue(label: "playground.serial")
        }
        
        // Put the launch jobs in the queue
        self.launchOnDispatchQueue(queue)
    }
    
    // MARK: - Private Launch Pad Controls
    
    /// Remove all rockets from the current launchpad view (animated)
    /// Parameter completion: Completion called after the rockets are removed from the view
    private func resetCurrentRockets(completion: (() -> Void)? = nil) {
        // Animate out all rockets
        UIView.animate(withDuration: self.ROCKET_FADE_DURATION, delay: 0, options: .curveEaseIn, animations: { 
            for rocket in self.rockets {
                rocket.imageView.alpha = 0.0
            }
        }) { (completed) in
            // If completed, remove all rockets from the launchpad view
            if completed {
                for rocket in self.rockets {
                    rocket.imageView.removeFromSuperview()
                }
                
                // Clear the rockets array
                self.rockets = []
                
                completion?()
            }
        }
    }
    
    /// Adds the rockets to the view after they are animated to be visible
    /// Parameter rocketCount: The number of rockets which should be added to the launchpad view
    private func setupAllRockets(rocketCount: Int) {
        self.setupRockets(rocketCount: rocketCount) {
            UIView.animate(withDuration: self.ROCKET_FADE_DURATION, delay: 0, options: .curveEaseOut, animations: {
                for rocket in self.rockets {
                    rocket.imageView.alpha = 1.0
                }
            })
        }
    }
    
    /// Launches the rockets using a provided dispatch queue
    private func launchOnDispatchQueue(_ queue: DispatchQueue) {
        // Adds all rockets to the queue (async)
        for (rocketNum, rocket) in self.rockets.enumerated() {
            queue.async {
                self.launchRocket(index: rocketNum)
                
                // Add a sleep to extend the duration of the function
                // This is used to emphasize the effect of a (serial) dispatch queue
                sleep(self.EXTEND_FUNC_SLEEP_DURATION)
            }
        }
        self.rocketsLaunched = true
    }
}
