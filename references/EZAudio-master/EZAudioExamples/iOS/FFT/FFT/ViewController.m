//
//  ViewController.m
//  FFT
//
//  Created by Syed Haris Ali on 12/1/13.
//  Updated by Syed Haris Ali on 1/23/16.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ViewController.h"

static vDSP_Length const FFTViewControllerFFTWindowSize = 4096;

int blue=0;

int v=3;

@implementation ViewController

//------------------------------------------------------------------------------
#pragma mark - Status Bar Style
//------------------------------------------------------------------------------

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

//------------------------------------------------------------------------------
#pragma mark - View Lifecycle
//------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSLog(@"Start.");
//    self.resultLabel.text = @"aaa";
    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }

    //
    // Setup time domain audio plot
    //
//    self.audioPlotTime.plotType = EZPlotTypeBuffer;
//    self.maxFrequencyLabel.numberOfLines = 0;
//
//    //
//    // Setup frequency domain audio plot
//    //
//    self.audioPlotFreq.shouldFill = YES;
//    self.audioPlotFreq.plotType = EZPlotTypeBuffer;
//    self.audioPlotFreq.shouldCenterYAxis = NO;
//
//    //
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    //
    self.microphone = [EZMicrophone microphoneWithDelegate:self];

    //
    // Create an instance of the EZAudioFFTRolling to keep a history of the incoming audio data and calculate the FFT.
    //
    self.fft = [EZAudioFFTRolling fftWithWindowSize:FFTViewControllerFFTWindowSize
                                         sampleRate:self.microphone.audioStreamBasicDescription.mSampleRate
                                           delegate:self];

    //
    // Start the mic
    //
    [self.microphone startFetchingAudio];
}
//
////------------------------------------------------------------------------------
//#pragma mark - EZMicrophoneDelegate
////------------------------------------------------------------------------------
//
//-(void)    microphone:(EZMicrophone *)microphone
//     hasAudioReceived:(float **)buffer
//       withBufferSize:(UInt32)bufferSize
// withNumberOfChannels:(UInt32)numberOfChannels
//{
//    //
//    // Calculate the FFT, will trigger EZAudioFFTDelegate
//    //
//    [self.fft computeFFTWithBuffer:buffer[0] withBufferSize:bufferSize];
//
//    __weak typeof (self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [weakSelf.audioPlotTime updateBuffer:buffer[0]
//                              withBufferSize:bufferSize];
//    });
//}
//
////------------------------------------------------------------------------------
//#pragma mark - EZAudioFFTDelegate
////------------------------------------------------------------------------------
//
//- (void)        fft:(EZAudioFFT *)fft
// updatedWithFFTData:(float *)fftData
//         bufferSize:(vDSP_Length)bufferSize
//{
//    float maxFrequency = [fft maxFrequency];
//    vDSP_Length maxFrequencyIndex = [fft maxFrequencyIndex];
//    NSLog(@"%lu\n",maxFrequencyIndex);
//    //blue=[7650,7700]
//    //green=[8100,8165]
//    //brown=[4200,4300]
//    //white=[7750,7780]
//    
//    
//    
//    
//    if (maxFrequency>6000) {
//        
//        if ([fft frequencyMagnitudeAtIndex:(vDSP_Length)716] > [fft frequencyMagnitudeAtIndex:(vDSP_Length)767]) {
//            
//            //
//            blue++;
//            
//        } else {
//            
//            //self.resultLabel.text = @"green";
//            blue--;
//            
//        }
//        
//    }
//    
//
//    
////    NSString *noteName = [EZAudioUtilities noteNameStringForFrequency:maxFrequency
////                                                        includeOctave:YES];
//
//    __weak typeof (self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//
//        if (blue>=4) {
//            
//            self.resultLabel.text = @"blue";
//            blue=0;
//            
//        }
//        
//        if (blue<=-3) {
//            
//            self.resultLabel.text = @"green";
//            blue=0;
//            
//        }
//        
////        if ((maxFrequency<7700)&&(maxFrequency>7650)) self.resultLabel.text = @"blue";
////        if ((maxFrequency<8165)&&(maxFrequency>8100)) self.resultLabel.text = @"green";
////        if ((maxFrequency<4300)&&(maxFrequency>4200)) self.resultLabel.text = @"brown";
//        
////        weakSelf.maxFrequencyLabel.text = [NSString stringWithFormat:@"Highest Note: %@,\nFrequency: %.2f", noteName, maxFrequency];
////        [weakSelf.audioPlotFreq updateBuffer:fftData withBufferSize:(UInt32)bufferSize];
//    });
//}
//

@end
