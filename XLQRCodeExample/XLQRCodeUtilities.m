//
//  XLQRCodeUtilities.m
//  XLQRCodeExample
//
//  Created by 谢 雷 on 13-10-24.
//  Copyright (c) 2013年 谢 雷. All rights reserved.
//

#import "XLQRCodeUtilities.h"
@implementation XLQRCodeUtilities
+(UIImage*)resetImageSizeBySize:(UIImage*)image withMaxSide:(CGFloat)d{
    CGFloat width = image.size.width;
	CGFloat height = image.size.height;
    if(width<d&&height<d){
        d = MAX(width, height);
    }
    CGFloat newWidth;
    CGFloat newHeight;
    if (width>=height) {
        if (width<d) {
            newWidth = width;
            newHeight = height;
        }
        else{
            newWidth = d;
            newHeight = d*height/width;
        }
    }
    else{
        
        if (height<d) {
            newHeight = height;
            newWidth = width;
        }
        else{
            newHeight = d;
            newWidth = d*width/height;
        }
    }
    UIGraphicsBeginImageContext(CGSizeMake((int)newWidth, (int)newHeight));
	[image drawInRect:CGRectMake(0, 0,(int)newWidth, (int)newHeight)];
    UIImage *t_image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return  t_image;
}

+(void)showAlertWithError:(NSError *)error{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
    [alertView show];
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}
@end
