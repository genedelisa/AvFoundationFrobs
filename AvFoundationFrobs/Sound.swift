//
//  Sound.swift
//  AvFoundationFrobs
//
//  Created by Gene De Lisa on 8/13/14.
//  Copyright (c) 2014 Gene De Lisa. All rights reserved.
//

import Foundation
import AVFoundation

/**
Plays an audion file (MP3) using an AVAudioPlayer and a MIDI file using AVMIDIPlayer.

:author: Gene De Lisa
*/

class Sound : NSObject {
    var avPlayer:AVAudioPlayer!
    var mp:AVMIDIPlayer!
    var soundbank:NSURL!
    
    override init() {
        super.init()
        readFileIntoAVPlayer()
        loadMIDIFile()
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayback, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    func stopAVPLayer() {
        if avPlayer.playing {
            avPlayer.stop()
            //self.playerTimer.invalidate()
        }
    }
    
    func toggleAVPlayer() {
        println("is playing \(avPlayer.playing)")
        if avPlayer.playing {
            avPlayer.pause()
        } else {
            setSessionPlayback()
            avPlayer.play()
            //            self.playerTimer = NSTimer.scheduledTimerWithTimeInterval(1,
            //                target:self,
            //                selector:"updatePlayerStatus:",
            //                userInfo:nil,
            //                repeats:true)
        }
    }
    
    /**
    Uses AvAudioPlayer to play a sound file.
    The player instance needs to be an instance variable. Otherwise it will disappear before playing.
    */
    func readFileIntoAVPlayer() {
        
        let fileURL:NSURL = NSBundle.mainBundle().URLForResource("modem-dialing-02", withExtension: "mp3")
        
        // the player must be a field. Otherwise it will be released before playing starts.
        var error: NSError?
        //        self.avPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: &error)
        self.avPlayer = AVAudioPlayer(contentsOfURL: fileURL, fileTypeHint: AVFileTypeMPEGLayer3, error: &error)
        if avPlayer == nil {
            if let e = error {
                println(e.localizedDescription)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"sessionInterrupted:",
            name:AVAudioSessionInterruptionNotification,
            object:avPlayer)
        
        println("playing \(fileURL)")
        avPlayer.delegate = self
        avPlayer.prepareToPlay()
        avPlayer.volume = 1.0
    }
    
    
    // MIDI funcs
    
    func toggleMIDIPlayer() {
        println("is playing \(mp.playing)")
        if mp.playing {
            //FIXME: bad access! go figure
            mp.stop()
        } else {
            mp.play({
                println("midi done")
            })
        }
    }
    
    func stopMIDIPLayer() {
        if mp.playing {
            mp.stop()
        }
    }
    
    func loadMIDIFile() {
        // Load a SoundFont or DLS file.
        self.soundbank = NSBundle.mainBundle().URLForResource("GeneralUser GS MuseScore v1.442", withExtension: "sf2")
        println("soundbank \(soundbank)")
        
        // a standard MIDI file.
        var contents:NSURL = NSBundle.mainBundle().URLForResource("ntbldmtn", withExtension: "mid")
        println("contents \(contents)")
        
        var error:NSError?
        self.mp = AVMIDIPlayer(contentsOfURL: contents, soundBankURL: soundbank, error: &error)
        if self.mp == nil {
            println("nil midi player")
        }
        if let e = error {
            println("Error \(e.localizedDescription)")
        }
        self.mp.prepareToPlay()
    }
    
    func playMIDIFile() {
        self.mp.play({
            println("midi done")
        })
        
        // or
        //        var completion:AVMIDIPlayerCompletionHandler = {println("done")}
        //        mp.play(completion)
    }
    
    // MARK: notification callbacks
    func sessionInterrupted(notification:NSNotification) {
        println("audio session interrupted")
        var p = notification.object as AVAudioPlayer
        p.stop()
    }
    
}


// MARK: AVAudioPlayerDelegate
extension Sound : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("finished playing \(flag)")
    }
    
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("\(error.localizedDescription)")
    }
    
}