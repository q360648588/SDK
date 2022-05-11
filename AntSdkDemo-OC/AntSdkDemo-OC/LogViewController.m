//
//  LogViewController.m
//  AntSdkDemo-OC
//
//  Created by 猜猜我是谁 on 2021/4/21.
//

#import "LogViewController.h"
#import "AntSdkDemo-OC-Bridging-Header.h"

@interface LogViewController ()

@property(nonatomic,strong)UITextView *textView;

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemTrash) target:self action:@selector(clearLog)];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.text = [AntSDKLog showLog];
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
}



-(void)clearLog {
    self.textView.text = nil;
    [AntSDKLog clear];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
