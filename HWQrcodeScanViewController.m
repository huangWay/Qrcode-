//
//  HWQrcodeScanViewController.m
//  ZBar
//
//  Created by 黄伟 on 14/7/16.
//  Copyright © 2014年 huangwei. All rights reserved.
//

#import "HWQrcodeScanViewController.h"
#import "HWWebViewController.h"
#define ImgViewImage @"qrcode_scanline_qrcode"//有效扫描区域内的图片，可以替换

@interface HWQrcodeScanViewController ()<ZBarReaderViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,strong) ZBarReaderView *reader;
//定时器
@property(nonatomic,strong) CADisplayLink *link;
//有效扫描区域
@property(nonatomic,strong) UIView *effectiveZone;
//有效区域内不断滚动的imageView
@property(nonatomic,strong) UIImageView *imgView;

//相册控制器
@property(nonatomic,strong) UIImagePickerController *picker;
@end

@implementation HWQrcodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openPhoto)];
    //创建readerView
    [self setUpReaderView];
    
    //创建有效扫描区域
    [self setUpEffeciveZone];
    
    //修建扫描区域，返回值是有效扫描区域，在上左下右各个方向上的长度与readerView对应方向上长度的比值
    self.reader.scanCrop = [self scanCropRect:self.effectiveZone.frame ratioInReaderViewBounds:self.reader.bounds];
    
    //创建有效区域里的图片
    [self setUpImageInEffectiveZone];
    
    [self.reader start];
    
    //开启定时器
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

//创建readerView
-(void)setUpReaderView{
    ZBarReaderView *reader = [[ZBarReaderView alloc]init];
    reader.frame = self.view.bounds;
    
    //设置代理
    reader.readerDelegate = self;
    [self.view addSubview:reader];
    self.reader = reader;
}

//创建有效扫描区域
-(void)setUpEffeciveZone{
    
    UIView *effectiveZone = [[UIView alloc]init];
    
    //拿到readerView的宽度
    CGFloat readerWidth = self.reader.bounds.size.width;
    
    //有效区域的frame
    effectiveZone.frame = CGRectMake(readerWidth*0.2, 150, readerWidth*0.6, readerWidth*0.6);
    
    //为view添加边框
    effectiveZone.layer.borderColor = [UIColor orangeColor].CGColor;
    effectiveZone.layer.borderWidth = 2;
    
    //把有效区域添加到readerView
    [self.reader addSubview:effectiveZone];
    self.effectiveZone = effectiveZone;
}

//创建有效区域内的图片
-(void)setUpImageInEffectiveZone{
    UIImage *image = [UIImage imageNamed:ImgViewImage];
    UIImageView *imgView = [[UIImageView alloc]init];
    imgView.image = image;
    
    //设置imgView的frame，一开始要在有效区域外
    CGRect frame = self.effectiveZone.bounds;
    frame.origin.y = -frame.size.height;
    imgView.frame = frame;
    [self.effectiveZone addSubview:imgView];
    
    //把超出有效区域的剪掉
    self.effectiveZone.layer.masksToBounds = YES;
    self.imgView = imgView;
}

//修建扫描区域，返回值是有效扫描区域，在上左下右各个方向上的长度与readerView对应方向上长度的比值
-(CGRect)scanCropRect:(CGRect)rect ratioInReaderViewBounds:(CGRect)rvBounds{
    
    //顶部的占比
    CGFloat top;
    
    //左侧占比
    CGFloat left;
    
    //底部占比
    CGFloat bottom;
    
    //右侧占比
    CGFloat right;
    
    //顶部占比 ＝ 有效扫描区域的y值/readerView的高度；
    top = rect.origin.y/rvBounds.size.height;
    
    //左侧占比 ＝ 有效扫描区域的x值/readerView的宽度；
    left = rect.origin.x/rvBounds.size.width;
    
    //底部占比 ＝ 有效区域底边的y值/readerView的高度
    bottom = CGRectGetMaxY(rect)/rvBounds.size.height;
    
    //右侧占比 ＝ 有效区域右边的y值/readerView的高度
    right = CGRectGetMaxX(rect)/rvBounds.size.width;
    return CGRectMake(top, left, bottom, right);

}

//navigationBar上的点击取消按钮，要做的事
-(void)cancelButtonClick{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//打开相册
-(void)openPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
    self.picker = picker;
}

#pragma mark -懒加载
-(CADisplayLink *)link{
    if (_link == nil) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshImageY)];
        _link.frameInterval = 2;
    }
    return _link;
}

//定时器不断调用，来让imgView的y值变化
-(void)refreshImageY{
    CGRect frm = self.imgView.frame;
    
#warning 有效扫描区域内图片的运动速度，可以改
    frm.origin.y += 10;
    if (frm.origin.y > frm.size.height) {
        frm.origin.y = -frm.size.height;
    }
    self.imgView.frame = frm;
}

#pragma mark -ZBarReaderViewDelegate
//ZBarReaderView扫描到二维码时调用
- (void) readerView: (ZBarReaderView*) readerView didReadSymbols: (ZBarSymbolSet*) symbols fromImage: (UIImage*) image{
    [NSThread sleepForTimeInterval:1];
    
    //如果有结果
    if (symbols.count > 0) {
        
        //停止扫描
        [readerView stop];
        
        //遍历结果
        for (ZBarSymbol *symbol in symbols) {
            NSString *result = symbol.data;
            
            //把结果告诉代理，让代理执行相应的动作
            if ([self.delegate respondsToSelector:@selector(scanViewController:result:)]) {
                [self.delegate scanViewController:self result:result];
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -UIImagePickerControllerDelegate
//选择相册图片时调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //从存有结果的数组中取出图片
    UIImage *selectImg = info[UIImagePickerControllerOriginalImage];
    
    ZBarReaderController *readerC = [[ZBarReaderController alloc]init];
    
    //读取图片
    id symbols = [readerC scanImage:selectImg.CGImage];
    
    //如果有结果
    if (symbols) {
       
        //遍历结果
        for (ZBarSymbol *symbol in symbols) {
            NSString *result = symbol.data;
            
            //告诉代理结果
            if ([self.delegate respondsToSelector:@selector(scanViewController:result:)]) {
                [self.delegate scanViewController:self result:result];
            }
        }
        
        //销毁扫描界面
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{//如果没有结果
        
        //弹出提示框
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:@"不能识别" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alert show];
        
    }
 
}

-(void)dealloc{
    [self.link invalidate];
    self.link = nil;
}
@end
