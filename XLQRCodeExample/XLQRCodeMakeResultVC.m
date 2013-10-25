//
//  XLQRCodeMakeResultVC.m
//  XLQRCodeExample
//
//  Created by 谢 雷 on 13-10-24.
//  Copyright (c) 2013年 谢 雷. All rights reserved.
//

#import "XLQRCodeMakeResultVC.h"
#import <MessageUI/MessageUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "XLQRCodeUtilities.h"
@interface XLQRCodeMakeResultVC ()<UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation XLQRCodeMakeResultVC

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
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"More", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(moreAction)];
    self.qrImageView.image = self.qrImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)moreAction{

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"More Choices", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Save to image album", @""),NSLocalizedString(@"Send e-mail", @""), nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Save to image album", @"")]) {

        [self.activityIndicator startAnimating];
//        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
//        if (status == ALAuthorizationStatusAuthorized) {
//            UIImageWriteToSavedPhotosAlbum(self.qrImage, nil, nil, nil);
//        }
        __weak __typeof(&*self)weakSelf = self;

        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary writeImageToSavedPhotosAlbum:self.qrImage.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
            [weakSelf.activityIndicator stopAnimating];
            if (error) {
                [XLQRCodeUtilities showAlertWithError:error];
            }
        }];
        
    }

    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Send e-mail", @"")]) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            mailComposeViewController.mailComposeDelegate = self;
            [mailComposeViewController setMessageBody:@"This is a QRCode image." isHTML:NO];
            [mailComposeViewController setSubject:@"QRCode Image"];
            [mailComposeViewController addAttachmentData:UIImageJPEGRepresentation(self.qrImage, 1.0) mimeType:@"image/jpeg" fileName:@"XLQRCodeImage"];
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        }
    }

}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{

    [controller dismissViewControllerAnimated:YES completion:^{
        if (error) {
            [XLQRCodeUtilities showAlertWithError:error];
        }else{
        
        }
    }];
}
@end
