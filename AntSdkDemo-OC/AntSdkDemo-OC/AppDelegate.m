//
//  AppDelegate.m
//  AntSdkDemo-OC
//
//  Created by 猜猜我是谁 on 2021/4/20.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AntSdkDemo-OC-Bridging-Header.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    AntCommandModule *manager = [AntCommandModule shareInstance];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    self.window.rootViewController = nav;
    
    [self setUpLaunchScreen];
    
    return YES;
}

- (void)setUpLaunchScreen {
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"gif"];
    
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef) fileUrl, NULL);           //将GIF图片转换成对应的图片源
    size_t frameCout = CGImageSourceGetCount(gifSource);                                         // 获取其中图片源个数，即由多少帧图片组成
    NSMutableArray *frames = [[NSMutableArray alloc] init];                                      // 定义数组存储拆分出来的图片
    for (size_t i = 0; i < frameCout; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL); // 从GIF图片中取出源图片
        UIImage *imageName = [UIImage imageWithCGImage:imageRef];                  // 将图片源转换成UIimageView能使用的图片源
        [frames addObject:imageName];                                              // 将图片加入数组中
        CGImageRelease(imageRef);
    }
    
    UIImageView *customLaunchImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 600)];
    customLaunchImageView.backgroundColor = [UIColor redColor];
    customLaunchImageView.userInteractionEnabled = YES;
    
    customLaunchImageView.animationImages = frames; // 将图片数组加入UIImageView动画数组中
    customLaunchImageView.animationDuration = 4; // 每次动画时长
    customLaunchImageView.animationRepeatCount = 1;
    [customLaunchImageView startAnimating];         // 开启动
    
    NSLog(@"[UIApplication sharedApplication].keyWindow = %@",[UIApplication sharedApplication].keyWindow);
    NSLog(@"self.window = %@",self.window);
    [[UIApplication sharedApplication].keyWindow addSubview:customLaunchImageView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:customLaunchImageView];
    
    //4秒后自动关闭
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.3 animations:^{
//            customLaunchImageView.alpha = 0;
//        } completion:^(BOOL finished) {
//            [customLaunchImageView removeFromSuperview];
//        }];
//    });
}


@end
