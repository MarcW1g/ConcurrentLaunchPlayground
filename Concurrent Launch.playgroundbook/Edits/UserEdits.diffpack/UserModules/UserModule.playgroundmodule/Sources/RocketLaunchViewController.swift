
import UIKit

// We need a single global property for the launch control view height as a bottom constraint breaks all other constraints (in Swift Playgrounds only)
let LAUNCH_CONTROL_HEIGHT: CGFloat = 320

/// The View Controller controlling the live view of the Rocket Launcher Playground
public class RocketLaunchLiveViewController : UIViewController, LaunchControlProtocol, LaunchViewProtocol {
    // MARK: - Private Constants
    
    /// The launch control view to control the live view
    private let launchControlView: LaunchControlView = {
        var launchControlView = LaunchControlView()
        launchControlView.translatesAutoresizingMaskIntoConstraints = false
        return launchControlView
    }()
    
    /// The launch view presenting the rockets and eart/moon
    private let launchView: LaunchView = {
        var launchView = LaunchView()
        launchView.translatesAutoresizingMaskIntoConstraints = false
        return launchView
    }()
    
    
    // MARK: - View Controller Setup
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupConstraints()
    }
    
    /// Add/setup all views required to the view
    private func setupView() {
        self.view.addSubview(self.launchView)
        self.view.addSubview(self.launchControlView)
        
        // Set this View Controller as the delegate
        self.launchControlView.delegate = self
        self.launchView.delegate = self
    }
    
    /// Adds all constraints to the view
    private func setupConstraints() {
        // Create constraints for the (top) launch view
        let launchViewConstraints = [
            self.launchView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.launchView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.launchView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.launchView.bottomAnchor.constraint(equalTo: self.launchControlView.topAnchor)
        ]
        
        // Create constraints for the (bottom) control view
        let launchControlViewConstraints = [
            self.launchControlView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.launchControlView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.launchControlView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.launchControlView.heightAnchor.constraint(equalToConstant: LAUNCH_CONTROL_HEIGHT)
        ]
        
        // Activate the constraints
        NSLayoutConstraint.activate(launchViewConstraints)
        NSLayoutConstraint.activate(launchControlViewConstraints)
    }
    
    
    // MARK: - LaunchControlProtocol
    
    /// Prepare the rockets in the launch view
    /// - Parameter rocketCount: The number of rockets that should be added to the view
    public func prepareRockets(_ rocketCount: Int) {
        launchView.setupWithRocketCount(rocketCount: rocketCount)
    }
    
    /// Launch the rockets with a launch type
    /// - Parameter type: The launch type used to launch the rockets (serial or concurrent)
    public func launchWithType(_ type: LaunchType) {
        launchView.launchRocketsWithType(type)
    }
    
    /// Reset the rockets in the launch view
    public func resetRockets() {
        launchView.resetRockets()
    }
    
    
    // MARK: - LaunchViewProtocol
    
    /// Presents a UIAlertController with a single dismiss button
    /// - Parameters:
    ///   - title: The title for the alert
    ///   - message: The message for the alert
    ///   - buttonTitle: The title for the dismiss button
    public func presentLaunchAlert(title: String, message: String, buttonTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default))
        self.present(alertController, animated: true)
    }
}
