//
//  HWQrcodeScanViewController.h
//  ZBar
//
//  Created by 黄伟 on 14/7/16.
//  Copyright © 2014年 huangwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
@class HWQrcodeScanViewController;
@protocol HWQrcodeScanViewControllerDelegate <NSObject>

-(void)scanViewController:(HWQrcodeScanViewController *)qsVC result:(NSString *)result;
@end

@interface HWQrcodeScanViewController : UIViewController
@property(nonatomic,weak) id<HWQrcodeScanViewControllerDelegate> delegate;
@end
