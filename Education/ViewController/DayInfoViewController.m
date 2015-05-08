//
//  DayInfoViewController.m
//  Education
//
//  Created by Feicun on 15/5/7.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "DayInfoViewController.h"

@interface DayInfoViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) NSMutableArray *dayLessonInfo;
@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSTableView *dayInfoTV;

@end

@implementation DayInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    NSString *titleStr = [NSString stringWithFormat:@"%@年%@月%@日", [self.dateDict objectForKey:@"Year"], [self.dateDict objectForKey:@"Month"], [self.dateDict objectForKey:@"Day"]];
    self.title = titleStr;
    [self loadDayInfo];
    [self initTableView];
    // Do view setup here.
}

- (void)initTableView {
    self.dayInfoTV = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    self.dayInfoTV.dataSource = self;
    self.dayInfoTV.delegate = self;
    
    [self addColumn:@"1" withTitle:@"老师"];
    [self addColumn:@"2" withTitle:@"课程"];
    [self addColumn:@"3" withTitle:@"时间"];
    [self addColumn:@"4" withTitle:@"学生"];
    
    NSScrollView *tvScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
    tvScroll.hasVerticalScroller = YES;
    tvScroll.hasHorizontalScroller = NO;
    [tvScroll setAutohidesScrollers:YES];
    [tvScroll setDocumentView:self.dayInfoTV];
    [self.view addSubview:tvScroll];
}

- (void)addColumn:(NSString*)newid withTitle:(NSString*)title
{
    NSTableColumn *column=[[NSTableColumn alloc] initWithIdentifier:newid];
    [[column headerCell] setStringValue:title];
    [[column headerCell] setAlignment:NSCenterTextAlignment];
    [column setWidth:100.0];
    [column setMinWidth:50];
    [column setEditable:NO];
    [column setResizingMask:NSTableColumnAutoresizingMask | NSTableColumnUserResizingMask];
    [self.dayInfoTV addTableColumn:column];
}

- (void)loadDayInfo {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [NSString stringWithFormat:@"%@-%02i-%02i", [self.dateDict objectForKey:@"Year"], [[self.dateDict objectForKey:@"Month"] intValue], [[self.dateDict objectForKey:@"Day"] intValue]];
    NSDate *start = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", dateStr]];
    NSDate *end = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:59:59", dateStr]];
    AVQuery *query = [AVQuery queryWithClassName:@"Lesson"];
    [query whereKey:@"startTime" greaterThanOrEqualTo:start];
    [query whereKey:@"endTime" lessThanOrEqualTo:end];
    NSArray *arr = [query findObjects];
    self.dayLessonInfo = [[NSMutableArray alloc] init];
    self.tableData = [[NSMutableArray alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    for (AVObject *obj in arr) {
        Lesson *les = [[Lesson alloc] initWithCloudLesson:obj];
        [self.dayLessonInfo addObject:les];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:les.teacher.realName forKey:@"1"];
        [dic setObject:les.lessonType forKey:@"2"];
        NSString *time = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:les.startTime], [dateFormatter stringFromDate:les.endTime]];
        [dic setObject:time forKey:@"3"];
        NSMutableString *stuName = [[NSMutableString alloc] init];
        for (int i = 0; i < les.students.count; i++) {
            User *u = les.students[i];
            [stuName appendString:u.realName];
            if (i != (les.students.count - 1)) {
                [stuName appendString:@", "];
            }
        }
        [dic setObject:stuName forKey:@"4"];
        [self.tableData addObject:dic];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dayLessonInfo.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[self.tableData objectAtIndex:row] objectForKey:[tableColumn identifier]];
}

//-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//    return nil;
//}

@end
