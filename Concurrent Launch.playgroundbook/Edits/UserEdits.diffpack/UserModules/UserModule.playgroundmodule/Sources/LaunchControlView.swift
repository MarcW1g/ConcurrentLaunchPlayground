
import UIKit

/// The type of launch that should be used while launching the rockets 
public enum LaunchType: String, CaseIterable {
    case serial = "Serial Execution"
    case concurrent = "Concurrent Execution"
}

public protocol LaunchControlProtocol {
    /// Prepare the rockets in the launch view
    /// - Parameter rocketCount: The number of rockets that should be added to the view
    func prepareRockets(_ rocketCount: Int)
    
    /// Launch the rockets with a launch type
    /// - Parameter type: The launch type used to launch the rockets (serial or concurrent)
    func launchWithType(_ type: LaunchType)
    
    /// Reset the rockets in the launch view
    func resetRockets()
}

/// The view presenting the launch control pad
public class LaunchControlView: UIView {
    // MARK: - Private Constants
    
    /// Segmented control for selecting the launch type
    private let launchTypeSegmentedControl: UISegmentedControl = {
        // Set the segments to the launch types of the LaunchType Enum
        var segmentedControl = UISegmentedControl(items: LaunchType.allCases.map { $0.rawValue })
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(launchTypeSegmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    /// The label image for the rocket counter
    private let rocketCounterLabelImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "nr_rockets_label.png"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// The rocket counter label
    private let rocketCounterLabel: UILabel = {
        let counterLabel = UILabel()
        counterLabel.text = "1"
        counterLabel.font = UIFont(name: "AmericanTypewriter", size: 60)
        counterLabel.textAlignment = .center
        counterLabel.textColor = .systemGreen
        counterLabel.backgroundColor = .black
        
        counterLabel.layer.borderWidth = 10
        counterLabel.layer.borderColor = UIColor.systemGray2.cgColor
        
        return counterLabel
    }()
    
    /// The counter stepper used to change the number of rockets
    private let rocketCounterStepper: UIStepper = {
        let stepper = UIStepper()
        
        // At minimum there should be 1 rocket. The max should be 5
        stepper.minimumValue = 1
        stepper.stepValue = 1
        stepper.maximumValue = 5
        
        stepper.wraps = true
        stepper.addTarget(self, action: #selector(rocketCounterValueChanged(_:)), for: .valueChanged)
        return stepper
    }()
    
    /// The button used to launch the rockets
    private let launchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Launch", for: .normal)
        button.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: 20)
        
        let launchButtonBackgroundImage = #imageLiteral(resourceName: "launchButtonBackground.png")
        button.setBackgroundImage(launchButtonBackgroundImage, for: .normal)
        
        button.addTarget(self, action: #selector(launchRocketButtonTouched(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// The label image for the *prepare rockets* button
    private let prepareButtonLabelImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "prepare_rockets_label.png"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// The button used to prepare the rockets
    private let prepareRocketsButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "red_button_off.png"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "red_button_on.png"), for: .highlighted)
        button.addTarget(self, action: #selector(prepareRocketsButtonTouched(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// The label image for the *reset rockets* button
    private let resetButtonLabelImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "reset_rockets_label.png"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// The button used to reset the rockets
    private let resetRocketsButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "red_button_off.png"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "red_button_on.png"), for: .highlighted)
        button.addTarget(self, action: #selector(resetRocketsButtonTouched(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// The standard padding around the whole view
    private let STANDARD_PADDING: CGFloat = 16
    
    /// The standard height for a button label image view
    private let BUTTON_LABEL_HEIGHT: CGFloat = 55
    
    /// The minimum width for a button label image view
    private let BUTTON_LABEL_WIDTH_MULTIPLIER: CGFloat = 1/2
    
    /// The standard width/height for the round buttons
    private let ROUND_CONTROL_BUTTON_WIDTH_HEIGHT: CGFloat = 110
    
    /// The standard width for the launch button
    private let LAUNCH_BUTTON_WIDTH: CGFloat = 500
    
    /// The standard height for the launch button
    private let LAUNCH_BUTTON_HEIGHT: CGFloat = 55
    
    /// The launch button width multiplier (relative to the width of the view)
    private let LAUNCH_BUTTON_WIDTH_MULTIPLIER: CGFloat = 2/5
    
    // The standard width for the counter label
    private let COUNTER_LABEL_WIDTH_HEIGHT: CGFloat = 90
    
    
    // MARK: Private properties
    
    /// The stack view for the rocket control portion of the control pad
    private var rocketControlVStack: UIStackView!
    
    /// The stack view for the control pad
    private var segmentedAndRocketControlVStack: UIStackView!
    
    /// The selected launch type
    private var currentLaunchType: LaunchType = .serial
    
    /// The selected number of rockets
    private var currentNumberOfRockets: Int = 1
    

    // MARK: Public Properties
    
    /// The delegate for the launch control protocol
    public var delegate: LaunchControlProtocol?
    
    
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
    
    /// Add/setup all views required to the view
    private func setupView() {
        // Set the background color
        self.backgroundColor = .systemGray3
        
        // Create the stack for the counter control
        let counterControlVStack = self.createStack(arrangedSubviews: [self.rocketCounterLabelImage, self.rocketCounterLabel, self.rocketCounterStepper], axis: .vertical, spacing: 20)
        
        // Create the stack for the rockets control
        let prepareRocketsVStack = self.createStack(arrangedSubviews: [self.prepareButtonLabelImageView, self.prepareRocketsButton], axis: .vertical)
        let resetVStack = self.createStack(arrangedSubviews: [self.resetButtonLabelImageView, self.resetRocketsButton], axis: .vertical)
        let prepareTopHStack = self.createStack(arrangedSubviews: [prepareRocketsVStack, resetVStack], axis: .horizontal)
        let rocketControlVStack = self.createStack(arrangedSubviews: [prepareTopHStack, self.launchButton], axis: .vertical)
        self.rocketControlVStack = rocketControlVStack
        
        // Combine the counter and rocket control stacks into one horizontal stack
        let controlHStack = self.createStack(arrangedSubviews: [counterControlVStack, rocketControlVStack], axis: .horizontal)
        
        // Combine the Segmented Control and the control stack into one vertical stack
        let segmentedAndRocketControlVStack = self.createStack(arrangedSubviews: [self.launchTypeSegmentedControl, controlHStack], axis: .vertical)
        
        // Add the control stack to the view
        self.segmentedAndRocketControlVStack = segmentedAndRocketControlVStack
        self.addSubview(segmentedAndRocketControlVStack)
    }
    
    /// Adds all constraints to the view
    private func setupConstraints() {
        // Create the constraints for the control stack
        let segmentedAndRocketControlVStackConstraints = [
            self.segmentedAndRocketControlVStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.STANDARD_PADDING),
            self.segmentedAndRocketControlVStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.STANDARD_PADDING),
            self.segmentedAndRocketControlVStack.topAnchor.constraint(equalTo: self.topAnchor, constant: self.STANDARD_PADDING),
        ]
        
        // Create the constraints for the launch type segmented control
        let launchTypeSegmentedControlConstraints = [
            self.launchTypeSegmentedControl.widthAnchor.constraint(equalTo: self.segmentedAndRocketControlVStack.widthAnchor)
        ]
        
        // Create the constraints for the rocket counter label image
        let rocketCounterLabelImageConstraints = [
            self.rocketCounterLabelImage.heightAnchor.constraint(equalToConstant: self.BUTTON_LABEL_HEIGHT)
        ]
        
        // Create the constraints for the rocket counter label
        let rocketCounterLabelConstraints = [
            self.rocketCounterLabel.heightAnchor.constraint(equalToConstant: self.COUNTER_LABEL_WIDTH_HEIGHT),
            self.rocketCounterLabel.widthAnchor.constraint(equalToConstant: self.COUNTER_LABEL_WIDTH_HEIGHT),
        ]
        
        // Create the constraints for the prepare rockets button
        let prepareRocketsButtonConstraints = [
            self.prepareRocketsButton.heightAnchor.constraint(equalToConstant: self.ROUND_CONTROL_BUTTON_WIDTH_HEIGHT),
            self.prepareRocketsButton.widthAnchor.constraint(equalToConstant: self.ROUND_CONTROL_BUTTON_WIDTH_HEIGHT)
        ]
        
        // Create the constraints for the prepare rockets label image
        let prepareButtonLabelImageViewConstraints = [
            self.prepareButtonLabelImageView.heightAnchor.constraint(equalToConstant: self.BUTTON_LABEL_HEIGHT),
            self.prepareButtonLabelImageView.widthAnchor.constraint(greaterThanOrEqualTo: self.rocketControlVStack.widthAnchor, multiplier: self.BUTTON_LABEL_WIDTH_MULTIPLIER)
        ]
        
        // Create the constraints for the reset rockets button
        let resetRocketsButtonConstraints = [
            self.resetRocketsButton.heightAnchor.constraint(equalToConstant: self.ROUND_CONTROL_BUTTON_WIDTH_HEIGHT),
            self.resetRocketsButton.widthAnchor.constraint(equalToConstant: self.ROUND_CONTROL_BUTTON_WIDTH_HEIGHT)
        ]
        
        // Create the constraints for the reset rockets label image
        let resetButtonLabelImageViewConstraints = [
            self.resetButtonLabelImageView.heightAnchor.constraint(equalToConstant: self.BUTTON_LABEL_HEIGHT),
            self.resetButtonLabelImageView.widthAnchor.constraint(greaterThanOrEqualTo: self.rocketControlVStack.widthAnchor, multiplier: self.BUTTON_LABEL_WIDTH_MULTIPLIER)
        ]
        
        // Create the constraints for the launch button
        let launchButtonConstraints = [
            self.launchButton.heightAnchor.constraint(equalToConstant: self.LAUNCH_BUTTON_HEIGHT),
            self.launchButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: self.LAUNCH_BUTTON_WIDTH_MULTIPLIER),
            self.launchButton.centerXAnchor.constraint(equalTo: self.rocketControlVStack.centerXAnchor)
        ]
        
        // Activate the constraints
        NSLayoutConstraint.activate(segmentedAndRocketControlVStackConstraints)
        NSLayoutConstraint.activate(launchTypeSegmentedControlConstraints)
        NSLayoutConstraint.activate(launchButtonConstraints)
        NSLayoutConstraint.activate(rocketCounterLabelConstraints)
        NSLayoutConstraint.activate(rocketCounterLabelImageConstraints)
        NSLayoutConstraint.activate(prepareRocketsButtonConstraints)
        NSLayoutConstraint.activate(prepareButtonLabelImageViewConstraints)
        NSLayoutConstraint.activate(resetRocketsButtonConstraints)
        NSLayoutConstraint.activate(resetButtonLabelImageViewConstraints)
    }
    
    
    // MARK: - View Creation helper functions
    
    /// Creates a standard stack view (center alignment) for the provided subviews
    /// - Parameters:
    ///   - arrangedSubviews: The list of views arranged by the stack view
    ///   - axis: The axis along which the arranged views are laid out.
    ///   - spacing: The distance in points between the adjacent edges of the stack view’s arranged views (standard: 10.0)
    /// - Returns: A new UIStackView
    private func createStack(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat = 10.0) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = axis
        stackView.alignment = .center
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    
    // MARK: - Actions
    
    /// Segmented Control action for valueChanged
    @objc private func launchTypeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        currentLaunchType = LaunchType.allCases[sender.selectedSegmentIndex]
    }
    
    /// Rocket Counter Stepper action for valueChanged
    @objc private func rocketCounterValueChanged(_ sender: UIStepper) {
        // Get the new value (as int)
        let rocketCount = Int(sender.value)
        
        // Update the label and currentNumberOfRockets
        self.rocketCounterLabel.text = String(rocketCount)
        self.currentNumberOfRockets = rocketCount
    }
    
    /// Prepare rockets button action for touchUpInside
    @objc private func prepareRocketsButtonTouched(_ sender: UIButton) {
        self.delegate?.prepareRockets(self.currentNumberOfRockets)
    }
    
    /// Reset rockets button action for touchUpInside
    @objc private func resetRocketsButtonTouched(_ sender: UIButton) {
        self.delegate?.resetRockets()
    }
    
    /// Launch rockets button action for touchUpInside
    @objc private func launchRocketButtonTouched(_ sender: UIButton) {
        self.delegate?.launchWithType(currentLaunchType)
    }
}
