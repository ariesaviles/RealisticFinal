//
//  InspiredDView.swift
//  realistic
//
//  Created by Aries Aviles on 12/2/21.
//

import UIKit
import SwiftUI

import CoreHaptics
import CoreMotion

import Combine

import AVFoundation

class AppStateCIR: ObservableObject {
    @Published var simpleFlag = false
}

struct  InspiredDView: UIViewControllerRepresentable {
//    @ObservedObject var fsettings : FloorSettings
    typealias UIViewControllerType = InspiredDController
    
    @EnvironmentObject var settings: AppStateCIR
    
    func makeUIViewController(context: Context) -> InspiredDController {
        let  InspiredDViewController = UIViewControllerType()
//         InspiredDViewController.fsettings = fsettings
//        let  InspiredDViewController = UIStoryboard(name: "Test", bundle: nil).instantiateViewController(identifier: String(describing: InspiredDController.self)) as! InspiredDController
//         InspiredDViewController.settings = fsettings
//          InspiredDView.delegate = context.coordinator
        return  InspiredDViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            // left blank
    }
    
    func makeCoordinator() ->  InspiredDView.Coordinator {
        return Coordinator(self)
    }
}

extension  InspiredDView {
    class Coordinator /*: SomeUIKitViewDelegate */ {
        var parent:  InspiredDView
        
        init(_ parent:  InspiredDView) {
            self.parent = parent
        }
        
        // Implement delegate methods here
    }
}


struct  InspiredDView_Previews: PreviewProvider {
    static var previews: some View {
         InspiredDView()
    }
}

class InspiredDController: UIViewController, UICollisionBehaviorDelegate {
    
    var fullFloorImg: String = "inspireddesign-full"
    var wallTexture: String = "CollisionLarge"
    var floorTexture: String = "Texture"
    
    // A single circular view that represents the sphere.
    var sphereView: UIView!
    var spherePositionPublisher: Cancellable?
    let kSphereRadiusSmall: CGFloat = 30
    let kSphereRadiusLarge: CGFloat = 78
    let kSphereColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    let kShieldColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
    let kSphereImplosionColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0)
    let kMaxShieldWidth: CGFloat = 15
    
    var isAnimating = false
    
    private let kDisabledBackgroundColor = UIColor.systemBackground
    private let kEnabledBackgroundColor = UIColor.systemBackground
    private var enabledImageView: UIImageView?
    
    enum SphereState {
        case none
        case small
        case large
        case shield
    }
    
    var sphereState: SphereState = .none
    var rollingTextureEnabled = false
    
    // The haptic engine and state.
    var engine: CHHapticEngine!
    var engineNeedsStart = true
    var spawnPlayer: CHHapticPatternPlayer!
    var growPlayer: CHHapticPatternPlayer!
    var shieldPlayer: CHHapticPatternPlayer!
    var implodePlayer: CHHapticPatternPlayer!
    var collisionPlayerSmall: CHHapticPatternPlayer!
    var collisionPlayerLarge: CHHapticPatternPlayer!
    var collisionPlayerShield: CHHapticPatternPlayer!
    var texturePlayer: CHHapticAdvancedPatternPlayer!
    
    lazy var supportsHaptics: Bool = {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }()
    
    // An animator that the app uses.
    var animator: UIDynamicAnimator!
    
    // The behaviors to give the sphere physical realism.
    var gravity: UIGravityBehavior!
    var wallCollisions: UICollisionBehavior!
    var bounce: UIDynamicItemBehavior!
    
    // Properties to manage motion data from the accelerometer and gyroscope.
    var motionManager: CMMotionManager!
    var motionQueue: OperationQueue!
    var motionData: CMAccelerometerData!
    
    private var foregroundToken: NSObjectProtocol?
    private var backgroundToken: NSObjectProtocol?
    
    // Properties to track the screen dimensions.
    lazy var windowWidth: CGFloat = { UIScreen.main.bounds.size.width / 1.25 }()
    lazy var windowHeight: CGFloat = { UIScreen.main.bounds.size.height / 1.75 }()

    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let controller = UIHostingController(rootView: FlooringInfo(flooringInfo: MOCK_FLOORING[0], settings: FloorSettings()))
//        controller.view.translatesAutoresizingMaskIntoConstraints = false
//        self.addChild(controller)
//        self.view.addSubview(controller.view)
//        controller.didMove(toParent: self)
        
//        print("test:" + settings.imgName)
//
//        fullFloorImg = settings.imgName
//        wallTexture = settings.colliName
//        floorTexture = settings.ahapName

        view.backgroundColor = kDisabledBackgroundColor
        initializeBackgroundImage()
        
        // Create and configure haptics before doing anything else, because the game begins immediately.
        createAndStartHapticEngine()
        initializeSpawnHaptics()
        initializeGrowHaptics()
        initializeShieldHaptics()
        initializeImplodeHaptics()
        initializeTextureHaptics()
        initializeCollisionHaptics()
        
        initializeSphere()
        initializeWalls()
        initializeBounce()
        initializeGravity()
        initializeAnimator()
        activateAccelerometer()
        
        addGestureRecognizers()
        addObservers()
        // Place the sphere at the center of the screen to start.
        spawn(view.center)
        
        rollingTextureEnabled = true
        view.backgroundColor = kEnabledBackgroundColor
        enabledImageView?.isHidden = false
        switch sphereState {
        case .none:
            break
        case .small, .large, .shield:
            startTexturePlayerIfNecessary()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopHapticEngine()
        self.stopPlayer(texturePlayer)
        self.removeAnimationBehaviors()
        rollingTextureEnabled = false
    }
    
    //    ==================================================================
    //                Step 1: Change Background
    //    ==================================================================
    
    // Load and configure the background texture image.
    private func initializeBackgroundImage() {
        let backgroundImagePath = Bundle.main.path(forResource: fullFloorImg,
                                                   ofType: "jpeg")!
        let backgroundImage = UIImage(contentsOfFile: backgroundImagePath)!
        enabledImageView = UIImageView(image: resizeImage(image: backgroundImage))
        enabledImageView!.contentMode = .topLeft
        enabledImageView!.frame = view.frame
        view.addSubview(enabledImageView!)
        enabledImageView!.isHidden = true
    }
    
    private func initializeSphere() {
        sphereView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        sphereView.layer.shadowColor = UIColor.black.cgColor
        sphereView.layer.shadowOpacity = 1
        sphereView.layer.shadowOffset = CGSize(width: 3, height: 3)
        sphereView.layer.shadowRadius = 4
        sphereView.backgroundColor = kSphereColor
        sphereView.layer.borderColor = kShieldColor.cgColor
        view.addSubview(sphereView)
        
        spherePositionPublisher = sphereView.publisher(for: \.layer.position)
            .sink() { position in self.handleSpherePositionChanged() }
    }
    
    func resizeImage(image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: windowWidth, height: windowHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    @objc
    func handleSpherePositionChanged() {
        guard supportsHaptics, bounce != nil else { return }
        
        updateTexturePlayer(normalizedSphereVelocity)
    }
    
    // MARK: - UICollisionBehaviorDelegate
    
    func collisionBehavior(_ behavior: UICollisionBehavior,
                           beganContactFor item: UIDynamicItem,
                           withBoundaryIdentifier identifier: NSCopying?,
                           at point: CGPoint) {
        // Play collision haptic for supported devices.
        guard supportsHaptics && sphereState != .none else { return }

        playCollisionHaptic(normalizedSphereVelocity)
        
        if sphereState == .shield {
            if sphereView.layer.borderWidth > 0 {
                playShieldDamageAnimation(normalizedSphereVelocity)
            } else {
                let explosionThreshold: CGFloat = 0.2
                if CGFloat(normalizedSphereVelocity) >= explosionThreshold {
                    implode()
                }
            }
        }
    }
    
    @objc
    private func sphereTapped(_ tap: UITapGestureRecognizer) {
        guard !isAnimating else { return }
        
//        switch sphereState {
//        case .small:
//            grow()
//        case .large:
//            shield()
//        default:
//            print("No action for the tap gesture during: \(sphereState)")
//        }
    }
    
    @objc
    private func backgroundTapped(_ tap: UITapGestureRecognizer) {
        guard !isAnimating else { return }
        
        if sphereState == .none {
            spawn(tap.location(in: view))
        } else {
            if rollingTextureEnabled {
                rollingTextureEnabled = false
                view.backgroundColor = kDisabledBackgroundColor
                enabledImageView?.isHidden = true
                switch sphereState {
                case .none:
                    break
                case .small, .large, .shield:
                    stopPlayer(texturePlayer)
                }
            } else {
                rollingTextureEnabled = true
                view.backgroundColor = kEnabledBackgroundColor
                enabledImageView?.isHidden = false
                switch sphereState {
                case .none:
                    break
                case .small, .large, .shield:
                    startTexturePlayerIfNecessary()
                }
            }
        }
    }
    
    private func addGestureRecognizers() {
        let sphereTap = UITapGestureRecognizer(target: self, action: #selector(sphereTapped))
        sphereView.addGestureRecognizer(sphereTap)
        
//        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
//        view.addGestureRecognizer(backgroundTap)
    }
    
    private func addObservers() {
        backgroundToken = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                                 object: nil,
                                                                 queue: nil) { [weak self] _ in
            guard let self = self, self.supportsHaptics else { return }
            
            self.stopHapticEngine()

        }

        foregroundToken = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                                 object: nil,
                                                                 queue: nil) { [weak self] _ in
            guard let self = self, self.supportsHaptics else { return }
                                                                    
            self.restartHapticEngine()
            self.startTexturePlayerIfNecessary()
        }
    }
}

extension InspiredDController {
    
    private var wallPadding: CGFloat { return 1 }
    
    func initializeWalls() {
        wallCollisions = UICollisionBehavior(items: [sphereView])
        wallCollisions.collisionDelegate = self
        
        // Express the walls using vertices.
        let upperLeft = CGPoint(x: -wallPadding, y: -wallPadding)
        let upperRight = CGPoint(x: windowWidth + wallPadding, y: -wallPadding)
        let lowerRight = CGPoint(x: windowWidth + wallPadding, y: windowHeight + wallPadding)
        let lowerLeft = CGPoint(x: -wallPadding, y: windowHeight + wallPadding)
        
        // Each wall is a straight line shifted one pixel offscreen to give an impression of existing at the boundary.
        
        // The left edge of the screen.
        wallCollisions.addBoundary(withIdentifier: NSString("leftWall"),
                                   from: upperLeft,
                                   to: lowerLeft)
        
        // The right edge of the screen.
        wallCollisions.addBoundary(withIdentifier: NSString("rightWall"),
                                   from: upperRight,
                                   to: lowerRight)
        
        // The top edge of the screen.
        wallCollisions.addBoundary(withIdentifier: NSString("topWall"),
                                   from: upperLeft,
                                   to: upperRight)
        
        // The bottom edge of the screen.
        wallCollisions.addBoundary(withIdentifier: NSString("bottomWall"),
                                   from: lowerRight,
                                   to: lowerLeft)
        
    }
    
    // Each bounce against the wall is a dynamic item behavior, which lets you tweak the elasticity to match the haptic effect.
    func initializeBounce() {
        bounce = UIDynamicItemBehavior(items: [sphereView])
        
        // Increase the elasticity to make the sphere bounce higher.
        bounce.elasticity = 0.66
    }
    
    // Represent gravity as a behavior in UIKit Dynamics.
    func initializeGravity() {
        gravity = UIGravityBehavior(items: [sphereView])
    }
    
    // The animator ties the gravity, sphere, and wall, so UIKit Dynamics is aware of all components.
    func initializeAnimator() {
        animator = UIDynamicAnimator(referenceView: view)
    }
    
    // Play the spawn transformation.
    func spawn(_ location: CGPoint) {
        let newPosition = boundedSphereCenter(location: location,
                                              radius: kSphereRadiusSmall)
        sphereView.layer.position = newPosition
        isAnimating = true
        
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseIn],
                       animations: {
            self.startPlayer(self.spawnPlayer)
            self.sphereView.bounds = CGRect(x: 0, y: 0,
                                            width: self.kSphereRadiusSmall * 2,
                                            height: self.kSphereRadiusSmall * 2)
            self.sphereView.layer.cornerRadius = self.kSphereRadiusSmall
        }, completion: { _ in
            self.addAnimationBehaviors()
            self.animator.updateItem(usingCurrentState: self.sphereView)
            self.isAnimating = false
            self.startTexturePlayerIfNecessary()
        })
        
        sphereState = .small
    }

    // Play the grow transformation.
    func grow() {
        stopPlayer(texturePlayer)
        removeAnimationBehaviors()
        isAnimating = true
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.55,
                       initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            self.startPlayer(self.growPlayer)
            let newPosition = self.boundedSphereCenter(location: self.sphereView.layer.position,
                                                       radius: self.kSphereRadiusLarge)
            self.sphereView.layer.position = newPosition
            self.sphereView.bounds = CGRect(x: 0, y: 0,
                                            width: self.kSphereRadiusLarge * 2,
                                            height: self.kSphereRadiusLarge * 2)
            self.sphereView.layer.cornerRadius = self.kSphereRadiusLarge
        }, completion: { _ in
            self.addAnimationBehaviors()
            self.animator.updateItem(usingCurrentState: self.sphereView)
            self.isAnimating = false
            self.startTexturePlayerIfNecessary()
        })
        
        sphereState = .large
    }
    
    // Play the shield transformation.
    func shield() {
        let shieldAnimation = CASpringAnimation(keyPath: "borderWidth")
        shieldAnimation.fromValue = 0
        shieldAnimation.toValue = kMaxShieldWidth
        shieldAnimation.duration = 0.5
        shieldAnimation.damping = 9
        shieldAnimation.initialVelocity = 20.0
        
        CATransaction.setCompletionBlock {
            self.addAnimationBehaviors()
            self.animator.updateItem(usingCurrentState: self.sphereView)
            self.isAnimating = false
            self.startTexturePlayerIfNecessary()
        }
        
        stopPlayer(texturePlayer)
        removeAnimationBehaviors()
        
        // Start the player for haptics and audio.
        startPlayer(shieldPlayer)
        
        // Play the shield animation.
        isAnimating = true
        sphereView.layer.add(shieldAnimation, forKey: "Width")
        sphereView.layer.borderWidth = kMaxShieldWidth
        sphereState = .shield
    }
    
    // Play the implode transformation.
    func implode() {
        stopPlayer(texturePlayer)
        removeAnimationBehaviors()
        isAnimating = true
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.startPlayer(self.implodePlayer)
            let expandFactor: CGFloat = 0.9
            self.sphereView.bounds = CGRect(x: 0, y: 0, width: self.kSphereRadiusLarge * (expandFactor * 2),
                                            height: self.kSphereRadiusLarge * (expandFactor * 2))
            self.sphereView.layer.cornerRadius = self.kSphereRadiusLarge * expandFactor
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                let expandFactor: CGFloat = 1.1
                let newPosition = self.boundedSphereCenter(location: self.sphereView.layer.position,
                                                           radius: self.kSphereRadiusLarge * expandFactor)
                self.sphereView.layer.position = newPosition
                
                self.sphereView.bounds = CGRect(x: 0, y: 0, width: self.kSphereRadiusLarge * (expandFactor * 2),
                                                height: self.kSphereRadiusLarge * (expandFactor * 2))
                self.sphereView.layer.cornerRadius = self.kSphereRadiusLarge * expandFactor
            }, completion: { _ in
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1.0,
                               initialSpringVelocity: 20.0, options: [.curveEaseOut], animations: {
                    self.sphereView.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
                    self.sphereView.layer.cornerRadius = 0
                    self.sphereView.backgroundColor = self.kSphereImplosionColor
                }, completion: { _ in
                    self.animator.updateItem(usingCurrentState: self.sphereView)
                    self.isAnimating = false
                    self.sphereView.backgroundColor = self.kSphereColor
                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
                        if self.sphereState == .none && !self.isAnimating {
                            self.spawn(self.view.center)
                        }
                    })
                })
            })
        })
        
        sphereState = .none
    }
    
    func playShieldDamageAnimation(_ magnitude: Float) {
        let impactScaleFactor: CGFloat = 3.5
        let scaledImpact = CGFloat(magnitude) * impactScaleFactor
        let minImpact: CGFloat = 2
        let shrinkAmount = max(scaledImpact, minImpact)
        
        UIView.animate(withDuration: 0, delay: 0, options: [.curveEaseIn], animations: {
            if shrinkAmount >= self.sphereView.layer.borderWidth {
                self.sphereView.layer.borderWidth = 0
            } else {
                self.sphereView.layer.borderWidth -= shrinkAmount
            }
        }, completion: { _ in
            self.isAnimating = false
        })
    }
    
    private func addAnimationBehaviors() {
        // Add bounce, gravity, and collision behavior.
        animator.addBehavior(bounce)
        animator.addBehavior(gravity)
        animator.addBehavior(wallCollisions)
    }
    
    func removeAnimationBehaviors() {
        // Remove bounce, gravity, and collision behavior.
        animator.removeBehavior(bounce)
        animator.removeBehavior(gravity)
        animator.removeBehavior(wallCollisions)
    }
    
    private func boundedSphereCenter(location: CGPoint, radius: CGFloat) -> CGPoint {
        var boundedPosition = location
        
        if location.x - radius < view.frame.minX + wallPadding {
            boundedPosition.x = view.frame.minX + wallPadding + radius
        }
        if location.x + radius > view.frame.maxX - wallPadding {
            boundedPosition.x = view.frame.maxX - wallPadding - radius
        }
        if location.y - radius < view.frame.minY + wallPadding {
            boundedPosition.y = view.frame.minY + wallPadding + radius
        }
        if location.y + radius > view.frame.maxY - wallPadding {
            boundedPosition.y = view.frame.maxY - wallPadding - radius
        }
        
        return boundedPosition
    }
}

extension InspiredDController {
//    @StateObject var settings = FloorSettings()
    
    func createAndStartHapticEngine() {
        guard supportsHaptics else { return }
        
        // Create and configure a haptic engine.
        do {
            engine = try CHHapticEngine(audioSession: .sharedInstance())
        } catch let error {
            fatalError("Engine Creation Error: \(error)")
        }
        
        // The stopped handler alerts engine stoppage.
        engine.stoppedHandler = { reason in
            print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                print("Audio session interrupt.")
            case .applicationSuspended:
                print("Application suspended.")
            case .idleTimeout:
                print("Idle timeout.")
            case .notifyWhenFinished:
                print("Finished.")
            case .systemError:
                print("System error.")
            case .engineDestroyed:
                print("Engine destroyed.")
            case .gameControllerDisconnect:
                print("Controller disconnected.")
            @unknown default:
                print("Unknown error")
            }
            
            // Indicate that the next time the app requires a haptic, the app must call engine.start().
            self.engineNeedsStart = true
        }
        
        // The reset handler notifies the app that it must reload all of its content.
        // If necessary, it recreates all players and restarts the engine in response to a server restart.
        engine.resetHandler = {
            print("The engine reset --> Restarting now!")
            
            // Tell the app to start the engine the next time a haptic is necessary.
            self.engineNeedsStart = true
        }
        
        // Start the haptic engine to prepare it for use.
        do {
            try engine.start()
            
            // Indicate that the next time the app requires a haptic, the app doesn't need to call engine.start().
            engineNeedsStart = false
        } catch let error {
            print("The engine failed to start with error: \(error)")
        }
    }
    
//    func stopHaptics() {
//        engine.stop(completionHandler: )
//    }
    //    ==================================================================
    //                Step 2: Textures
    //    ==================================================================
    
    func initializeCollisionHaptics() {
        // Create a collision player for each ball state.
        let collisionPatternSmall = createPatternFromAHAP(wallTexture)!
        collisionPlayerSmall = try? engine.makePlayer(with: collisionPatternSmall)
        
        let collisionPatternLarge = createPatternFromAHAP(wallTexture)!
        collisionPlayerLarge = try? engine.makePlayer(with: collisionPatternLarge)
        
        let collisionPatternShield = createPatternFromAHAP(wallTexture)!
        collisionPlayerShield = try? engine.makePlayer(with: collisionPatternShield)
    }
    
    func initializeTextureHaptics() {
        // Create a texture player.
        let texturePattern = createPatternFromAHAP(floorTexture)!
        texturePlayer = try? engine.makeAdvancedPlayer(with: texturePattern)
        texturePlayer?.loopEnabled = true
    }
    
    func initializeSpawnHaptics() {
        // Create a pattern from the spawn asset.
        let pattern = createPatternFromAHAP("Spawn")!

        // Create a player from the spawn pattern.
        spawnPlayer = try? engine.makePlayer(with: pattern)
    }
    
    func initializeGrowHaptics() {
//        // Create a pattern from the grow asset.
//        let pattern = createPatternFromAHAP("Grow")!
//
//        // Create a player from the grow pattern.
//        growPlayer = try? engine.makePlayer(with: pattern)
    }
    
    func initializeShieldHaptics() {
//        // Create a pattern from the shield asset.
//        let pattern = createPatternFromAHAP("ShieldContinuous")!
//
//        // Create a player from the shield pattern.
//        shieldPlayer = try? engine.makePlayer(with: pattern)
    }
    
    func initializeImplodeHaptics() {
//        // Create a pattern from the implode asset.
//        let pattern = createPatternFromAHAP("Implode")!
//
//        // Create a player from the implode pattern.
//        implodePlayer = try? engine.makePlayer(with: pattern)
    }
    
    private func createPatternFromAHAP(_ filename: String) -> CHHapticPattern? {
        // Get the URL for the pattern in the app bundle.
        let patternURL = Bundle.main.url(forResource: filename, withExtension: "ahap")!
        
        do {
            // Read JSON data from the URL.
            let patternJSONData = try Data(contentsOf: patternURL, options: [])
            
            // Create a dictionary from the JSON data.
            let dict = try JSONSerialization.jsonObject(with: patternJSONData, options: [])
            
            if let patternDict = dict as? [CHHapticPattern.Key: Any] {
                // Create a pattern from the dictionary.
                return try CHHapticPattern(dictionary: patternDict)
            }
        } catch let error {
            print("Error creating haptic pattern: \(error)")
        }
        return nil
    }
    
    func startPlayer(_ player: CHHapticPatternPlayer) {
        guard supportsHaptics else { return }
        do {
            try startHapticEngineIfNecessary()
            try player.start(atTime: CHHapticTimeImmediate)
        } catch let error {
            print("Error starting haptic player: \(error)")
        }
    }
    
    func stopPlayer(_ player: CHHapticPatternPlayer) {
        guard supportsHaptics else { return }
        
        do {
            try startHapticEngineIfNecessary()
            try player.stop(atTime: CHHapticTimeImmediate)
        } catch let error {
            print("Error stopping haptic player: \(error)")
        }
    }
    
    func startTexturePlayerIfNecessary() {
        guard supportsHaptics, rollingTextureEnabled else { return }
        
        // Create and send a dynamic parameter with zero intensity at the start of
        // the texture playback. The intensity dynamically modulates as the
        // sphere moves, but it starts from zero.
        let zeroIntensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
                                                          value: 0,
                                                          relativeTime: 0)
        do {
            try startHapticEngineIfNecessary()
            try texturePlayer.sendParameters([zeroIntensityParameter], atTime: 0)
        } catch let error {
            print("Dynamic Parameter Error: \(error)")
        }
        
        startPlayer(texturePlayer)
    }
    
    func updateTexturePlayer(_ magnitude: Float) {
        // Create dynamic parameters for the updated intensity.
        let intensityValue = linearInterpolation(alpha: magnitude, min: 0.05, max: 0.45)
        let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
                                                          value: intensityValue,
                                                          relativeTime: 0)
        // Send dynamic parameter to the haptic player.
        do {
            try startHapticEngineIfNecessary()
            
            switch sphereState {
            case .none:
                break
            case .small, .large, .shield:
                try texturePlayer.sendParameters([intensityParameter],
                                                        atTime: 0)
            }
        } catch let error {
            print("Dynamic Parameter Error: \(error)")
        }
    }
    
    private func linearInterpolation(alpha: Float, min: Float, max: Float) -> Float {
        return min + alpha * (max - min)
    }
    
    func playCollisionHaptic(_ normalizedMagnitude: Float) {
        do {
            // Create dynamic parameters for the current magnitude.
            let intensityValue = linearInterpolation(alpha: normalizedMagnitude, min: 0.375, max: 1.0)
            let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
                                                              value: intensityValue,
                                                              relativeTime: 0)
            let volumeValue = linearInterpolation(alpha: normalizedMagnitude, min: 0.1, max: 1.0)
            let volumeParameter = CHHapticDynamicParameter(parameterID: .audioVolumeControl,
                                                              value: volumeValue,
                                                              relativeTime: 0)
            
            try startHapticEngineIfNecessary()
            
            switch sphereState {
            case .small:
                try collisionPlayerSmall.sendParameters([intensityParameter, volumeParameter], atTime: CHHapticTimeImmediate)
                try collisionPlayerSmall.start(atTime: CHHapticTimeImmediate)
            case .large:
                try collisionPlayerLarge.sendParameters([intensityParameter, volumeParameter], atTime: CHHapticTimeImmediate)
                try collisionPlayerLarge.start(atTime: CHHapticTimeImmediate)
            case .shield:
                try collisionPlayerShield.sendParameters([intensityParameter, volumeParameter], atTime: CHHapticTimeImmediate)
                try collisionPlayerShield.start(atTime: CHHapticTimeImmediate)
            default:
                print("No action for the collision during: \(sphereState)")
            }
        } catch let error {
                print("Haptic Playback Error: \(error)")
        }
    }
    
    func startHapticEngineIfNecessary() throws {
        if engineNeedsStart {
            try engine.start()
            engineNeedsStart = false
        }
    }
    
    func restartHapticEngine() {
        self.engine.start { error in
            if let error = error {
                print("Haptic Engine Startup Error: \(error)")
                return
            }
            self.engineNeedsStart = false
        }
    }
    
    func stopHapticEngine() {
        self.engine.stop { error in
            if let error = error {
                print("Haptic Engine Shutdown Error: \(error)")
                return
            }
            self.engineNeedsStart = true
        }
    }
}

extension InspiredDController {
    
    private var kMaxVelocity: Float { return 500 }
    
    var normalizedSphereVelocity: Float {
        let velocity = bounce.linearVelocity(for: bounce.items[0])
        let xVelocity = Float(velocity.x)
        let yVelocity = Float(velocity.y)
        let magnitude = sqrtf(xVelocity * xVelocity + yVelocity * yVelocity)
        return min(max(Float(magnitude) / kMaxVelocity, 0.0), 1.0)
    }
    
    func activateAccelerometer() {
        // Manage the motion events in a separate queue off of the main thread.
        motionQueue = OperationQueue()
        motionData = CMAccelerometerData()
        motionManager = CMMotionManager()
        
        guard let manager = motionManager else { return }
        
        manager.startDeviceMotionUpdates(to: motionQueue) { deviceMotion, error in
            guard let motion = deviceMotion else { return }
            
            let gravity = motion.gravity
            
            // Dispatch gravity updates back to the main queue because they affect the user interface.
            DispatchQueue.main.async {
                self.gravity.gravityDirection = CGVector(dx: gravity.x * 3.5,
                                                         dy: -gravity.y * 3.5)
            }
        }
    }
}

