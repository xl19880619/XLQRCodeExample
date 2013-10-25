//
//  XLQRCodeScanResultVC.m
//  XLQRCodeExample
//
//  Created by 谢 雷 on 13-10-24.
//  Copyright (c) 2013年 谢 雷. All rights reserved.
//

#import "XLQRCodeScanResultVC.h"

@interface XLQRCodeScanResultVC ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *resultButton;

@end

@implementation XLQRCodeScanResultVC

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
    // Do any additional setup after loading the view from its nib.
    self.resultLabel.text = self.resultString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)openURLAction:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.resultString]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.resultString]];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"Can not open the URL.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [alertView show];
    }
}

@end
