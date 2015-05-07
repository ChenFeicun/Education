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
#import "DayDetailViewController.h"

@interface ViewController() <ToadyClick, MonthDayClick, NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) MonthView *monthView;
@property (strong, nonatomic) HeadView *headView;

@property (nonatomic) int month;
@property (nonatomic) int year;
@property (nonatomic) int curDay;
@property (nonatomic) DayView *chosenDay;

@property (strong, nonatomic) User *selectUser;
@property (strong, nonatomic) NSMutableArray *tchLessonArray;


@property (strong, nonatomic) NSSearchField *userSF;
@property (strong, nonatomic) NSTableView *userTV;
@property (strong, nonatomic) NSMutableArray *tableArr;
@property (strong, nonatomic) NSMutableArray *userArr;
@property (strong, nonatomic) NSScrollView *tvScroll;
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
    
#warning 必须等AVOS初始化成功后才能使用 故延时1.5f
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(timerEnded:) userInfo:nil repeats:NO];
}

- (void)timerEnded:(NSTimer *)timer {
    [timer invalidate];
    timer = nil;
    [self loadUserDataFromCloud];
    [self initSearch];
}

- (void)initSearch {
    self.tchLessonArray = [[NSMutableArray alloc] init];
    
    self.userSF = [[NSSearchField alloc] initWithFrame:NSMakeRect(240, SCREEN_HEIGHT - 30, 100, 25)];
    self.userSF.target = self;
    self.userSF.action = @selector(searchUser:);
    [self.view addSubview:self.userSF];
    
    self.userTV = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    self.userTV.dataSource = self;
    self.userTV.delegate = self;
    
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"NameCol"];
    [[column headerCell] setStringValue:@"结果"];
    //[[column headerCell] setHidden:YES];
    [column setWidth:100.0];
    [column setEditable:NO];
    [column setResizingMask:NSTableColumnAutoresizingMask | NSTableColumnUserResizingMask];
    [self.userTV addTableColumn:column];
    
    
    self.tvScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(240, SCREEN_HEIGHT - 130, 100, 100)];
    self.tvScroll.hasVerticalScroller = YES;
    self.tvScroll.hasHorizontalScroller = NO;
    [self.tvScroll setAutohidesScrollers:YES];
    [self.tvScroll setDocumentView:self.userTV];
    self.tvScroll.hidden = YES;
    [self.view addSubview:self.tvScroll];
}

//- (void)mouseDown:(NSEvent *)theEvent {
//    NSPoint point = [theEvent locationInWindow];
//    if (self.userSF) {
//        NSPoint curPoint = NSMakePoint(point.x - self.userSF.bounds.origin.x, point.y - self.userSF.bounds.origin.y);
//        if (CGRectContainsPoint(self.userSF.bounds, curPoint)) {
//            self.tvScroll.hidden = NO;
//        } else {
//            NSLog(@"Out");
//        }
//    }
//}

- (void)searchUser:(id)sender {
    self.tvScroll.hidden = NO;
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:self.userArr];
    if ([self.userSF.stringValue isEqualToString:@""] || !self.userSF.stringValue) {
        //[self.teacherCV setContent:self.teacherArray];
        self.tableArr = self.userArr;
        [self.userTV reloadData];[self.userSF becomeFirstResponder];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realName like[c] %@",[NSString stringWithFormat:@"%@*",self.userSF.stringValue]];
        //联想
        [tempArr filterUsingPredicate:predicate];
        self.tableArr = tempArr;
        [self.userTV reloadData];
    }
}

- (void)loadUserDataFromCloud {
    AVQuery *query = [AVUser query];
    NSArray *arr = [query findObjects];
    self.userArr = [[NSMutableArray alloc] init];
    for (AVUser *obj in arr) {
        User *user = [[User alloc] initWithAVUser:obj];
        [self.userArr addObject:user];
    }
    self.tableArr = self.userArr;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.tableArr.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return ((User *)self.tableArr[row]).realName;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
#warning 自己写Cell
    //id cell = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
    NSButton *cell = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
    cell.title = ((User *)self.tableArr[row]).realName;
    //[cell setButtonType:NSMomentaryPushInButton];
    cell.bordered = NO;
    cell.bezelStyle = NSRoundRectBezelStyle;
    cell.alignment = NSLeftTextAlignment;
    cell.target = self;
    cell.tag = row;
    cell.action = @selector(cellClick:);
    return cell;
}

- (void)cellClick:(NSButton *)sender {
    self.tvScroll.hidden = YES;
    self.selectUser = (User *)self.tableArr[sender.tag];
    [self.monthView updateCalendarWithMonth:self.month withYear:self.year];
    [self initViewWithData];
    NSLog(@"%@", ((User *)self.tableArr[sender.tag]).realName);
}

//- (void)initButton {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teacherSelected:) name:@"TeacherSelected" object:nil];
//    NSButton *tchBtn = [[NSButton alloc] initWithFrame:NSMakeRect(240, SCREEN_HEIGHT - 30, 100, 25)];
//    tchBtn.title = @"选择老师";
//    [tchBtn setButtonType:NSMomentaryPushInButton];
//    //响应点击事件 需要设置 action 和 target
//    [tchBtn setAction:@selector(selectTeacher:)];
//    [tchBtn setTarget:self];
//    tchBtn.bezelStyle = NSRoundRectBezelStyle;
//    [self.view addSubview:tchBtn];
//}

//- (void)teacherSelected:(NSNotification *)notification {
//    self.selectUser = [notification.userInfo objectForKey:@"Teacher"];
//    NSLog(@"%@", self.selectUser.username);
//    self.tchLessonArray = [[NSMutableArray alloc] init];
//    [self.monthView updateCalendarWithMonth:self.month withYear:self.year];
//    [self initViewWithData];
//}

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
    NSDate *start = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", self.monthView.firstDate]];
    NSDate *end = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:59:59", self.monthView.lastDate]];
    AVQuery *query = [AVQuery queryWithClassName:@"Lesson"];
    [query whereKey:@"startTime" greaterThan:start];
    [query whereKey:@"endTime" lessThan:end];
    if ([self.selectUser.type isEqualToString:@"Student"]) {
        [query whereKey:@"students" containsString:self.selectUser.objectId];
    } else if ([self.selectUser.type isEqualToString:@"Teacher"]) {
        [query whereKey:@"teacher" equalTo:self.selectUser.objectId];
    }
    
    NSArray *lesArr = [query findObjects];
    for (AVObject *obj in lesArr) {
        Lesson *lesson = [[Lesson alloc] initWithCloudLesson:obj andTeacher:self.selectUser];
        [self.tchLessonArray addObject:lesson];
    }
    NSLog(@"%li", self.tchLessonArray.count);
}

//- (void)selectUser:(NSButton *)sender {
//    [self performSegueWithIdentifier:@"selectUser" sender:self];
//}

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
    if (self.selectUser) {
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
    if (self.selectUser) {
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
    if (self.selectUser) {
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
        if (self.selectUser) {
            [self initViewWithData];
        }
    } else if (dayView.state == 1) {
        if (self.month >= 12) {
            self.month = 1;
            self.year++;
        } else {
            self.month++;
        }
        [self.monthView updateCalendarWithMonth:self.month withYear:self.year];
        [self setHeadDate];
        if (self.selectUser) {
            [self initViewWithData];
        }
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
        if (self.selectUser) {
            controller.selectUser = self.selectUser;
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
