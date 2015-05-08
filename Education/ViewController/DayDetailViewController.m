//
//  DayDetailViewController.m
//  Education
//
//  Created by Feicun on 15/4/21.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "DayDetailViewController.h"
#import "FuncBlockView.h"
#import "PickViewController.h"

@interface DayDetailViewController () <BlockClick>

@property (strong, nonatomic) FuncBlockView *tempBlock;//第一次点击的Block
//@property (strong, nonatomic) FuncBlockView *curTempBlock;//点击后滑动的Block

@property (strong, nonatomic) NSMutableArray *listenArray;
@property (strong, nonatomic) NSMutableArray *speakArray;
@property (strong, nonatomic) NSMutableArray *readArray;
@property (strong, nonatomic) NSMutableArray *writeArray;
@property (strong, nonatomic) NSMutableDictionary *timeArray;//时间字典 1-24  YES/NO YES代表没选择课程

//临时存储选时间时的区间
@property (nonatomic) int firstHour;
@property (nonatomic) int lastHour;

//保存所选课程
@property (strong, nonatomic) NSMutableArray *lessonArray;
@property (strong, nonatomic) Lesson *selectLesson;
//传递给下个页面的操作类型 Edit  Add  Check
@property (strong, nonatomic) NSString *passType;

@property (strong, nonatomic) NSMutableArray *deleteLessonArr;

@end

@implementation DayDetailViewController

#warning 如果上课时间为 8:00-10:20 10:30-  那选课就会出现问题

#pragma -mark 界面初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *titleStr = [NSString stringWithFormat:@"%@年%@月%@日", [self.dateDict objectForKey:@"Year"], [self.dateDict objectForKey:@"Month"], [self.dateDict objectForKey:@"Day"]];
    self.title = titleStr;
    
    if (self.selectUser) {
    
        self.lessonArray = [[NSMutableArray alloc] init];
        self.deleteLessonArr = [[NSMutableArray alloc] init];
        [self initHours];
        self.listenArray = [self funcArrayWithType:@"听" andIndex:1];
        self.speakArray = [self funcArrayWithType:@"说" andIndex:2];
        self.readArray = [self funcArrayWithType:@"读" andIndex:3];
        self.writeArray =[self funcArrayWithType:@"写" andIndex:4];
        self.timeArray = [[NSMutableDictionary alloc] init];
    
        for (int i = 0; i < 24; i++) {
            [self.timeArray setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", i]];
    }
    
    [self initButton];
    
    if (self.selectUser) {
        [self loadLessonDataFromCloud];
        if (self.lessonArray.count) {
            [self initViewWithData];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lessonConfirmed:) name:@"LessonConfirmed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lessonCancel:) name:@"LessonCancel" object:nil];
    }
    // Do view setup here.
}
//初始化 所有按钮  页面可/不可编辑 两种状态
- (void)initButton {
    if (self.isEditable) {
        NSButton *saveBtn = [[NSButton alloc] initWithFrame:NSMakeRect(650, 300, 100, 20)];
        saveBtn.title = @"保存";
        [saveBtn setAction:@selector(saveChange:)];
        [saveBtn setTarget:self];
        [saveBtn setButtonType:NSMomentaryPushInButton];
        saveBtn.bezelStyle = NSRoundRectBezelStyle;
        [self.view addSubview:saveBtn];
        
        NSButton *resetBtn = [[NSButton alloc] initWithFrame:NSMakeRect(650, 250, 100, 20)];
        resetBtn.title = @"重置";
        [resetBtn setAction:@selector(resetAll:)];
        [resetBtn setTarget:self];
        [resetBtn setButtonType:NSMomentaryPushInButton];
        resetBtn.bezelStyle = NSRoundRectBezelStyle;
        [self.view addSubview:resetBtn];
        
        NSButton *cancelBtn = [[NSButton alloc] initWithFrame:NSMakeRect(650, 200, 100, 20)];
        cancelBtn.title = @"取消";
        [cancelBtn setAction:@selector(cancel:)];
        [cancelBtn setTarget:self];
        [cancelBtn setButtonType:NSMomentaryPushInButton];
        cancelBtn.bezelStyle = NSRoundRectBezelStyle;
        [self.view addSubview:cancelBtn];
        
        for (int i = 1; i <= 4; i++) {
            NSButton *columnReset = [[NSButton alloc] initWithFrame:NSMakeRect(100 * i, SCREEN_HEIGHT - 30, 100, 20)];
            columnReset.title = @"重置";
            [columnReset setAction:@selector(eachReset:)];
            [columnReset setTarget:self];
            [columnReset setButtonType:NSMomentaryPushInButton];
            columnReset.bezelStyle = NSRoundRectBezelStyle;
            columnReset.tag = i;
            [self.view addSubview:columnReset];
        }
    }
}

- (void)initViewWithData {
    for (Lesson *lesson in self.lessonArray) {
        NSMutableArray *typeArr = [self getFuncArrayByType:lesson.lessonType];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"HH"];
        int start = [[formatter stringFromDate:lesson.startTime] intValue];
        int end = [[formatter stringFromDate:lesson.endTime] intValue];
        for (int i = start; i <= end; i++) {
            FuncBlockView *temp = (FuncBlockView *)typeArr[23 - i];
            [temp didSelected:YES];
            temp.isEditable = NO;
            [self.timeArray setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%i", i]];
        }
    }
}

//从云端读取数据  然后初始化 FuncBlock
- (void)loadLessonDataFromCloud {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [NSString stringWithFormat:@"%@-%02i-%02i", [self.dateDict objectForKey:@"Year"], [[self.dateDict objectForKey:@"Month"] intValue], [[self.dateDict objectForKey:@"Day"] intValue]];
    NSDate *start = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", dateStr]];
    NSDate *end = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:59:59", dateStr]];
    //nsdate *start = []
    AVQuery *query = [AVQuery queryWithClassName:@"Lesson"];
    [query whereKey:@"startTime" greaterThanOrEqualTo:start];
    [query whereKey:@"endTime" lessThanOrEqualTo:end];
    if ([self.selectUser.type isEqualToString:@"Student"]) {
        [query whereKey:@"students" containsString:self.selectUser.objectId];
    } else if ([self.selectUser.type isEqualToString:@"Teacher"]) {
        [query whereKey:@"teacher" equalTo:self.selectUser.objectId];
    }
    NSArray *lesArr = [query findObjects];
    for (AVObject *obj in lesArr) {
        Lesson *lesson = [[Lesson alloc] initWithCloudLesson:obj];
        [self.lessonArray addObject:lesson];
    }
    //self.lessonArray = [[NSMutableArray alloc] initWithArray:[query findObjects]];
}

#warning 从数据库读取
//听说读写 四列块的初始化
- (NSMutableArray *)funcArrayWithType:(NSString *)type andIndex:(int)index {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 24; i++) {
        FuncBlockView *func = [[FuncBlockView alloc] initWithFrame:NSMakeRect(100 * index, SCREEN_HEIGHT / 24 * i - i, 100, SCREEN_HEIGHT / 24) withType:type andEditable:self.isEditable];
        func.delegate = self;
        func.time = 23 - i;
        [array addObject:func];
        [self.view addSubview:func];
    }
    return array;
}
//根据块类型返回相应Array
- (NSMutableArray *)getFuncArrayByType:(NSString *)type {
    if ([type isEqualToString:@"听"]) {
        return self.listenArray;
    } else if ([type isEqualToString:@"说"]) {
        return self.speakArray;
    } else if ([type isEqualToString:@"读"]) {
        return self.readArray;
    } else if ([type isEqualToString:@"写"]) {
        return self.writeArray;
    }
    return nil;
}
//24小时的初始化
- (void)initHours {
    for (int i = 0; i < 24; i++) {
//        TimeBlock *tb = [[TimeBlock alloc] initWithFrame:NSMakeRect(0, SCREEN_HEIGHT / 24 * i - i, 100, SCREEN_HEIGHT / 24)];
//        [self.view addSubview:tb];
        NSTextField *tf = [[NSTextField alloc] initWithFrame:NSMakeRect(0, SCREEN_HEIGHT / 24 * i - i, 100, SCREEN_HEIGHT / 24)];
        tf.stringValue = [NSString stringWithFormat:@"%i:00", 23 - i];
        tf.font = [NSFont systemFontOfSize:15];
        tf.backgroundColor = [NSColor whiteColor];
        tf.editable = NO;
        tf.selectable = NO;
        tf.bordered = YES;
        tf.alignment = NSCenterTextAlignment;
        [self.view addSubview:tf];
    }
}

#pragma -mark 按钮相应函数
//四列的重置 根据tag(type)来重置
- (void)eachReset:(NSButton *)sender {
    NSString *type = @"";
    switch ((int)sender.tag) {
        case 1:
            type = @"听";
            break;
        case 2:
            type = @"说";
        case 3:
            type = @"读";
        case 4:
            type = @"写";
        default:
            break;
    }
    NSMutableArray *column = [self getFuncArrayByType:type];
    for (FuncBlockView *func in column) {
        if (func.isSelected) {
            [func didSelected:NO];
            [self.timeArray setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", func.time]];
        }
    }
}
//取消
- (void)cancel:(NSButton *)sender {
    [self dismissViewController:self];
}
//重置所有
- (void)resetAll:(NSButton *)sender {
    for (int i = 0; i < 24; i++) {
        [self.timeArray setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", i]];
        FuncBlockView *bv = self.listenArray[i];
        [bv didSelected:NO];
        bv = self.speakArray[i];
        [bv didSelected:NO];
        bv = self.readArray[i];
        [bv didSelected:NO];
        bv = self.writeArray[i];
        [bv didSelected:NO];
    }
    [self.lessonArray removeAllObjects];
}
//保存
- (void)saveChange:(NSButton *)sender {
#warning 这里发送通知给学生
//    iOS端 需要在注册installation时添加用户
//    AVInstallation *installation = [AVInstallation currentInstallation];
//    [installation setObject:[AVUser currentUser] forKey:@"owner"];
//    [installation saveInBackground];
    
//    AVQuery *pushQuery = [AVInstallation query];
//    [pushQuery whereKey:@"objectId" containedIn:nil];
//    
//    // Send push notification to query
//    AVPush *push = [[AVPush alloc] init];
//    [push setQuery:pushQuery]; // Set our Installation query
//    [push setMessage:@"你有新的课程"];
//    [push sendPushInBackground];
    
    if (self.deleteLessonArr.count) {
        for (Lesson *les in self.deleteLessonArr) {
            [les deleteFromCloud];
        }
    }
    
    NSMutableArray *typeArr = [[NSMutableArray alloc] init];
    for (Lesson *les in self.lessonArray) {
        [les uploadToCloud];
        if ([self.selectUser.type isEqualToString:@"Teacher"]) {
            if ([self.selectUser.objectId isEqualToString:les.teacher.objectId] && ![typeArr containsObject:les.lessonType]) {
                [typeArr addObject:les.lessonType];
            }
        } else if ([self.selectUser.type isEqualToString:@"Student"]) {
            if ([les isLessonContainsStudent:self.selectUser] && ![typeArr containsObject:les.lessonType]) {
                [typeArr addObject:les.lessonType];
            }
        }
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:typeArr, @"LessonTypes", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChosenLesson" object:nil userInfo:dic];
    
    [self dismissViewController:self];
}

- (Lesson *)getLessonFromBlock:(FuncBlockView *)block {
    for (Lesson *lesson in self.lessonArray) {
        if ([block.type isEqualToString:lesson.lessonType]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"HH"];
            int start = [[formatter stringFromDate:lesson.startTime] intValue];
            int end = [[formatter stringFromDate:lesson.endTime] intValue];
            if (block.time >= start && block.time <= end) {
                return lesson;
            }
        }
    }
    return nil;
}

#pragma -mark 鼠标事件
//右键菜单 只在选定的课程Block中响应
- (void)rightMouseDown:(NSEvent *)theEvent {
    NSArray *typeArr = [[NSArray alloc] initWithObjects:@"听", @"说", @"读", @"写", nil];
    //NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.listenArray, @"听", self.speakArray, @"说", self.readArray, @"读", self.writeArray, @"写", nil];
    NSPoint point = [theEvent locationInWindow];
    BOOL findBlock = NO;
    for (NSString *type in typeArr) {
        NSMutableArray *arr = [self getFuncArrayByType:type];
        for (FuncBlockView *block in arr) {
            NSPoint curPoint = NSMakePoint(point.x - block.frame.origin.x, point.y - block.frame.origin.y);
            if (CGRectContainsPoint(block.bounds, curPoint)) {
                if (!block.isEditable) {
                    //说明此处有课
                    findBlock = YES;
                    self.selectLesson = [self getLessonFromBlock:block];
                    [self popUpRightMenu:theEvent];
                    break;
                }
            }
        }
        if (findBlock) {
            break;
        }
    }
}

//弹出右键菜单
- (void)popUpRightMenu:(NSEvent *)theEvent {
    NSMenu *menu = [[NSMenu alloc] init];
    //NSMenuItem *editItem = [[NSMenuItem alloc] initWithTitle:@"修改" action:@selector(editLesson) keyEquivalent:nil];
    [menu insertItemWithTitle:@"查看" action:@selector(checkLesson) keyEquivalent:@"" atIndex:0];
    if (self.isEditable) {
        [menu insertItemWithTitle:@"修改" action:@selector(editLesson) keyEquivalent:@"" atIndex:1];
        [menu insertItemWithTitle:@"删除" action:@selector(deleteLesson) keyEquivalent:@"" atIndex:2];
    }
    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self.view];
}

- (void)deleteLesson {
#warning 老师删是整个课都删 学生删是只删除自己
    [self redrawLessonBlock:self.selectLesson.lessonType fromStart:[self.selectLesson lessonStartHour] toEnd:[self.selectLesson lessonEndHour]];
    if ([self.selectUser.type isEqualToString:@"Teacher"]) {
        [self.deleteLessonArr addObject:self.selectLesson];
        [self.lessonArray removeObject:self.selectLesson];
    } else if ([self.selectUser.type isEqualToString:@"Student"]) {
        //删掉自己  如果是只有一个学生 那么正门课一起删掉
        if ([self.selectLesson.students count] == 1) {
            //如果不是自己  则根本不会显示(修改过)
            [self.deleteLessonArr addObject:self.selectLesson];
            [self.lessonArray removeObject:self.selectLesson];
        } else {
            for (Lesson *temp in self.lessonArray) {
                if ([temp.objectId isEqualToString:self.selectLesson.objectId]) {
                    [temp lessonRemoveStudent:self.selectUser];
                    [self.selectLesson lessonRemoveStudent:self.selectUser];
                    break;
                }
            }
           
        }
    }
    
    self.selectLesson = nil;
}

- (void)checkLesson {
    self.passType = @"Check";
    [self performSegueWithIdentifier:@"PickTAndS" sender:self];
    self.selectLesson = nil;
}

- (void)editLesson {
    self.passType = @"Edit";
    [self performSegueWithIdentifier:@"PickTAndS" sender:self];
    self.selectLesson = nil;
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (self.tempBlock.isSelected) {
#warning 判断是否连续 不连续则无法添加
        self.passType = @"Add";
        [self performSegueWithIdentifier:@"PickTAndS" sender:self];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (self.tempBlock.isSelected) {
        NSPoint point = [theEvent locationInWindow];
        for (FuncBlockView *block in [self getFuncArrayByType:self.tempBlock.type]) {
            NSPoint curPoint = NSMakePoint(point.x - block.frame.origin.x, point.y - block.frame.origin.y);
            if (CGRectContainsPoint(block.bounds, curPoint)) {
                if ([[self.timeArray objectForKey:[NSString stringWithFormat:@"%i", block.time]] boolValue]) {
                    [block didSelected:YES];
                    [self.timeArray setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%i", block.time]];
                    if (block.time > self.lastHour) {
                        self.lastHour = block.time;
                    }
                    if (block.time < self.firstHour) {
                        self.firstHour = block.time;
                    }
                }
            }
        }
    }
}

- (void)clickBlock:(FuncBlockView *)blockView {
    self.tempBlock = blockView;
    self.firstHour = blockView.time;
    self.lastHour = blockView.time;
    //self.curTempBlock = blockView;
    if ([[self.timeArray objectForKey:[NSString stringWithFormat:@"%i", self.tempBlock.time]] boolValue] && !blockView.isSelected) {
        [self.timeArray setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%i", self.tempBlock.time]];
        [blockView didSelected:YES];
    } else if (blockView.isSelected){
        [self.timeArray setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", self.tempBlock.time]];
        [blockView didSelected:NO];
    }
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PickTAndS"]) {
        PickViewController *pick = segue.destinationController;
        NSString *date = [NSString stringWithFormat:@"%@-%02i-%02i", [self.dateDict objectForKey:@"Year"], [[self.dateDict objectForKey:@"Month"] intValue], [[self.dateDict objectForKey:@"Day"] intValue]];
        pick.date = date;
        pick.lessonType = self.tempBlock.type;
        pick.startHour = self.firstHour;
        pick.endHour = self.lastHour;
        pick.selectUser = self.selectUser;
        pick.pageType = self.passType;
        if (![self.passType isEqualToString:@"Add"]) {
            pick.lessonType = self.selectLesson.lessonType;
            pick.pageLesson = self.selectLesson;
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"HH"];
            pick.startHour = [[df stringFromDate:self.selectLesson.startTime] intValue];
            pick.endHour = [[df stringFromDate:self.selectLesson.endTime] intValue];
        }
    }
}

//课程确认
- (void)lessonConfirmed:(NSNotification *)notification {
    Lesson *lesson = [notification.userInfo objectForKey:@"Lesson"];
    if (lesson.objectId) {
        //说明是edit 更新lessonArray里的
        for (Lesson *temp in self.lessonArray) {
            if ([temp.objectId isEqualToString:lesson.objectId]) {
                if ([self.selectUser.type isEqualToString:@"Teacher"]) {
                    if (![self.selectUser.objectId isEqualToString:lesson.teacher.objectId]) {
                        //说明换老师了  那显示的要删掉
                        [self redrawLessonBlock:lesson.lessonType fromStart:[lesson lessonStartHour] toEnd:[lesson lessonEndHour]];
                    }
                } else if ([self.selectUser.type isEqualToString:@"Student"]) {
                    if (![lesson isLessonContainsStudent:self.selectUser]) {
                        [self redrawLessonBlock:lesson.lessonType fromStart:[lesson lessonStartHour] toEnd:[lesson lessonEndHour]];
                    }
                }
                [temp updateLesson:lesson];
                break;
            }
        }
    } else {
        [self.lessonArray addObject:lesson];
    }
}

- (void)lessonCancel:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    int start = [[dict objectForKey:@"Start"] intValue];
    int end = [[dict objectForKey:@"End"] intValue];
    [self redrawLessonBlock:[dict objectForKey:@"LessonType"] fromStart:start toEnd:end];
}

- (void)redrawLessonBlock:(NSString *)type fromStart:(int)start toEnd:(int)end {
    NSMutableArray *arr = [self getFuncArrayByType:type];
    for (int i = start; i <= end; i++) {
        FuncBlockView *func = arr[23 - i];
        [func didSelected:NO];
        [self.timeArray setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", i]];
    }

}

@end

//判断是否为同一block  是得话不做操作
//                BOOL canSelected = [[self.timeArray objectForKey:[NSString stringWithFormat:@"%i", block.time]] boolValue];
//                BOOL curTBCanSelected = [[self.timeArray objectForKey:[NSString stringWithFormat:@"%i", self.curTempBlock.time]] boolValue];
//                if (![self.curTempBlock isEqual:block]) {
//                    //向下
//                    if (!self.curTempBlock.time < block.time && canSelected) {
//                        [block didSelected:YES];
//                        [self.timeArray setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%i", block.time]];
//                        if (curTBCanSelected) {
//                            [self.curTempBlock didSelected:YES];
//                            [self.timeArray setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%i", self.curTempBlock.time]];
//                        }
//                    }
//                    //向上
//                    if (self.curTempBlock.time > block.time && !canSelected) {
//                        [block didSelected:NO];
//                        [self.timeArray setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", block.time]];
//                        if (!curTBCanSelected) {
//                            [self.curTempBlock didSelected:NO];
//                            [self.timeArray setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", self.curTempBlock.time]];
//                        }
//                    }
//                     self.curTempBlock = block;
//                }



//
//                self.curTempBlock = block;
//            }
//        }
//    }

//NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self.view bounds] options: (NSTrackingInVisibleRect | NSTrackingActiveInActiveApp | NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited) owner:self userInfo:nil];
//[self.view addTrackingArea:trackingArea];