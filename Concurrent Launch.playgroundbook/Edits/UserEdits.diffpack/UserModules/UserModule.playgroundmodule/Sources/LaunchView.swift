import UIKit

public protocol LaunchViewProtocol {
    /// Presents a UIAlertController with a single dismiss button
    /// - Parameters:
    ///   - title: The title for the alert
    ///   - message: The message for the alert
    ///   - buttonTitle: The title for the dismiss button
    func presentLaunchAlert(title: String, message: String, buttonTitle: String)
}

/// The view presenting the 'earth-moon' view and the launch pad (rockets)
public class LaunchView: UIView {
    // MARK: - Private Constants
    
    /// Sky-Space background gradient
    private let skySpaceGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor(red: 98/255, green: 159/255, blue: 187/255, alpha: 1.0).cgColor]
        gradientLayer.locations = [-0.3, 1.0]
        return gradientLayer
    }()
    
    /// Image view for the earth surface
    private let earthSurfaceView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "earth_surface.png"))
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Image view for the moon surface
    private let moonSurfaceView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "moon_surface.png"))
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// A flag decoration image for the moon surface
    private let moonFlagDecorationImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "moon_usa_flag.png"))
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// A background image pattern view for the stars
    private let starsPatternImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "stars_pattern.png"))
        imageView.alpha = 0.7
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// The launch pad view containing the rockets
    private let launchpadView: LaunchpadView = {
        let launchpadView = LaunchpadView()
        launchpadView.translatesAutoresizingMaskIntoConstraints = false
        return launchpadView
    }()
    
    /// The standard height for the earth/moon surface
    private let SURFACE_HEIGHT: CGFloat = 20
    
    /// The standard width and height for the flag image view
    private let STANDARD_FLAG_WIDTH_HEIGHT: CGFloat = 50
    
    
    // MARK: Public Properties
    /// Delegate for the LaunchView Protocol
    public var delegate: LaunchViewProtocol?
    
    
    // MARK: - Initialization
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.setupConstraints()
    }
    
    public init() {
        super.init(frame: .zero)
        self.setupView()
        self.setupConstraints()
    }
    
    
    // MARK: - View UI Functions
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // If the layout of the view changes, the space gradient should be redrawn
        self.skySpaceGradientLayer.frame = self.bounds
    }
    
    /// Add/setup all views required to the view
    private func setupView() {
        // First add the background layers
        self.layer.insertSublayer(self.skySpaceGradientLayer, at: 0)
        self.addSubview(self.starsPatternImageView)
        
        // Add the moon and earth surfaces
        self.addSubview(self.earthSurfaceView)
        self.addSubview(self.moonSurfaceView)
        
        // Add the moon decoration image view
        self.addSubview(self.moonFlagDecorationImageView)
        
        // Add the launchpad view
        self.addSubview(self.launchpadView)
    }
    
    /// Adds all constraints to the view
    private func setupConstraints() {
        // Create constraints for the stars background
        let starsPatternImageViewConstraints = [
            self.starsPatternImageView.bottomAnchor.constraint(equalTo: self.centerYAnchor),
            self.starsPatternImageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.starsPatternImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.starsPatternImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ]
        
        // Create constraints for the earth surface
        let earthSurfaceConstraints = [
            self.earthSurfaceView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.earthSurfaceView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.earthSurfaceView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.earthSurfaceView.heightAnchor.constraint(equalToConstant: self.SURFACE_HEIGHT),
        ]
        
        // Create constraints for the moon surface
        let moonSurfaceConstraints = [
            self.moonSurfaceView.topAnchor.constraint(equalTo: self.topAnchor),
            self.moonSurfaceView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.moonSurfaceView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.moonSurfaceView.heightAnchor.constraint(equalToConstant: self.SURFACE_HEIGHT),
        ]
        
        // Create constraints for the flag
        let moonFlagDecorationImageViewConstraints = [
            self.moonFlagDecorationImageView.topAnchor.constraint(equalTo: self.moonSurfaceView.bottomAnchor),
            self.moonFlagDecorationImageView.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            self.moonFlagDecorationImageView.widthAnchor.constraint(equalToConstant: self.STANDARD_FLAG_WIDTH_HEIGHT),
            self.moonFlagDecorationImageView.heightAnchor.constraint(equalToConstant: self.STANDARD_FLAG_WIDTH_HEIGHT),
        ]
        
        // Create constraints for the launch pad
        let launchpadViewConstraints = [
            self.launchpadView.bottomAnchor.constraint(equalTo: self.earthSurfaceView.topAnchor, constant: self.SURFACE_HEIGHT),
            self.launchpadView.topAnchor.constraint(equalTo: self.moonSurfaceView.bottomAnchor, constant: -self.SURFACE_HEIGHT),
            self.launchpadView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.launchpadView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ]
        
        // Activate the constraints
        NSLayoutConstraint.activate(starsPatternImageViewConstraints)
        NSLayoutConstraint.activate(launchpadViewConstraints)
        NSLayoutConstraint.activate(earthSurfaceConstraints)
        NSLayoutConstraint.activate(moonSurfaceConstraints)
        NSLayoutConstraint.activate(moonFlagDecorationImageViewConstraints)
    }
    
    
    // MARK: - Rocket setup and launch
    
    /// Sets up the launchpad with *rocketCount* rockets and enables the view for launch
    /// - Parameter rocketCount: The number of rockets that should be added to the launchpad
    public func setupWithRocketCount(rocketCount: Int) {
        self.launchpadView.prepareRockets(rocketCount: rocketCount)
    }
    
    /// Resets the launchpad and the disables the view for launch
    public func resetRockets() {
        self.launchpadView.resetRockets()
    }
    
    /// Launches the rockets using a *LaunchType*
    /// - Parameter type: The launch type used to launch the rockets
    public func launchRocketsWithType(_ type: LaunchType) {
        // Launch the rockets with the given type and catch the error if the job cannot be executed
        do {
            try self.launchpadView.launchRocketsWithType(type)
        } catch LaunchPadError.launchPadNotReadyForLaunch {
            self.delegate?.presentLaunchAlert(title: "Not ready!", message: "The rockets are not ready for launch. Please prepare them first.", buttonTitle: "Ok")
        } catch LaunchPadError.launchPadAlreadyLaunched {
            self.delegate?.presentLaunchAlert(title: "Already launched", message: "The rockets are already on the moon. Please first reset the rockets back to earth.", buttonTitle: "Ok")
        } catch {
            self.delegate?.presentLaunchAlert(title: "Unable to launch", message: "The rockets can currently not be launched.", buttonTitle: "Ok")
        }
    }
}

