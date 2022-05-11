//
//  ViewController.m
//  AntSdkDemo-OC
//
//  Created by 猜猜我是谁 on 2021/4/20.
//

#import "ViewController.h"
#import "AntSdkDemo-OC-Bridging-Header.h"
#import "CommandViewController.h"
#import <zlib.h>

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataSourceArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-100)];//UITableView.init(frame: .init(x: 0, y: 0, width: screenWidth, height: screenHeight-100))
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    UIButton *scanButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2.0-75, screenHeight-80, 150, 50)];
    scanButton.backgroundColor = [UIColor redColor];
    [scanButton setTitle:@"扫描" forState:(UIControlStateNormal)];
    [scanButton addTarget:self action:@selector(scanButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:scanButton];
    
    Byte byte = 0x01;
    NSData *data = [[NSData alloc] initWithBytes:&byte length:1];
    
    NSLog(@"data = %@",data);
    
    uLong  crc = crc32(0L, data.bytes, (uInt)data.length);
    NSLog(@"crc = %lu",crc);
    
    NSLog(@"myCrc32With = %u",[self myCrc32With:data]);
    
    NSLog(@"%x",crc);
    
    
}

-(uint32_t)myCrc32With:(NSData *)data
{
    uint32_t *table = malloc(sizeof(uint32_t) * 256);
    uint32_t crc = 0xffffffff;
    uint8_t *bytes = (uint8_t *)[data bytes];
    
    for (uint32_t i=0; i<256; i++) {
        table[i] = i;
        for (int j=0; j<8; j++) {
            if (table[i] & 1) {
                table[i] = (table[i] >>= 1) ^ 0xedb88320;
            } else {
                table[i] >>= 1;
            }
        }
    }
    
    for (int i=0; i<data.length; i++) {
        crc = (crc >> 8) ^ table[(crc & 0xff) ^ bytes[i]];
    }
    crc ^= 0xffffffff;
    
    free(table);
    return crc;
}

-(void)scanButtonClick:(UIButton *)sender{
    [self.dataSourceArray removeAllObjects];
    [self.tableView reloadData];
    
    [[AntCommandModule shareInstance] scanDeviceWithScanModel:^(AntScanModel * _Nonnull model) {

    } modelArray:^(NSArray<AntScanModel *> * _Nonnull modelArray) {
        self.dataSourceArray = [NSMutableArray arrayWithArray:modelArray];
        [self.tableView reloadData];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSourceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scanCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"scanCell"];
    }
    
    AntScanModel *model = self.dataSourceArray[indexPath.row];
        
    cell.textLabel.text = [NSString stringWithFormat:@"%@    %ld",model.name,(long)model.rssi];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",model.uuidString];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[AntCommandModule shareInstance] disconnect];
    [[AntCommandModule shareInstance] stopScan];
    
    AntScanModel *model = self.dataSourceArray[indexPath.row];
    
    [[AntCommandModule shareInstance] connectDeviceWithPeripheral:model.uuidString connectState:^(BOOL result) {
        
        if (result) {
            
            NSLog(@"连接成功 -> %@,%@",model.name,model.uuidString);
            
            CommandViewController *vc = [[CommandViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];

}

@end
