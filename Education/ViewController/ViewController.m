//
//  ViewController.m
//  Education
//
//  Created by Feicun on 15/4/15.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "ViewController.h"
#import "Circle.h"
#import "MonthView.h"
#import "HeadView.h"
#import "DayDetailViewController.h"

@interface ViewController() <ToadyClick, MonthDayClick>

@property (strong, nonatomic) MonthView *monthView;
@property (strong, nonatomic) HeadView *headView;

@property (nonatomic) int month;
@property (nonatomic) int year;
@property (nonatomic) int curDay;
@property (nonatomic) int chosenDay;
@end

@implementation ViewController

#pragma -mark 页面初始化
- (void)viewDidLoad {
    [super viewDidLoad];

    self.monthView = [[MonthView alloc] initWithFrame:NSMakeRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.monthView.delegate = self;
    [self.view addSubview:self.monthView];
    [self getCurDate];
    
    self.headView = [[HeadView alloc] initWithFrame:NSMakeRect(0, SCREEN_HEIGHT / 7 * 6, SCREEN_WIDTH, SCREEN_HEIGHT / 7)];
    self.headView.delegate = self;
    [self setHeadDate];
    [self.view addSubview:self.headView];
    
//    AVUser *user = [AVUser user];
//    user.username = @"test";
//    user.password = @"123123";
//    
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        NSLog(@"%@", error.localizedDescription);
//        if (succeeded && !error) {
//            NSLog(@"Success");
//        }
//    }];
    // Do any additional setup after loading the view.
}
//设置日历头
- (void)setHeadDate {
    self.headView.dateText = [NSString stringWithFormat:@"%i年%i月", self.year, self.month];
}

//设置年月为系统当前年月
- (void)getCurDate {
    NSDictionary *dict = self.monthView.curDate;
    self.month = [[dict objectForKey:@"Month"] intValue];
    self.year = [[dict objectForKey:@"Year"] intValue];
    self.curDay = [[dict objectForKey:@"Day"] intValue];
}
//判断某天是否可被编辑
- (BOOL)isEditable:(int)day {
    NSDictionary *dict = self.monthView.curDate;
    int month = [[dict objectForKey:@"Month"] intValue];
    int year = [[dict objectForKey:@"Year"] intValue];
    if ((day >= self.curDay && self.month == month && self.year == year) || (self.month > month && self.year == year) || self.year > year) {
        return YES;
    }
    return NO;
}

#pragma -mark 按钮响应函数
//点击 今天 按钮
- (void)clickToday {
    [self getCurDate];
    [self.monthView updateCalendarWithMonth:self.month withYear:self.year];
    [self setHeadDate];
}
//上个月
- (void)clickPrevious {
    if (self.month <= 1) {
        self.month = 12;
        self.year--;
    } else {
        self.month--;
    }
    [self.monthView updateCalendarWithMonth:self.month withYear:self.year];
    [self setHeadDate];
}
//下个月
- (void)clickNext {
    if (self.month >= 12) {
        self.month = 1;
        self.year++;
    } else {
        self.month++;
    }
    [self.monthView updateCalendarWithMonth:self.month withYear:self.year];
    [self setHeadDate];
}
//点击 DayView
- (void)clickMonthDay:(DayView *)dayView {
    //NSLog(@"%i", dayView.state);
    if (dayView.state == -1) {
        if (self.month <= 1) {
            self.month = 12;
            self.year--;
        } else {
            self.month--;
        }
        [self.monthView updateCalendarWithMonth:self.month withYear:self.year];
        [self setHeadDate];
    } else if (dayView.state == 1) {
        if (self.month >= 12) {
            self.month = 1;
            self.year++;
        } else {
            self.month++;
        }
        [self.monthView updateCalendarWithMonth:self.month withYear:self.year];
        [self setHeadDate];
    } else {
//        if ([self isEditable:dayView.day]) {
//            NSLog(@"OK!!!!!!");
        self.chosenDay = dayView.day;
        [self performSegueWithIdentifier:@"DayDetail" sender:self];
//        } else {
//            NSLog(@"NOOOOOOOOOOOOO!!!!");
//        }
    }
}
//跳转至 某天的页面
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DayDetail"]) {
        DayDetailViewController *controller = segue.destinationController;
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%i", self.chosenDay], @"Day", [NSString stringWithFormat:@"%i", self.month], @"Month", [NSString stringWithFormat:@"%i", self.year], @"Year", nil];
        controller.dateDict = dict;
        controller.isEditable = [self isEditable:self.chosenDay];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
@end
