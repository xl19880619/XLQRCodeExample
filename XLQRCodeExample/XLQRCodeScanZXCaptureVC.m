//
//  XLQRCodeScanZXCaptureVC.m
//  XLQRCodeExample
//
//  Created by 谢 雷 on 13-10-23.
//  Copyright (c) 2013年 谢 雷. All rights reserved.
//

#import "XLQRCodeScanZXCaptureVC.h"
#import "XLQRCodeUtilities.h"
#import <ZXingObjC.h>
#import "XLQRCodeScanResultVC.h"
@interface XLQRCodeScanZXCaptureVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ZXCaptureDelegate>
@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic, weak) UIView *maskView;
@end

@implementation XLQRCodeScanZXCaptureVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{

    [self.capture.layer removeFromSuperlayer];
    self.capture = nil;
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 1;
    }];

    if (self.capture) {
        self.capture.delegate = self;
        [self.capture start];
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
    
    self.capture = [[ZXCapture alloc] init];
    [self.capture order_skip];
    self.capture.camera = self.capture.back;
    self.capture.rotation = 90.0f;
    self.capture.layer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.capture.layer];
    self.capture.delegate = self;
    [self.capture start];
    
    [self.view bringSubviewToFront:self.maskView];
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 0;
    }];
    self.capture.delegate = nil;
    [self.capture stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
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

#pragma mark - ZXCaptureDelegate
- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result{

    if (result.barcodeFormat == kBarcodeFormatQRCode) {
        self.capture.delegate = nil;
        [self.capture stop];
        NSString *resultString = result.text;
        resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"resultString %@",resultString);
        [self pushResultVC:resultString];
    }

}

- (void)captureSize:(ZXCapture *)capture
              width:(NSNumber *)width
             height:(NSNumber *)height{

}
@end
