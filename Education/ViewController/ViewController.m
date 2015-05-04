//
//  ViewController.m
//  Education
//
//  Created by Feicun on 15/4/15.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "ViewController.h"
#import "MonthView.h"
#import "HeadView.h"
#import "User.h"
#import "Lesson.h"
#import "DayDetailViewController.h"

@interface ViewController() <ToadyClick, MonthDayClick>

@property (strong, nonatomic) MonthView *monthView;
@property (strong, nonatomic) HeadView *headView;

@property (nonatomic) int month;
@property (nonatomic) int year;
@property (nonatomic) int curDay;
@property (nonatomic) DayView *chosenDay;

@property (strong, nonatomic) User *teacher;
@property (strong, nonatomic) NSMutableArray *tchLessonArray;

@end

@implementation ViewController

#pragma -mark 页面初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDayLesson:) name:@"ChosenLesson" object:nil];
    self.monthView = [[MonthView alloc] initWithFrame:NSMakeRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.monthView.delegate = self;
    [self.view addSubview:self.monthView];
    [self getCurDate];
    
    self.headView = [[HeadView alloc] initWithFrame:NSMakeRect(0, SCREEN_HEIGHT / 7 * 6, SCREEN_WIDTH, SCREEN_HEIGHT / 7)];
    self.headView.delegate = self;
    [self setHeadDate];
    [self.view addSubview:self.headView];
    
    [self initButton];
}

- (void)initButton {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teacherSelected:) name:@"TeacherSelected" object:nil];
    NSButton *tchBtn = [[NSButton alloc] initWithFrame:NSMakeRect(240, SCREEN_HEIGHT - 30, 100, 25)];
    tchBtn.title = @"选择老师";
    [tchBtn setButtonType:NSMomentaryPushInButton];
    //响应点击事件 需要设置 action 和 target
    [tchBtn setAction:@selector(selectTeacher:)];
    [tchBtn setTarget:self];
    tchBtn.bezelStyle = NSRoundRectBezelStyle;
    [self.view addSubview:tchBtn];
}

- (void)teacherSelected:(NSNotification *)notification {
    self.teacher = [notification.userInfo objectForKey:@"Teacher"];
    NSLog(@"%@", self.teacher.username);
    self.tchLessonArray = [[NSMutableArray alloc] init];
    [self initViewWithData];
}

- (void)initViewWithData {
    [self loadLessonDataFromCloud];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    for (Lesson *lesson in self.tchLessonArray) {
        NSString *lessonDate = [dateFormatter stringFromDate:lesson.startTime];
        for (DayView *dayView in self.monthView.allDay) {
            NSString *dayDate = [NSString stringWithFormat:@"%i-%02i-%02i", dayView.year, dayView.month, dayView.day];
            if ([lessonDate isEqualToString:dayDate]) {
                [dayView showWithType:lesson.lessonType];
            }
        }
    }
}
- (void)loadLessonDataFromCloud {
    [self.tchLessonArray removeAllObjects];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
//    NSString *dateStr = [NSString stringWithFormat:@"%@-%02i-%02i", [self.dateDict objectForKey:@"Year"], [[self.dateDict objectForKey:@"Month"] intValue], [[self.dateDict objectForKey:@"Day"] intValue]];
    NSDate *start = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", self.monthView.firstDate]];
    NSDate *end = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:59:59", self.monthView.lastDate]];
    //nsdate *start = []
    AVQuery *query = [AVQuery queryWithClassName:@"Lesson"];
    [query whereKey:@"startTime" greaterThan:start];
    [query whereKey:@"endTime" lessThan:end];
    [query whereKey:@"teacher" equalTo:self.teacher.objectId];
    NSArray *lesArr = [query findObjects];
    for (AVObject *obj in lesArr) {
        Lesson *lesson = [[Lesson alloc] initWithCloudLesson:obj andTeacher:self.teacher];
        [self.tchLessonArray addObject:lesson];
    }
    NSLog(@"%li", self.tchLessonArray.count);
}

- (void)selectTeacher:(NSButton *)sender {
    [self performSegueWithIdentifier:@"SelectTeacher" sender:self];
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
    if (self.teacher) {
        [self initViewWithData];
    }
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
    if (self.teacher) {
        [self initViewWithData];
    }
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
    if (self.teacher) {
        [self initViewWithData];
    }
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
        self.chosenDay = dayView;
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
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%i", self.chosenDay.day], @"Day", [NSString stringWithFormat:@"%i", self.month], @"Month", [NSString stringWithFormat:@"%i", self.year], @"Year", nil];
        controller.dateDict = dict;
        if (self.teacher) {
            controller.teacher = self.teacher;
        }
        controller.isEditable = [self isEditable:self.chosenDay.day];
    }
}

- (void)showDayLesson:(NSNotification *)notification {
    NSMutableArray *type = [notification.userInfo objectForKey:@"LessonTypes"];
    [self.chosenDay showWithLessonType:type];
}

//- (void)setRepresentedObject:(id)representedObject {
//    [super setRepresentedObject:representedObject];
//
//    // Update the view, if already loaded.
//}
@end
