//
//  XLQRCodeScanCustomCaptureForiOS7VC.m
//  XLQRCodeExample
//
//  Created by 谢 雷 on 13-10-25.
//  Copyright (c) 2013年 谢 雷. All rights reserved.
//

#import "XLQRCodeScanCustomCaptureForiOS7VC.h"
#import <AVFoundation/AVFoundation.h>
#import "XLQRCodeScanResultVC.h"
#import <ZXingObjC.h>
#import "XLQRCodeUtilities.h"

@interface XLQRCodeScanCustomCaptureForiOS7VC(InternalUtilityMethods)
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;
@end

@implementation XLQRCodeScanCustomCaptureForiOS7VC(InternalUtilityMethods)

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
@interface XLQRCodeScanCustomCaptureForiOS7VC ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{

    NSUInteger _numbers;
}
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (nonatomic, weak) UIView *maskView;

- (BOOL) setupSession;


@end

@implementation XLQRCodeScanCustomCaptureForiOS7VC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 1;
    }];

    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Open Album", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(openAlbum)];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat width = MAX(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    UIView *maskView =[[UIView alloc] initWithFrame:CGRectMake((320-width)/2, 0, width, width)];
    maskView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:maskView];
    maskView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
    maskView.layer.borderWidth = (width-200)/2;
    self.maskView = maskView;
    
    _numbers = 0;
    
    __weak __typeof(&*self)weakSelf = self;
    
    if ([self setupSession]) {
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        captureVideoPreviewLayer.frame = self.view.bounds;
        [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.view.layer insertSublayer:captureVideoPreviewLayer below:[[self.view.layer sublayers] objectAtIndex:0]];
        self.captureVideoPreviewLayer = captureVideoPreviewLayer;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf.session startRunning];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 0;
    }];

    if (self.session) {
        [self.session stopRunning];
    }
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
    self.output = [[AVCaptureMetadataOutput alloc] init];

    dispatch_queue_t videoQueue = dispatch_queue_create("com.sunsetlakesoftware.colortracki ng.metadataqueue", NULL);
    [self.output setMetadataObjectsDelegate:self queue:videoQueue];

    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    if ([self.output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }

    
    [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    
    success = YES;
    return success;
}

#pragma mark - Action
- (void)checkQRImage:(UIImage*)image{
    
}

- (void)openAlbum{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)pushResultVC:(NSString *)qrString{
    
    XLQRCodeScanResultVC *qrCodeScanResultVC = [[XLQRCodeScanResultVC alloc] init];
    qrCodeScanResultVC.resultString = qrString;
    [self.navigationController pushViewController:qrCodeScanResultVC animated:YES];
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (originalImage) {
            if (originalImage.size.width == originalImage.size.height) {
                originalImage =  [XLQRCodeUtilities resetImageSizeBySize:originalImage withMaxSide:320];
            }
            ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:originalImage.CGImage];
            ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
            NSError *error = nil;
            
            ZXDecodeHints *hints = [ZXDecodeHints hints];
            ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
            ZXResult *result = [reader decode:bitmap hints:hints error:&error];
            
            if (error) {
                [XLQRCodeUtilities showAlertWithError:error];
            }else{
                if (result.barcodeFormat == kBarcodeFormatQRCode) {
                    [self.session stopRunning];
                    NSString *resultString = result.text;
                    resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSLog(@"resultString %@",resultString);
                    [self pushResultVC:resultString];
                }
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    _numbers ++;
    if (_numbers%20 == 1) {
        for (AVMetadataObject *object in metadataObjects) {
            if ([[object type] isEqualToString:AVMetadataObjectTypeQRCode]) {
                AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject *)object;
                if (code.stringValue.length) {
                    [self.session stopRunning];
                    NSLog(@"code.stringValue %@",code.stringValue);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self pushResultVC:code.stringValue];
                    });
                }
            }
        }
    }
}


@end
