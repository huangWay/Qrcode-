//
//  ReadMe.m
//  HW-ZBar
//
//  Created by 黄伟 on 15/7/16.
//  Copyright (c) 2015年 huangwei. All rights reserved.
//

1.需要导入框架ZBarSDK,AVFoundation,CoreMedia,libiconv.dylib;

2.从其他控制器，进入HWQrcodeScanViewController

3.实现代理方法
 -(void)scanViewController:(HWQrcodeScanViewController *)qsVC result:(NSString *)result;

4.如果需要跳转到view是UIWebView的控制器上，那么在将要从当前扫描控制器跳转到的目标控制器时：
   4.1 目标控制器的viewWillAppear方法里，给控制器的一个属性赋值，
   4.2 这个属性将来是这个UIWebViewloadRequest里的request的url里的string（一般来说结果是NSString）