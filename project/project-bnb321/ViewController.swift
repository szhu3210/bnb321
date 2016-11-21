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
// 1.1 This application is able to classify different mechanical keyboards by analyzing the sound come from the keyboard, assuming that it works in a quiet environment.
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

//  I am using the peak frequency indices to classify the different switches, which is able to classify 2 switches. In order to make full use of the FFT data, I will improve this kind of classification method and use KNN algorithm instead to try to detect and classify more switches, which I believe is possible. --Troy 4/14/2016

//  I have built the test codes to test classification algorithm. --Troy 4/14/2016

//  In the final release, I will cancel the buffer which was used to record the collection of peak frequency indices and only record the first detected fft data and ultilize the KNN algorithm to classify the switches. Since it is a machine learning algorithm, I might integrate some learning process in the UI interface or in the background. --Troy 4/14/2016

//  I am implementing the machine learning algorithm to increase the accuracy of sound classification. --Troy 4/24/2016

//  Since different click sound has quite different FFT data so machine learning algorithm does not work. I now use an improved method using peak frequency index to classify the switches. --Troy 5/1/2016

//--------------------------------------------------------------------------------------------------------


import UIKit
import Charts

// This is the windows size which is used to calculate FFT.
let FFTViewControllerFFTWindowSize : vDSP_Length = 4096

// Defind windowSize as the same data above but in different type.
let windowSize = Int(FFTViewControllerFFTWindowSize)

// Set high pass value in order to filter the low frequency noise. 200 (index) -> 2153Hz.
let highpass: vDSP_Length = 700

// We integrated EZAudio library into our project.
class ViewController: UIViewController, EZMicrophoneDelegate, EZAudioFFTDelegate {

    //Define a timer
    var timer = NSTimer()
    
    //Define a timer flag
    var timerSet = 0
    
    //Define a buffer to store the fft data of a single stroke of key
    var buffer: [UInt] = []
    
    //Define a fft data buffer to store the fft data into a 2D array for calculation of average
    var fftbuffer: [[Double]] = []
    
    //Define a fft data buffer to store the 1200th data
    var buffer1200: [Double] = []
    
    //Define a temp array to temporarily store fft data
    var tempArray: [Double] = []
    
    //Define a calculated fftdata for plot
    var avgfftdata: [Double] = []
    
    //Define the result
    var result = ""
    
    //fftPlot to plot the fft chart
    @IBOutlet weak var fftPlot: BarChartView!
    
    //Define a set which stores the blue key characteristic frequency indices
    var bluemfi: Set<UInt> = []
    
    //Define a set which stores the green key characteristic frequency indices
    var greenmfi: Set<UInt> = []
    
    //Define a set which stores the white key characteristic frequency indices
    var whitemfi: Set<UInt> = []
    
    //Surrounding noise frequency marker and reset timer
    var mfi0 = 0
    var timerMfi0 = NSTimer()
    
    //This label is show the peak frequency.
    @IBOutlet weak var resultLabel: UILabel!
    
    //Set microphone
    var microphone: EZMicrophone!;
    
    //Set fft calculator
    var fft : EZAudioFFTRolling = EZAudioFFTRolling()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Set the mfi which is the pattern of each key switch
        setmfi()
        
        //Show "no data" on the screen at first
        fftPlot.noDataText = "No FFT Data"
        
        //Open the microphone and activate it
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
        
        // Reset the mfi0 back to 0 every second so that we can dynamically detect the surrounding noise and filter it accordingly.
        self.timerMfi0 = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "resetMfi0", userInfo: nil, repeats: true)

        // Set microphone and start to detect sound
        self.microphone = EZMicrophone(microphoneDelegate: self, startsImmediately: true)
        
        // Set fft calculator as rolling mode which is able to calculate accurate FFT result.
        self.fft = EZAudioFFTRolling(windowSize: FFTViewControllerFFTWindowSize, sampleRate:Float(self.microphone.audioStreamBasicDescription().mSampleRate), delegate: self)
        
        // Change the label to show frequency
        resultLabel.text = "frequency and result"
        
    }
    
    func resetMfi0() {
        
        // Reset the surrounding noise frequency index in every one second.
        self.mfi0 = 0
        
    }
    
    // This is to tell the fft calculate FFT result once received audio.
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        self.fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
        
    }

    // This is to show the FFT result once FFT is calculated.
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        
        //Overall mfi, this is to detect the surrounding noise frequency level in order to decide which threshold to use to filter the noise.
        let mfi = Int(fft.maxFrequencyIndex)
        
        //Update the surrounding noise frequency is the current one is the highest.
        if ((mfi>self.mfi0) && (mfi<100)) {
            
            self.mfi0 = mfi
            print("mfi0: \(self.mfi0)\n")

        }
        
        //Detect mfi (1), this is used to filter out the noise
        var mfi1 = mfi0
        for i in mfi0..<4096 {
            
            if (fft.fftData[i] > fft.fftData[mfi1]) {
                
                mfi1 = i
                
            }
            
        }
        
        //in-region mfi (2), this "region" is for detecting the keyboard stroke.
        var mfi2 = 701
        
        // Make a high pass filter for the fft data and calculate the max frequency index manually.
        for i in 701..<4096 {
            
            if (fft.fftData[i] > fft.fftData[mfi2]) {
                
                mfi2 = i
                
            }
            
        }
        
        // Show the max frequency in real time.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            // If detected peak frequency index is above 700, it means a keyboard stroke.
            if (mfi1 > 700) {
            
                //print mfi
                print(mfi2)
                
                if self.timerSet == 0 {
                    
                    //set timer, when timer is over erase the buffer
                    self.timerSet = 1
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "cleanBufferAndCalculateResult", userInfo: nil, repeats: false)
                    self.resultLabel.text = "Calculating..."
                    
                }
                
                //write to maxFrequency buffer
                self.buffer.append(UInt(mfi2))
                
                //write to fftData buffer
                for i in 0..<windowSize {
                    
                    self.tempArray.append(Double(fft.fftData[i]))
                    
                }
                
                self.fftbuffer.append(self.tempArray)
                
                //write to 1200 magnitude buffer
                self.buffer1200.append(10*log10(self.tempArray[1200]))
                
            }
            
        });
    }
    
    //When the timer is over, call this function to hide the nameLabel
    func cleanBufferAndCalculateResult() {
        
        //print buffer
        print(self.buffer)
        
        //calculate result
        self.result = classifier(buffer)
        
        //print result to log
        print("Result: \(self.result)\n")
        
        //print to screen
        self.printresult()
        
        //clean buffer
        buffer.removeAll()
        
        //clean buffer1200
        buffer1200.removeAll()
        
        //timer flag reset
        self.timerSet = 0
        
        //reset temp array
        self.tempArray = []
        
        //calculate fftplot
        var sum1 = 0.0
        
        for j in 0..<windowSize {
            
            for i in 0..<fftbuffer.count {
                
                sum1 += fftbuffer[i][j]
                
            }
            
            avgfftdata.append(sum1/Double(fftbuffer.count))
            sum1 = 0.0
            
        }
        
        //print fftPlot
        self.drawFFT(avgfftdata)
        
        //reset fftbuffer and avgfftdata
        fftbuffer = []
        avgfftdata = []
    
    }
    
    func drawFFT(fft: [Double]) {
        
        print("drawFFT")
        
        let dataPoints = fft
        
        var dataEntries: [BarChartDataEntry] = []
        
        var xValues: [String] = []
        
        print(dataPoints[windowSize-1])
        
        // set the FFT graph range
        let startPoint = 400
        
        let endPoint = 1600
        
        // update FFT graph data
        for i in startPoint..<endPoint {
            
            let dataEntry = BarChartDataEntry(value: 100+10*log10(dataPoints[i]), xIndex: i-startPoint)
            
            dataEntries.append(dataEntry)
            
            xValues.append("\(i)")
        }
        
        // update FFT graph (import data)
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "dB")
        
        // set FFT graph color
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        
        // set label position
        fftPlot.xAxis.labelPosition = .Bottom
        
        // update FFT graph (update)
        fftPlot.data = BarChartData(xVals: xValues, dataSet: chartDataSet)

    }
    
    func classifier(buffer: [UInt]) -> String {
        
        //calculate results from the buffer
        var isGreen = 0
        
        for x in buffer {
            
            if self.greenmfi.contains(x) {
                
                isGreen += 1
                
            }
            
        }
        
        var isWhite = 0
        
        for x in buffer {
            
            if self.whitemfi.contains(x) {
                
                isWhite += 1
                
            }
            
        }

        var isBlue = 0
        
        for x in buffer {
            
            if self.bluemfi.contains(x) {
                
                isBlue += 1
                
            }
            
        }
        
        // calculate the ratio
        let isGreenRatio = Double(isGreen) / Double(buffer.count)
        let isWhiteRatio = Double(isWhite) / Double(buffer.count)
        let isBlueRatio = Double(isBlue) / Double(buffer.count)
        
        // log the ratio
        print("\nGreen\tBlue\tWhite\n\(isGreenRatio)\t\t\(isBlueRatio)\t\t\(isWhiteRatio)\n")
        
        // classification algorithm
        if ((( isWhiteRatio >= 0.3 && ( buffer.count <= 5 ) ) || (isWhiteRatio > isGreenRatio*3) ) && (isWhiteRatio >= isBlueRatio)) {
            
            return "white"
            
        } else if ((isGreenRatio >= 0.3) && (isGreenRatio > isBlueRatio)) {
            
            return "green"
            
        } else if ( isBlueRatio >= 0.3 )  {
            
            return "blue"
            
        } else {
            
            return "Unknown"
            
        }
        
    }
    
    func setmfi() {
        
        // set the range of blue, green, white key switch
        for i in 700..<730 {
            
            bluemfi.insert(UInt(i))
            
        }
        
        for i in 800..<860 {
            
            bluemfi.insert(UInt(i))
            
        }
        
        for i in 786..<795 {
            
            bluemfi.insert(UInt(i))
            
        }
        
        for i in 1000..<1200 {
            
            bluemfi.insert(UInt(i))
            
        }
        
        for i in 730..<775 {
            
            greenmfi.insert(UInt(i))
            
        }
        
        for i in 875..<885 {
            
            greenmfi.insert(UInt(i))
            
        }
        
        for i in 1055..<1058 {
            
            greenmfi.insert(UInt(i))
            
        }
        
        for i in 770..<790 {
            
            whitemfi.insert(UInt(i))
            
        }
        
        for i in 890..<900 {
            
            whitemfi.insert(UInt(i))
            
        }
        
        for i in 735..<772 {
            
            whitemfi.insert(UInt(i))
            
        }
        
        for i in 850..<870 {
            
            whitemfi.insert(UInt(i))
            
        }
        
        for i in 725..<735 {
            
            whitemfi.insert(UInt(i))
            
        }
        
        for i in 875..<885 {
            
            whitemfi.insert(UInt(i))
            
        }
        
        for i in 839..<840 {
            
            whitemfi.insert(UInt(i))
            
        }
        
    }

    func printresult() {
        
        // print out the result onto the screen
        self.resultLabel.text = "Noise Freq. Index: \(mfi0)\nResult: \(self.result)"
        
    }
    
}