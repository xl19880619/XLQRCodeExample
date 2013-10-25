//
//  XLQRCodeScanCustomCaptureVC.m
//  XLQRCodeExample
//
//  Created by 谢 雷 on 13-10-23.
//  Copyright (c) 2013年 谢 雷. All rights reserved.
//

#import "XLQRCodeScanCustomCaptureVC.h"
#import <AVFoundation/AVFoundation.h>

@interface XLQRCodeScanCustomCaptureVC(InternalUtilityMethods)
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;
@end

@implementation XLQRCodeScanCustomCaptureVC(InternalUtilityMethods)

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

@end

@interface XLQRCodeScanCustomCaptureVC ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

- (BOOL) setupSession;
- (void)captureStillImage;
@end

@implementation XLQRCodeScanCustomCaptureVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Action
- (BOOL) setupSession{

    BOOL success = NO;
    
	// Set torch and flash mode to auto
	if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOff]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeOff];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
	if ([[self backFacingCamera] hasTorch]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeOff]) {
				[[self backFacingCamera] setTorchMode:AVCaptureTorchModeOff];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
    
    // Init the device inputs
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    // Setup the still image file output
    self.output = [[AVCaptureVideoDataOutput alloc] init];
    [self.output setAlwaysDiscardsLateVideoFrames:YES];
    // Use RGB frames instead of YUV to ease color processing
	[self.output setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    dispatch_queue_t videoQueue = dispatch_queue_create("com.sunsetlakesoftware.colortracki ng.videoqueue", NULL);
	[self.output setSampleBufferDelegate:self queue:videoQueue];

    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    [self.session setSessionPreset:AVCaptureSessionPreset640x480];

    success = YES;
    return success;
}

- (void)captureStillImage{

}

#pragma mark - Action
- (void)checkQRImage:(UIImage*)image{

}

#pragma mark - delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

}
@end
