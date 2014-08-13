//
//  ViewController.swift
//  AvFoundationFrobs
//
//  Created by Gene De Lisa on 8/13/14.
//  Copyright (c) 2014 Gene De Lisa. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var engine:AVAudioEngine!
    var playerNode:AVAudioPlayerNode!
    var mixer:AVAudioMixerNode!
    var sampler:AVAudioUnitSampler!
    var buffer:AVAudioPCMBuffer!
    /// soundbanks are either dls or sf2. see http://www.sf2midi.com/
    var soundbank:NSURL!
    let melodicBank:UInt8 = UInt8(kAUSampler_DefaultMelodicBankMSB)
    /// general midi number for marimba
    let gmMarimba:UInt8 = 12
    let gmHarpsichord:UInt8 = 6
    
    var sound:Sound = Sound()
    
    @IBOutlet var midiEventButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initAudioEngine()
        
        midiEventButton.addTarget(self, action: "hstart:", forControlEvents: .TouchDown)
        midiEventButton.addTarget(self, action: "hstop:", forControlEvents: .TouchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func play(sender: AnyObject) {
        playerNodePlay()
    }
    
    
    @IBAction func avPlay(sender: AnyObject) {
        sound.toggleAVPlayer()
    }
    
    @IBAction func midiPlay(sender: AnyObject) {
        sound.toggleMIDIPlayer()
    }
    
    func initAudioEngine () {
        let fileURL = NSBundle.mainBundle().URLForResource("modem-dialing-02", withExtension: "mp3")
        var error: NSError?
        let audioFile = AVAudioFile(forReading: fileURL, error: &error)
        //        let audioFile = AVAudioFile(forReading: fileURL, commonFormat: .PCMFormatFloat32, interleaved: false, error: &error)
        if let e = error {
            println(e.localizedDescription)
        }
        
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        engine.attachNode(playerNode)
        mixer = engine.mainMixerNode
        //engine.connect(playerNode, to: mixer, format: mixer.outputFormatForBus(0))
        
        engine.connect(playerNode, to: engine.mainMixerNode, format: audioFile.processingFormat)
        playerNode.scheduleFile(audioFile, atTime:nil, completionHandler:nil)
        
        // for the midi functionality
        initMIDI()
        
        if !engine.startAndReturnError(&error) {
            println("error couldn't start engine")
            if let e = error {
                println("error \(e.localizedDescription)")
            }
        }
        
        loadHarpsichord()
    }
    
    func initMIDI() {
        sampler = AVAudioUnitSampler()
        engine.attachNode(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        soundbank = NSBundle.mainBundle().URLForResource("GeneralUser GS MuseScore v1.442", withExtension: "sf2")
    }
    
    /**
    Uses an AVAudioPlayerNode to play an audio file.
    */
    func playerNodePlay() {
        if engine.running {
            playerNode.play()
        } else {
            var error: NSError?
            if !engine.startAndReturnError(&error) {
                println("error couldn't start engine")
                if let e = error {
                    println("error \(e.localizedDescription)")
                }
            } else {
                playerNode.play()
            }
        }
    }
    
    func loadHarpsichord() {
        var error:NSError?
        if !sampler.loadSoundBankInstrumentAtURL(soundbank, program: gmHarpsichord,
            bankMSB: melodicBank, bankLSB: 0, error: &error) {
                println("could not load soundbank")
        }
        if let e = error {
            println("error \(e.localizedDescription)")
        }
        self.sampler.sendProgramChange(gmHarpsichord, bankMSB: melodicBank, bankLSB: 0, onChannel: 0)
    }
    
    func hstart(sender: AnyObject) {
        self.sampler.startNote(65, withVelocity: 64, onChannel: 0)
    }
    
    func hstop(sender: AnyObject) {
        self.sampler.stopNote(65, onChannel: 0)
    }
    
}

