//
//  SparkleView.swift
//  LettersGame_iOS
//
//  Created by Volodymyr Yehorov on 05.01.2024.
//

import SwiftUI
import UIKit

// Define a struct that wraps the CAEmitterLayer in a UIView
struct SparkleView: UIViewRepresentable {

    @Binding var isAnimating: Bool
    var animationDuration: CGFloat = 4
    var birthRate: Float = 0

    init(isAnimating: Binding<Bool>, birthRate: Float) {
        self._isAnimating = isAnimating
        self.birthRate = birthRate
    }

    // Define a function that creates and returns the UIView
    func makeUIView(context: Context) -> UIView {
        // Create a UIView with a clear background
        let view = UIView()
        view.backgroundColor = .clear

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                // Set the view's frame to match the window's bounds
                view.frame = window.bounds
            }
        }

        // Create a CAEmitterLayer and add it to the view's layer
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 4)
        emitterLayer.emitterShape = .circle
        emitterLayer.emitterSize = CGSize(width: 100, height: 100)
        view.layer.addSublayer(emitterLayer)

        // Create a CAEmitterCell and configure its properties
        let cell = makeCell()

        // Store the emitter and the cell in the context's coordinator
        context.coordinator.emitter = emitterLayer
        context.coordinator.cell = cell

        return view
    }

    // Define a function that updates the UIView
    func updateUIView(_ uiView: UIView, context: Context) {
        if isAnimating {
            context.coordinator.startAnimation()
        }
        else {
            context.coordinator.stopAnimation()
        }
    }

    // Define a function that creates and returns a coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, birthRate: birthRate)
    }

// Create a CAEmitterCell and configure its properties
    private func makeCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "star_white")?.cgImage
        cell.birthRate = 0 // start with zero particles
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 150
        cell.emissionRange = CGFloat.pi * 2
        cell.scale = 0.2
        cell.scaleRange = 0.1
        cell.spin = 2
        cell.spinRange = 5

        cell.redRange = 50
        cell.redSpeed = 5
        cell.greenRange = 50
        cell.greenSpeed = 5
        cell.blueRange = 50
        cell.blueSpeed = 5

        return cell
    }

    private func addBasicAnimationTo(emitterLayer: CAEmitterLayer) {
        // Create a CABasicAnimation object to animate the birthRate property
        let birthRateAnimation = CABasicAnimation(keyPath: "birthRate")
        // Set the fromValue and toValue properties
        birthRateAnimation.fromValue = birthRate
        birthRateAnimation.toValue = 0
        // Set the duration and timingFunction properties
        birthRateAnimation.duration = animationDuration
        birthRateAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        // Add the animation to the emitterLayer
        emitterLayer.add(birthRateAnimation, forKey: "birthRate")

        // Create a CABasicAnimation object to animate the lifetime property
        let lifetimeAnimation = CABasicAnimation(keyPath: "lifetime")
        // Set the fromValue and toValue properties
        lifetimeAnimation.fromValue = 5
        lifetimeAnimation.toValue = 0
        // Set the duration and timingFunction properties
        lifetimeAnimation.duration = animationDuration
        lifetimeAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        // Add the animation to the emitterLayer
        emitterLayer.add(lifetimeAnimation, forKey: "lifetime")

        // Create a CABasicAnimation object to animate the position property
        let positionAnimation = CABasicAnimation(keyPath: "emitterPosition")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let window = windowScene.windows.first else { return }
        // Set the start and end points of the animation
        positionAnimation.fromValue = NSValue(cgPoint: CGPoint(x: window.bounds.width / 2, y: window.bounds.height * 3/4))
        positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: window.bounds.width / 2, y: window.bounds.height / 4))

        // Set the duration and timingFunction properties
        positionAnimation.duration = animationDuration - 1

        // Set the animation to stay at the final position when completed
        positionAnimation.fillMode = .forwards
        positionAnimation.isRemovedOnCompletion = false

        // Add the animation to the emitterLayer
        emitterLayer.add(positionAnimation, forKey: "emitterPosition")
    }

    // Define a class that acts as a coordinator
    class Coordinator {
        var parent: SparkleView
        var birthRate: Float

        init(parent: SparkleView, birthRate: Float) {
            self.parent = parent
            self.birthRate = birthRate
        }

        // Define properties to hold the emitter and the cell
        var emitter: CAEmitterLayer?
        var cell: CAEmitterCell?

        // Define a function that starts the animation
        func startAnimation() {
            // Set the birthRate of the cell
            cell?.birthRate = birthRate
            parent.addBasicAnimationTo(emitterLayer: emitter!)
            // Set the emitter's cells to an array containing the cell
            emitter?.emitterCells = [cell!]

            // Stop the animation
            DispatchQueue.main.asyncAfter(deadline: .now() + parent.animationDuration) {
                self.stopAnimation()
            }
        }

        // Define a function that stops the animation
        func stopAnimation() {
            // Set the birthRate of the cell to zero particles per second
            cell?.birthRate = 0
            emitter?.emitterCells = []
        }
    }
}
