//
//  CommandViewController.m
//  AntSdkDemo-OC
//
//  Created by 猜猜我是谁 on 2021/4/20.
//

#import "CommandViewController.h"
#import "LogViewController.h"
#import "AntSdkDemo-OC-Bridging-Header.h"

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

@interface CommandViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataSourceArray;
@property(nonatomic,strong)NSArray *titleArray;

@end

@implementation CommandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-100)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIButton *logButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2.0-75, screenHeight-80, 150, 50)];
    [logButton setTitle:@"log显示" forState:(UIControlStateNormal)];
    [logButton addTarget:self action:@selector(logButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:logButton];
    
    self.titleArray = @[@"Information",@"Fitness data",@"Alarm/Notify",@"System control",@"Test (just for developers)"];
    
    self.dataSourceArray = [[NSMutableArray alloc] initWithArray:@[
        @[
            @"Get sn",
            @"Get Device Time",
            @"Get Battery level",
            @"(无回复)Get device worn status",
            @"(无回复)get serial number",
            @"(无回复)get distance unit",
            @"Get mac address",
            @"Set personal information",
            @"Set Sn",
            @"Set Time  Format",
            @"Set Device mode",
            @"Set Pairing phone type",
            @"Set Device Time",
            @"(无回复)Set Time Zone time",
            @"Set serial number",
            @"Set distance display unit"
        ],
        @[
            @"(回复格式长度错误)Get fitness value",
            @"(无回复)Get history data for automatic heart rate and BP measurement",
            @"(无回复)Get 5 minutes walking step data",
            @"Obtain the hr and bp values manually measured by the user, up to 100 groups",
            @"Get 1 min sleep data",
            @"(无回复)Get 5 minutes running step data",
            @"(无回复)Get climbing stairs historical data",
            @"(无回复)Get 1 minutes  cycling history data",
            @"Get  active minutes history data",
            @"Set Daily Walking Target(Steps target)",
            @"Heart rate measurement control",
            @"Erase Fitness Data",
            @"BP measurement control",
            @"Set the current sport mode",
            @"Update HR zone value to device",
            @"Set live steps control",
            @"Set sport mode pause",
            @"Synchronize the parameters of accurate blood pressure",
            @"(回复格式长度错误)Clear user bp data",
        ],
        @[
            @"Set Sedentary Alert info",
            @"Music status notification",
            @"(无回复)Set Message Alert Switchs",
            @"Send Message Content ",
            @"Set Alarm info",
            @"Set the DND mode",
            @"(无回复)Send Music Artist",
            @"(无回复)Send Music Name",
            @"Turn off message notifications"
        ],
        @[
            @"(无回复)Set reset system",
            @"(无回复)Set power off",
        ],
        @[
            @"(无回复)Get the 6-axis raw data",
            @"Get External flash ID",
            @"(回复格式长度错误)Get BP ID",
            @"Get device sport status",
            @"(无回复)Get the BP raw data",
            @"(无回复)Set motot para",
            @"Set day steps num",
            @"Control motor vibration",
        ]
    ]];
    
}

-(void)logButtonClick:(UIButton *)sender{
    LogViewController *vc = [[LogViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *sectionArray = self.dataSourceArray[section];
    return sectionArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    view.backgroundColor = [UIColor grayColor];//ViewBgColor
    view.userInteractionEnabled = YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, screenWidth-140, 50)];
    label.text = self.titleArray[section];
    [view addSubview:label];

    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commandCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"commandCell"];
    }
    
    NSArray *sectionArray = self.dataSourceArray[indexPath.section];
    cell.textLabel.text = sectionArray[indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = true;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *sectionArray = self.dataSourceArray[indexPath.section];
    NSString *rowString = sectionArray[indexPath.row];
    
//    rowString = [rowString stringByReplacingOccurrencesOfString:@"(回复格式长度错误)" withString:@""];
//    rowString = [rowString stringByReplacingOccurrencesOfString:@"(无回复)" withString:@""];
    /*
    if ([rowString containsString:@"Get sn"]) {
        [[AntCommandModule shareInstance] GetSn:^(NSString * _Nonnull success) {
            NSLog(@"GetSn->%@",success);
        }];
    }
    
    if ([rowString containsString:@"Get Device Time"]) {
        [[AntCommandModule shareInstance] GetDeviceTime:^(NSString * _Nonnull success) {
            NSLog(@"GetDeviceTime->%@",success);
        }];
    }
    
    if ([rowString containsString:@"Get Battery level"]) {
        [[AntCommandModule shareInstance] GetBatteryLevel:^(NSString * _Nonnull success) {
            NSLog(@"GetBatteryLevel->%@",success);
        }];
    }
    
    if ([rowString containsString:@"Get device worn status"]) {
        [[AntCommandModule shareInstance] GetDeviceWornStatus:^(NSString * _Nonnull success) {
            NSLog(@"GetDeviceWornStatus->%@",success);
        }];
    }
    
    if ([rowString containsString:@"get serial number"]) {
        [[AntCommandModule shareInstance] GetSerialNumber:^(NSString * _Nonnull success) {
            NSLog(@"GetSerialNumber->%@",success);
        }];
    }
    
    if ([rowString containsString:@"get distance unit"]) {
        [[AntCommandModule shareInstance] GetDistanceUnit:^(NSString * _Nonnull success) {
            NSLog(@"GetDistanceUnit->%@",success);
        }];
    }
    
    if ([rowString containsString:@"Get mac address"]) {
        [[AntCommandModule shareInstance] GetMacAddress:^(NSString * _Nonnull success) {
            NSLog(@"GetMacAddress->%@",success);
        }];
    }
    
    if ([rowString containsString:@"Set personal information"]) {

        NSArray *array = @[
            @"height:[0,255]",
            @"weight:[0,255]",
            @"strideLength:[0,255]",
            @"gender:[0,1] 0男1女"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"请输入用户资料设置" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *height = textArray[0];
            NSString *weight = textArray[1];
            NSString *strideLength = textArray[2];
            NSString *gender = textArray[3];
            
            [[AntCommandModule shareInstance] SetPersonalInformationWithHeight:height weight:weight strideLength:strideLength gender:gender success:^(NSString * _Nonnull success) {
                NSLog(@"SetPersonalInformation->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set Sn"]) {
        [[AntCommandModule shareInstance] SetSn:^(NSString * _Nonnull success) {
            NSLog(@"SetSn->%@",success);
        }];
    }

    if ([rowString containsString:@"Set Time  Format"]) {

        NSArray *array = @[
            @"[0,1] 0:24小时，1:12小时"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set Time  Format" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *format = textArray[0];
            
            [[AntCommandModule shareInstance] SetTimeFormatWithFormat:format success:^(NSString * _Nonnull success) {
                NSLog(@"SetTimeFormat->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set Device mode"]) {

        NSArray *array = @[
            @"[0,3] 0: normal，1: test，2: power off，3: reserve"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set Device mode" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *mode = textArray[0];
            
            [[AntCommandModule shareInstance] SetDeviceModeWithMode:mode success:^(NSString * _Nonnull success) {
                NSLog(@"SetDeviceMode->%@",success);
            }];
            
        }];

    }

    if ([rowString containsString:@"Set Pairing phone type"]) {

        NSArray *array = @[
            @"[0,1] 0: Andriod,1: IOS"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set Pairing phone type" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *type = textArray[0];
            
            [[AntCommandModule shareInstance] SetPairingPhoneTypeWithPhoneType:type success:^(NSString * _Nonnull success) {
                NSLog(@"SetPairingPhoneType->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set Device Time"]) {

        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
        
        NSArray *array = @[
            [format stringFromDate:[NSDate date]]
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认当前时间，格式错误可能闪退。yyyy-MM-dd HH:mm:ss or yyyy-MM-dd HH:mm:ss ±hhmm)" Message:@"Set Device Time" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *time = textArray[0];
            
            [[AntCommandModule shareInstance] SetDeviceTimeWithTime:time success:^(NSString * _Nonnull success) {
                NSLog(@"SetDeviceTimeWithTime->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set Time Zone time"]) {

        NSArray *array = @[
            @"+0000"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0，格式错误可能闪退。±hhmm)" Message:@"Set Time Zone time" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *zone = textArray[0];
            
            [[AntCommandModule shareInstance] SetTimeZoneTimeWithZone:zone success:^(NSString * _Nonnull success) {
                NSLog(@"SetTimeZoneTime->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set serial number"]) {

        NSArray *array = @[
            @"112233445566"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set serial number" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *serial = textArray[0];
            
            [[AntCommandModule shareInstance] SetSerialNumberWithSerial:serial success:^(NSString * _Nonnull success) {
                NSLog(@"SetSerialNumber->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set distance display unit"]) {

        NSArray *array = @[
            @"[0,1] 0: Km 1: Miles"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set distance display unit" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *type = textArray[0];
            
            [[AntCommandModule shareInstance] SetDistanceDisplayUnitWithType:type success:^(NSString * _Nonnull success) {
                NSLog(@"SetDistanceDisplayUnit->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Get fitness value"]) {

        NSArray *array = @[
            @"[0,1] today - 0 yesterday - 1"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get fitness value" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            
            [[AntCommandModule shareInstance] GetFitnessValueWithDay:day success:^(NSString * _Nonnull success) {
                NSLog(@"GetFitnessValue->%@",success);
            }];
            
        }];

    }

    if ([rowString containsString:@"Get history data for automatic heart rate and BP measurement"]) {

        NSArray *array = @[
            @"day:[0,15]",
            @"startHour:[0,23]",
            @"endHour:[0,23]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get history data for automatic heart rate and BP measurement" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            NSString *startHour = textArray[1];
            NSString *endHour = textArray[2];
            
            [[AntCommandModule shareInstance] GetHistoryDataWithDay:day startHour:startHour endHour:endHour success:^(NSString * _Nonnull success) {
                NSLog(@"GetHistoryData->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Get 5 minutes walking step data"]) {

        NSArray *array = @[
            @"day:[0,15]",
            @"startHour:[0,23]",
            @"endHour:[0,23]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get 5 minutes walking step data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            NSString *startHour = textArray[1];
            NSString *endHour = textArray[2];
            
            [[AntCommandModule shareInstance] Get5MinutesWalkingStepWithDay:day startHour:startHour endHour:endHour success:^(NSString * _Nonnull success) {
                NSLog(@"Get5MinutesWalkingStep->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Get Hourly walking data"]) {

        NSArray *array = @[
            @"day:[0,15]",
            @"startHour:[0,23]",
            @"endHour:[0,23]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get Hourly walking data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            NSString *startHour = textArray[1];
            NSString *endHour = textArray[2];
            
            [[AntCommandModule shareInstance] GetHourlyWalkingWithDay:day startHour:startHour endHour:endHour success:^(NSString * _Nonnull success) {
                NSLog(@"GetHourlyWalking->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Get 10 minutes sleep data"]) {

        NSArray *array = @[
            @"day:[0,15]",
            @"startHour:[0,23]",
            @"endHour:[0,23]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get 10 minutes sleep data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            NSString *startHour = textArray[1];
            NSString *endHour = textArray[2];
            
            [[AntCommandModule shareInstance] Get10MinutesSleepWithDay:day startHour:startHour endHour:endHour success:^(NSString * _Nonnull success) {
                NSLog(@"Get10MinutesSleep->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Obtain the hr and bp values manually measured by the user, up to 100 groups"]) {

        [[AntCommandModule shareInstance] ObtainValuesUpTo100Groups:^(NSString * _Nonnull success) {
            NSLog(@"ObtainValuesUpTo100Groups->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Get 1 min sleep data"]) {

        NSArray *array = @[
            @"day:[0,15]",
            @"startHour:[0,23]",
            @"endHour:[0,23]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get 1 min sleep data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            NSString *startHour = textArray[1];
            NSString *endHour = textArray[2];
            
            [[AntCommandModule shareInstance] Get1MinSleepWithDay:day startHour:startHour endHour:endHour success:^(NSString * _Nonnull success) {
                NSLog(@"Get1MinSleep->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Get 5 minutes running step data"]) {

        NSArray *array = @[
            @"day:[0,15]",
            @"startHour:[0,23]",
            @"endHour:[0,23]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get 5 minutes running step data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            NSString *startHour = textArray[1];
            NSString *endHour = textArray[2];
            
            [[AntCommandModule shareInstance] Get5MinutesRunningStepWithDay:day startHour:startHour endHour:endHour success:^(NSString * _Nonnull success) {
                NSLog(@"Get5MinutesRunningStep->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Get climbing stairs historical data"]) {

        NSArray *array = @[
            @"day:[0,15]",
            @"startHour:[0,23]",
            @"endHour:[0,23]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get climbing stairs historical data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            
            [[AntCommandModule shareInstance] GetClimbingStairsHistoricalWithDay:day success:^(NSString * _Nonnull success) {
                NSLog(@"GetClimbingStairsHistorical->%@",success);
            }];
            
        }];

    }
    
    
    if ([rowString containsString:@"Get 1 minutes  cycling history data"]) {

        NSArray *array = @[
            @"[0,1] today - 0 yesterday - 1"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get 1 minutes  cycling history data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            NSString *startHour = textArray[1];
            NSString *endHour = textArray[2];
            
            [[AntCommandModule shareInstance] Get1MinutesCyclingHistoryWithDay:day startHour:startHour endHour:endHour success:^(NSString * _Nonnull success) {
                NSLog(@"Get1MinutesCyclingHistory->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Get  active minutes history data"]) {

        NSArray *array = @[
            @"[0,1] today - 0 yesterday - 1"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get  active minutes history data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *day = textArray[0];
            
            [[AntCommandModule shareInstance] GetActiveMinutesHistoryWithDay:day success:^(NSString * _Nonnull success) {
                NSLog(@"GetActiveMinutesHistory->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set Daily Walking Target(Steps target)"]) {

        NSArray *array = @[
            @"[0,4294967295]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set Daily Walking Target(Steps target)" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *target = textArray[0];
            
            [[AntCommandModule shareInstance] SetDailyWalkingTargetWithTarget:target success:^(NSString * _Nonnull success) {
                NSLog(@"SetDailyWalkingTarget->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Heart rate measurement control"]) {

        NSArray *array = @[
            @"[1,2] 1- Start  2-Stop"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Heart rate measurement control" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *value = textArray[0];
            
            [[AntCommandModule shareInstance] HeartRateMeasurementControlWithValue:value success:^(NSString * _Nonnull success) {
                NSLog(@"HeartRateMeasurementControl->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Erase Fitness Data"]) {

        NSArray *array = @[
            @"type:[0,1] 0: Step  1:Sleep",
            @"day:[0,7]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Erase Fitness Data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *type = textArray[0];
            NSString *day = textArray[1];
            
            [[AntCommandModule shareInstance] EraseFitnessDataWithType:type day:day success:^(NSString * _Nonnull success) {
                NSLog(@"EraseFitnessData->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"BP measurement control"]) {

        NSArray *array = @[
            @"[0,1] 1- Start  2-Stop"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"BP measurement control" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *value = textArray[0];
            
            [[AntCommandModule shareInstance] BpMeasurementControlWithValue:value success:^(NSString * _Nonnull success) {
                NSLog(@"BpMeasurementControl->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set the current sport mode"]) {

        NSArray *array = @[
            @"mode:[0,5] 0-off ,1 - Walking,2 - Running,3 - Cycling,4 - Swimming,5 - Tai chi",
            @"environment:[0,1]  0-indoor,1-outdoor",
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set the current sport mode" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *mode = textArray[0];
            NSString *environment = textArray[1];
            
            [[AntCommandModule shareInstance] SetCurrentSportModeWithMode:mode environment:environment success:^(NSString * _Nonnull success) {
                NSLog(@"SetCurrentSportMode->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Update HR zone value to device"]) {

        NSArray *array = @[
            @"type:[0,5] 1: ENDURANCE，2: ANAEROBIC，3:RECOVERY，4:FAT BURN，5:THRESHOLD",
            @"value:[0,116] 此处默认0x76（116）",
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Update HR zone value to device" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *type = textArray[0];
            NSString *value = textArray[1];
            
            [[AntCommandModule shareInstance] UpdateHrZoneValueWithType:type value:value success:^(NSString * _Nonnull success) {
                NSLog(@"UpdateHrZoneValue->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set live steps control"]) {

        NSArray *array = @[
            @"[0,1] 1- Start  2-Stop"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set live steps control" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *value = textArray[0];
            
            [[AntCommandModule shareInstance] SetLiveStepsControlWithValue:value success:^(NSString * _Nonnull success) {
                NSLog(@"SetLiveStepsControl->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set sport mode pause"]) {

        NSArray *array = @[
            @"[0,1] 1- Start  2-Stop"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set sport mode pause" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *value = textArray[0];
            
            [[AntCommandModule shareInstance] SetSportModePauseWithValue:value success:^(NSString * _Nonnull success) {
                NSLog(@"SetSportModePause->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Synchronize the parameters of accurate blood pressure"]) {

        NSArray *array = @[
            @"dbp:[-255,255]",
            @"sbp:[-255,255]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Synchronize the parameters of accurate blood pressure" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *dbp = textArray[0];
            NSString *sbp = textArray[1];
            
            [[AntCommandModule shareInstance] SynchronizeParametersBloodPressureWithDbp:dbp sbp:sbp success:^(NSString * _Nonnull success) {
                NSLog(@"SynchronizeParametersBloodPressure->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Clear user bp data"]) {

        [[AntCommandModule shareInstance] ClearUserBp:^(NSString * _Nonnull success) {
            NSLog(@"ClearUserBp->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Set Sedentary Alert info"]) {

        NSArray *array = @[
            @"isOpen:[1,2] 1: open 2:close",
            @"startTime: HH:mm",
            @"endTime: HH:mm",
            @"interval:[0,255]"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set Sedentary Alert info" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *isOpen = textArray[0];
            NSString *startTime = textArray[1];
            NSString *endTime = textArray[1];
            NSString *interval = textArray[1];
            
            [[AntCommandModule shareInstance] SetSedentaryAlertInfoWithIsOpen:isOpen startTime:startTime endTime:endTime interval:interval success:^(NSString * _Nonnull success) {
                NSLog(@"SetSedentaryAlertInfo->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Music status notification"]) {

        NSArray *array = @[
            @"[1,2] 1: open 2:close"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Music status notification" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *status = textArray[0];
            
            [[AntCommandModule shareInstance] MusicStatusNotificationWithStatus:status success:^(NSString * _Nonnull success) {
                NSLog(@"MusicStatusNotification->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Send Message Content "]) {
        
        [[AntCommandModule shareInstance] SendMessageContent:^(NSString * _Nonnull success) {
            NSLog(@"SendMessageContent->%@",success);
        }];
        
    }
    
    if ([rowString containsString:@"Set Alarm info"]) {
        
        [[AntCommandModule shareInstance] SetAlarmInfo:^(NSString * _Nonnull success) {
            NSLog(@"SetAlarmInfo->%@",success);
        }];
        
    }
    
    if ([rowString containsString:@"Set the DND mode"]) {

        NSArray *array = @[
            @"[1,2] 1: open 2:close"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Set the DND mode" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *status = textArray[0];
            
            [[AntCommandModule shareInstance] SetDndModeWithStatus:status success:^(NSString * _Nonnull success) {
                NSLog(@"SetDndMode->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Send Music Artist"]) {
        
        [[AntCommandModule shareInstance] SendMusicArtist:^(NSString * _Nonnull success) {
            NSLog(@"SendMusicArtist->%@",success);
        }];
        
    }
    
    if ([rowString containsString:@"Set reset system"]) {
        
        [[AntCommandModule shareInstance] SetResetSystem:^(NSString * _Nonnull success) {
            NSLog(@"SetResetSystem->%@",success);
        }];
        
    }
    
    if ([rowString containsString:@"Set power off"]) {
        
        [[AntCommandModule shareInstance] SetPowerOff:^(NSString * _Nonnull success) {
            NSLog(@"SetPowerOff->%@",success);
        }];
        
    }
    
    if ([rowString containsString:@"Get the 6-axis raw data"]) {

        NSArray *array = @[
            @"[1,2] 1：start 2：stop"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get the 6-axis raw data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *type = textArray[0];
            
            [[AntCommandModule shareInstance] Get6AxisRawWithType:type success:^(NSString * _Nonnull success) {
                NSLog(@"Get6AxisRaw->%@",success);
            }];
            
        }];

    }
    
//    if ([rowString containsString:@"Get  MEMS sensor data"]) {
//
//        [[AntCommandModule shareInstance] GetMemsSensor:^(NSString * _Nonnull success) {
//            NSLog(@"GetMemsSensor->%@",success);
//        }];
//
//    }
    
    if ([rowString containsString:@"Get External flash ID"]) {

        [[AntCommandModule shareInstance] GetExternalFlashId:^(NSString * _Nonnull success) {
            NSLog(@"GetExternalFlashId->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Get BP ID"]) {

        [[AntCommandModule shareInstance] GetBpId:^(NSString * _Nonnull success) {
            NSLog(@"GetExternalFlashId->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Test GPS"]) {

        [[AntCommandModule shareInstance] TestGps:^(NSString * _Nonnull success) {
            NSLog(@"TestGps->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Get device sport status"]) {

        [[AntCommandModule shareInstance] GetDeviceSportStatus:^(NSString * _Nonnull success) {
            NSLog(@"GetDeviceSportStatus->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Get the BP raw data"]) {

        NSArray *array = @[
            @"[1,2] 1：start 2：stop"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Get the BP raw data" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *type = textArray[0];
            
            [[AntCommandModule shareInstance] GetBpRawWithType:type success:^(NSString * _Nonnull success) {
                NSLog(@"GetBpRaw->%@",success);
            }];
            
        }];

    }
    
    if ([rowString containsString:@"Set motot para"]) {

        [[AntCommandModule shareInstance] TestVibrato:^(NSString * _Nonnull success) {
            NSLog(@"TestVibrato->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Real Time Accelerate Data Notify "]) {

        [[AntCommandModule shareInstance] RealTimeAccelerateDataNotify:^(NSString * _Nonnull success) {
            NSLog(@"TestVibrato->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Test touch "]) {

        [[AntCommandModule shareInstance] TestTouch:^(NSString * _Nonnull success) {
            NSLog(@"TestVibrato->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Set day steps num"]) {

        [[AntCommandModule shareInstance] SetDayStepsNum:^(NSString * _Nonnull success) {
            NSLog(@"SetDayStepsNum->%@",success);
        }];

    }
    
    if ([rowString containsString:@"Control motor vibration"]) {

        NSArray *array = @[
            @"[1,2] 1：start 2：stop"
        ];
        
        [self presentTextFieldAlertVCWithTitle:@"提示(无效数据默认0)" Message:@"Control motor vibration" HolderStringArray:array CancelAction:^{
            
        } OkAction:^(NSArray *textArray) {
            NSString *type = textArray[0];
            
            [[AntCommandModule shareInstance] ControlMotorVibrationWithType:type success:^(NSString * _Nonnull success) {
                NSLog(@"ControlMotorVibration->%@",success);
            }];
            
        }];

    }
    */
}

-(void)presentTextFieldAlertVCWithTitle:(NSString *)title Message:(NSString *)message HolderStringArray:(NSArray *)holderStringArray CancelAction:(void (^)(void))cancelAction OkAction:(void (^)(NSArray *textArray))okAction{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    
    for (int i = 0; i < holderStringArray.count; i++) {
        [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = holderStringArray[i];
        }];
    }
    
    UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        cancelAction();
    }];
    
    UIAlertAction *okAC = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < holderStringArray.count; i++) {
            UITextField *textField = alertVC.textFields[i];
            [array addObject:textField.text];
        }
        
        okAction([NSArray arrayWithArray:array]);
    }];
    
    [alertVC addAction:cancelAC];
    [alertVC addAction:okAC];
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
    
}


//presentTextFieldAlertVC(title:String?,message:String?,holderStringArray:[String]? = [],cancel:String? = "取消" ,cancelAction:(()->())?,ok:String? = "确定" ,okAction:(([String])->())?){
//
//    let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
//
//    var cancel = cancel
//    if cancel == nil {
//        cancel = "取消"
//    }
//
//    var ok = ok
//    if ok == nil {
//        ok = "确定"
//    }
//
//    for item in holderStringArray ?? [] {
//        alertVC.addTextField { (textField) in
//            textField.placeholder = item
//        }
//    }
//
//    let cancelAC = UIAlertAction.init(title: cancel, style: .default) { (action) in
//        if let cancelAction = cancelAction{
//            cancelAction()
//        }
//    }
//
//    let okAC = UIAlertAction.init(title: ok, style: .default) { (action) in
//        var array = [String].init()
//        for i in stride(from: 0, to: holderStringArray?.count ?? 0, by: 1) {
//            let textField = alertVC.textFields?[i]
//            array.append(textField?.text ?? "")
//        }
//
//        if let okAction = okAction{
//            okAction(array)
//        }
//    }
//
//    alertVC.addAction(cancelAC)
//    alertVC.addAction(okAC)
//
//    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
//
//        alertVC.popoverPresentationController?.sourceView = self.view //要展示在哪里
//
//        alertVC.popoverPresentationController?.sourceRect = self.view.frame //箭头指向哪里
//
//    }
//
//    self.present(alertVC, animated: true, completion: nil)
//}

@end
