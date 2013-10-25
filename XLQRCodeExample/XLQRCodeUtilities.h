//
//  XLQRCodeUtilities.h
//  XLQRCodeExample
//
//  Created by 谢 雷 on 13-10-24.
//  Copyright (c) 2013年 谢 雷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface XLQRCodeUtilities : NSObject
+(UIImage*)resetImageSizeBySize:(UIImage*)image withMaxSide:(CGFloat)d;
+(void)showAlertWithError:(NSError *)error;
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
@end
