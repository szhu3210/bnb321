//
//  ViewController.swift
//  project-bnb321
//
//  Created by Troy on 3/1/16.
//  Copyright © 2016 Troy. All rights reserved.
//

//--------------------------------------------------------------------------------------------------------

// requirements

// ECE 473/573 Project
// Requirements
// Ce Wang, Shengxiang Zhu
// 3/31/2016
//
// (B requirements)
// 1.1 This application is able to classify different mechanical keyboards by analyzing the sound come from the keyboard, assuming that  it works in a quiet environment.
// 1.2 This application would display the result of classification given a certain sound input.
// 1.3 This application would be able to classify at least 2 kinds of typical mechanical keyboard switch.
//
// (A requirements)
// 2.1 This application could work in a normal environment where there might be some noise.
// 2.2 This application would be able to display the FFT graph of the input signal.
// 2.3 This application would be able to classify at least 3 kinds of switches.



//--------------------------------------------------------------------------------------------------------


//  Notes:

//  The above is the requirements of this project. I posted it here for our convenience.  --Troy 3/2/2016

//  We will develop this app on iOS 9.2. Make sure the iPhone is upgraded into iOS 9.2. --Troy 3/2/2016

//  I'm considering which API to use, the AudioKit.io or the EZAudio. I will test them and decide. --Troy 3/2/2016

//  I installed the EZAudio Framework via CocoaPod to this project in order to implement the FFT quickly and easily. PLease make sure that when open the project, always open the xcworkspace file, not the xcodeproj file! --Troy 3/2/2016

//  For the FFT, we can refer to the sample code of EZAudioSample which is in the EZAudio-Swift-master folder. --Troy 3/2/2016

//  I have constructed the structure of our project, which is now able to receive audio in real time and do FFT and the real-time magnitude-frequency relationship. --Troy 3/9/2016


//--------------------------------------------------------------------------------------------------------


import UIKit

// This is the windows size which is used to calculate FFT.
let FFTViewControllerFFTWindowSize : vDSP_Length = 4096
//var blue=0
//var v=3

// We integrated EZAudio library into our project.
class ViewController: UIViewController, EZMicrophoneDelegate, EZAudioFFTDelegate {

    //This label is show the peak frequency.
    @IBOutlet weak var resultLabel: UILabel!
    
    //Set microphone
    var microphone: EZMicrophone!;
    
    //Set fft calculator
    var fft : EZAudioFFTRolling = EZAudioFFTRolling()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Open the microphone
        let session = AVAudioSession.sharedInstance()
   
        do {
            
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        } catch {
        
            // error
            
        }
        
        do {
            
            try session.setActive(true)
            
        } catch {
            
            // error
            
        }

        // Set microphone and start to detect sound
        self.microphone = EZMicrophone(microphoneDelegate: self, startsImmediately: true)
        
        // Set fft calculator as rolling mode which is able to calculate accurate FFT result.
        self.fft = EZAudioFFTRolling(windowSize: FFTViewControllerFFTWindowSize, sampleRate:Float(self.microphone.audioStreamBasicDescription().mSampleRate), delegate: self)
        
        // Change the label to show frequency
        resultLabel.text = "frequency"
        
    }
    
    // This is to tell the fft calculate FFT result once received audio.
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        self.fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
        
    }

    // This is to show the FFT result once FFT is calculated.
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        
        // This is to get the max frequency.
        let maxFrequency = fft.maxFrequency
        //let maxFrequencyIndex = fft.maxFrequencyIndex
        
        // Show the max frequency in real time.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.resultLabel.text = "\(maxFrequency) Hz"
            //self.audioPlotTime.updateBuffer(buffer[0], withBufferSize: bufferSize);
            
        });
    }

}



























































