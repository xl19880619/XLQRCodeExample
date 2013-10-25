//
//  XLQRCodeMakeVC.m
//  XLQRCodeExample
//
//  Created by 谢 雷 on 13-10-23.
//  Copyright (c) 2013年 谢 雷. All rights reserved.
//

#import "XLQRCodeMakeVC.h"
#import "XLQRCodeMakeResultVC.h"
#import <ZXingObjC.h>
@interface XLQRCodeMakeVC ()<UITextViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation XLQRCodeMakeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIActivityIndicatorView *)activityIndicator{

    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.frame = self.view.bounds;
        [self.view addSubview:_activityIndicator];
    }
    return _activityIndicator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next Step", @"") style:UIBarButtonItemStyleDone target:self action:@selector(makeQRCodeImage)];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)makeQRCodeImage{

    if (self.textView.text.length > 0) {
        
        if ([self.textView isFirstResponder]) {
            [self.textView resignFirstResponder];
        }
        [self.activityIndicator startAnimating];
        NSError *error = nil;
        ZXMultiFormatWriter *qrWriter = [[ZXMultiFormatWriter alloc] init];
        ZXBitMatrix *result = [qrWriter encode:self.textView.text format:kBarcodeFormatQRCode width:500 height:500 error:&error];
        [self.activityIndicator stopAnimating];
        if (result) {
            CGImageRef image =  [[ZXImage imageWithMatrix:result] cgimage];
            UIImage *qrImage = [UIImage imageWithCGImage:image];
            [self pushQRCodeImage:qrImage];
        }else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alertView show];
        }
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Make Styles", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Use ZXingObjc SDK", @""),NSLocalizedString(@"Use API", @""), nil];
//        [actionSheet showInView:self.view];
    }
}

- (void)pushQRCodeImage:(UIImage *)qrCodeImage{
    XLQRCodeMakeResultVC *resultVC = [[XLQRCodeMakeResultVC alloc] init];
    resultVC.qrImage = qrCodeImage;
    [self.navigationController pushViewController:resultVC animated:YES];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{

    textView.text = @"";
    return YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Use ZXingObjc SDK", @"")]) {
        [self.activityIndicator startAnimating];
        NSError *error = nil;
        ZXMultiFormatWriter *qrWriter = [[ZXMultiFormatWriter alloc] init];
        ZXBitMatrix *result = [qrWriter encode:self.textView.text format:kBarcodeFormatQRCode width:500 height:500 error:&error];
        [self.activityIndicator stopAnimating];
        if (result) {
            CGImageRef image =  [[ZXImage imageWithMatrix:result] cgimage];
            UIImage *qrImage = [UIImage imageWithCGImage:image];
            [self pushQRCodeImage:qrImage];
        }else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alertView show];
        }
    }

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Use API", @"")]) {
        
    }

}
@end
