//
//  ParticlesViewController.swift
//  WeatherApp
//
//  Created by Мария Матичина on 4/20/20.
//  Copyright © 2020 Мария Матичина. All rights reserved.
//

import UIKit
import SpriteKit

class ParticlesViewController: SKView {
    
    var particles: SKEmitterNode!
      // SKEmitterNode - Источник различных эффектов частиц
    
    override func didMoveToSuperview() { // Tells the view that its superview changed.
        let scene = SKScene(size: self.frame.size) // сцена в пределах, котороый будут меняться частицы
        // scene = размерам нашего View
        scene.backgroundColor = UIColor.clear
        self.presentScene(scene) // отображаем эту сцену
        
        // MARK:- сделать фон ParticlesView прозрачным. Но прозрачным сделать его не можем, поэтому:
        // Transparency - прозрачность
        self.allowsTransparency = true // разрешить прозрачность
        self.backgroundColor = UIColor.clear
        
        // MARK: разместить частицы в нашей сцене
        particles = SKEmitterNode(fileNamed: "ParticleScene.sks")
        
        // MARK: на какой ширине экрана частицы будут размещаться
        particles.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height)
        
        /*
         position - The position of the node in its parent's coordinate system.
         CGPoint - Структура, которая содержит точку в двумерной системе координат.
         
         Когда изначально размещаем view - то он появляется в левом нижнем углу, чтобы разместить его вверху нужно:
         • нужно передвинуть его по оси x на половину ширигы экрана, потому что изначально он появляется: половина на экране, половина за пределами
         • поднять на высоту y
         */
        
        // MARK: в каких пределах должны генерироваться наши частицы
        particles.particlePositionRange = CGVector(dx: self.bounds.size.width, dy: 0)
        // particlePositionRang - Диапазон допустимых случайных значений для положения частицы.
        scene.addChild(particles) // добавляем particles на scene
        
    }
    
    func setParticles(_ image: UIImage) {
        particles.particleTexture = SKTexture(image: image) // Текстура, используемая для визуализации частицы
        // SKTexture - Изображение, декодированное на графическом процессоре, которое можно использовать для визуализации различных объектов SpriteKit
    }
}


