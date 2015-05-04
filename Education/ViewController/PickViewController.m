//
//  PickViewController.m
//  Education
//
//  Created by Feicun on 15/4/27.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "PickViewController.h"
#import "CollectionItem.h"
#import "User.h"
#import "Lesson.h"

@interface PickViewController ()

//课程时间段
@property (strong, nonatomic) NSComboBox *startCB;
@property (strong, nonatomic) NSComboBox *endCB;
@property (strong, nonatomic) NSString *startMin;
@property (strong, nonatomic) NSString *endMin;

//老师 学生 CollectionView Search
@property (strong, nonatomic) NSCollectionView *teacherCV;
@property (strong, nonatomic) NSSearchField *teacherSearch;
@property (strong, nonatomic) NSCollectionView *studentCV;
@property (strong, nonatomic) NSSearchField *studentSearch;

//@property (strong, nonatomic) NSMutableArray *nameArray;

//老师一位  学生可以多位
#warning 从数据库中读取 加一个是否被选择字段(初始化为否)
@property (strong, nonatomic) NSMutableArray *teacherArray;
@property (strong, nonatomic) NSMutableArray *studentArray;
//用于检索 联想时用  存名字
@property (strong, nonatomic) NSMutableArray *tchSchArr;
@property (strong, nonatomic) NSMutableArray *stuSchArr;
@end

@implementation PickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.lessonType;//[self typeToLesson:self.lessonType];
    [self loadDataFromCloud];
    [self initCombobox];
    [self initButton];
    [self initCollection];
}

#warning 学生老师这些信息 应该放在系统登录时 用一个Manager管理
- (void)loadDataFromCloud {
    AVQuery *query = [AVUser query];
    //[query whereKey:@"type" equalTo:@"Student"];
    NSArray *arr = [query findObjects];
    self.teacherArray = [[NSMutableArray alloc] init];
    self.studentArray = [[NSMutableArray alloc] init];
    self.tchSchArr = [[NSMutableArray alloc] init];
    self.stuSchArr = [[NSMutableArray alloc] init];

    for (int i = 0; i < [arr count]; i++) {
        AVUser *tempUser = (AVUser *)arr[i];
    
        User *user = [[User alloc] initWithAVUser:tempUser];
        
        NSImage *picture = [NSImage imageNamed:@"jc.jpg"];
        user.image = picture;
        user.isSelected = NO;
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:user, @"User", nil];
        if ([user.type isEqualTo:@"Student"]) {
            [self.stuSchArr addObject:user];
            [self.studentArray addObject:tempDic];
        } else if ([user.type isEqualTo:@"Teacher"]) {
            [self.tchSchArr addObject:user];
            [self.teacherArray addObject:tempDic];
        }
    }
    //self.tchSchArr = self.teacherArray;
    //self.stuSchArr = self.studentArray;
}

- (void)initCollection {
#warning 从数据库读取数据 照片-姓名
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemClick:) name:@"ItemClick" object:nil];
    self.teacherCV = [[NSCollectionView alloc] initWithFrame:NSMakeRect(0, 0, 520, 150)];
    //self.teacherCV.delegate = self;
    [self.teacherCV setItemPrototype:[CollectionItem new]];
    [self.teacherCV setContent:self.teacherArray];
    [self.teacherCV setMaxNumberOfRows:1];
    //[self.teacherCV setAutoresizingMask:(NSViewMinXMargin | NSViewWidthSizable | NSViewMaxXMargin | NSViewMinYMargin  | NSViewHeightSizable| NSViewMaxYMargin)];
    //[self.teacherCV setAutoresizesSubviews:YES];
    self.teacherCV.selectable = YES;
    self.teacherCV.allowsMultipleSelection = NO;
    NSScrollView *teacherScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(40, 40, 520, 150)];
    teacherScroll.hasVerticalScroller = YES;
    teacherScroll.hasHorizontalScroller = YES;
    [teacherScroll setAutohidesScrollers:YES];
    [teacherScroll setDocumentView:self.teacherCV];
    [self.view addSubview:teacherScroll];
    
    self.teacherSearch = [[NSSearchField alloc] initWithFrame:NSMakeRect(580, 260, 100, 20)];
    self.teacherSearch.target = self;
    self.teacherSearch.action = @selector(searchTeacher:);
    [self.view addSubview:self.teacherSearch];
    
    self.studentCV = [[NSCollectionView alloc] initWithFrame:NSMakeRect(0, 200, 520, 150)];
    //self.teacherCV.delegate = self;
    [self.studentCV setItemPrototype:[CollectionItem new]];
    [self.studentCV setContent:self.studentArray];
    [self.studentCV setMaxNumberOfRows:1];
    
    self.studentCV.selectable = YES;
    self.studentCV.allowsMultipleSelection = NO;
    NSScrollView *studentScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(40, 240, 520, 150)];
    studentScroll.hasVerticalScroller = YES;
    studentScroll.hasHorizontalScroller = YES;
    [studentScroll setAutohidesScrollers:YES];
    [studentScroll setDocumentView:self.studentCV];
    [self.view addSubview:studentScroll];
    
    self.studentSearch = [[NSSearchField alloc] initWithFrame:NSMakeRect(580, 460, 100, 20)];
    self.studentSearch.target = self;
    self.studentSearch.action = @selector(searchStudent:);
    
    [self.view addSubview:self.studentSearch];
}

- (void)searchStudent:(id)sender {
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:self.stuSchArr];
    if ([self.studentSearch.stringValue isEqualToString:@""] || !self.studentSearch.stringValue) {
        [self.studentCV setContent:self.studentArray];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username like[c] %@",[NSString stringWithFormat:@"%@*",self.studentSearch.stringValue]];
        //联想
        [tempArr filterUsingPredicate:predicate];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < tempArr.count; i++) {
            [arr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:tempArr[i], @"User", nil]];
        }
        [self.studentCV setContent:arr];
    }
}

- (void)searchTeacher:(id)sender {
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:self.tchSchArr];
    if ([self.teacherSearch.stringValue isEqualToString:@""] || !self.teacherSearch.stringValue) {
        [self.teacherCV setContent:self.teacherArray];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username like[c] %@",[NSString stringWithFormat:@"%@*",self.teacherSearch.stringValue]];
        //联想
        [tempArr filterUsingPredicate:predicate];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < tempArr.count; i++) {
            [arr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:tempArr[i], @"User", nil]];
        }
        [self.teacherCV setContent:arr];
    }
}

//实现单选  点击item 发送通知传入item信息   接收通知后 返回一个通知 回传给所有item  将之前选择的item清空
#warning 联想过后 点击会出问题
- (void)itemClick:(NSNotification *)notification {
    User *user = [notification.userInfo objectForKey:@"User"];
    //NSLog(@"%@", user.username);
    if ([user.type isEqualTo:@"Teacher"]) {
//        for (NSMutableDictionary *dict in self.teacherArray) {
//            User *tchUser = [dict objectForKey:@"User"];
//            //NSLog(@"%@", tchUser.username);
//            if ([user.username isEqualTo:tchUser.username]) {
//                tchUser.isSelected = user.isSelected;
//            } else {
//                tchUser.isSelected = NO;
//                user.isSelected = NO;
//            }
//            //[self.teacherCV setNeedsDisplay:YES];
//        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"DisOtherItem" object:nil userInfo:notification.userInfo];
        //NSLog(@"Selected Teacher: %@", user.username);
    } else if ([user.type isEqualTo:@"Student"]) {
        NSMutableString *stu = [[NSMutableString alloc] initWithString:@"Selected Students: "];
        for (NSMutableDictionary *dict in self.studentArray) {
            User *stuUser = [dict objectForKey:@"User"];
            //比较有问题
            if ([user.username isEqualTo:stuUser.username]) {
                stuUser.isSelected = user.isSelected;
            }
            if (stuUser.isSelected) {
                [stu appendString:[NSString stringWithFormat:@"%@, ", stuUser.username]];
            }
        }
        //NSLog(@"%@", stu);
    }
}

- (void)initCombobox {
    NSTextField *startTF = [[NSTextField alloc] initWithFrame:NSMakeRect(0, SCREEN_HEIGHT - 100, 30, 25)];
    startTF.backgroundColor = [NSColor clearColor];
    startTF.editable = NO;
    startTF.selectable = NO;
    startTF.bordered = NO;
    startTF.alignment = NSRightTextAlignment;
    startTF.font = [NSFont systemFontOfSize:17];
    startTF.stringValue = [NSString stringWithFormat:@"%i:", self.startHour];
    self.startCB = [[NSComboBox alloc] initWithFrame:NSMakeRect(30, SCREEN_HEIGHT - 100, 100, 25)];
    self.startCB.editable = NO;
    self.startCB.bordered = YES;
    
    NSTextField *endTF = [[NSTextField alloc] initWithFrame:NSMakeRect(0, SCREEN_HEIGHT - 70, 30, 25)];
    endTF.backgroundColor = [NSColor clearColor];
    endTF.editable = NO;
    endTF.selectable = NO;
    endTF.bordered = NO;
    endTF.alignment = NSRightTextAlignment;
    endTF.font = [NSFont systemFontOfSize:17];
    endTF.stringValue = [NSString stringWithFormat:@"%i:", self.endHour];
    self.endCB = [[NSComboBox alloc] initWithFrame:NSMakeRect(30, SCREEN_HEIGHT - 70, 100, 25)];
    self.endCB.editable = NO;
    self.endCB.bordered = YES;
    
    for (int i = 0; i < 60; i++) {
        NSString *value = [NSString stringWithFormat:@"%02i", i];
        [self.startCB addItemWithObjectValue:value];
        [self.endCB addItemWithObjectValue:value];
    }
    
    [self.startCB selectItemAtIndex:0];
    [self.endCB selectItemAtIndex:0];
    
    [self.view addSubview:startTF];
    [self.view addSubview:endTF];
    [self.view addSubview:self.startCB];
    [self.view addSubview:self.endCB];
}

- (void)initButton {
    NSButton *saveBtn = [[NSButton alloc] initWithFrame:NSMakeRect(SCREEN_WIDTH - 100, 0, 100, 20)];
    saveBtn.title = @"保存";
    [saveBtn setButtonType:NSMomentaryPushInButton];
    [saveBtn setAction:@selector(saveAll:)];
    [saveBtn setTarget:self];
    saveBtn.bezelStyle = NSRoundRectBezelStyle;
    [self.view addSubview:saveBtn];
    
    NSButton *cancelBtn = [[NSButton alloc] initWithFrame:NSMakeRect(SCREEN_WIDTH - 100, 30, 100, 20)];
    cancelBtn.title = @"取消";
    [cancelBtn setButtonType:NSMomentaryPushInButton];
    [cancelBtn setAction:@selector(cancel:)];
    [cancelBtn setTarget:self];
    cancelBtn.bezelStyle = NSRoundRectBezelStyle;
    [self.view addSubview:cancelBtn];
}

- (void)cancel:(NSButton *)sender {
    //起止时间 和类型传回去
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.startHour], @"Start", [NSNumber numberWithInt:self.endHour], @"End", self.lessonType, @"LessonType", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LessonCancel" object:nil userInfo:dict];
    [self dismissViewController:self];
}

- (void)saveAll:(NSButton *)sender {
    //传递 开始结束时间  老师 学生 以及课程类型
    self.startMin = [self.startCB itemObjectValueAtIndex:[self.startCB indexOfSelectedItem]];
    self.endMin = [self.endCB itemObjectValueAtIndex:[self.endCB indexOfSelectedItem]];
    NSString *start = [NSString stringWithFormat:@"%@ %02i:%@:00", self.date, self.startHour, self.startMin];
    NSString *end = [NSString stringWithFormat:@"%@ %02i:%@:00", self.date, self.endHour, self.endMin];
    
    User *selTch = [[User alloc] init];
    for (User *user in self.tchSchArr) {
        if (user.isSelected) {
            selTch = user;
            break;
        }
    }
    NSLog(@"%@", selTch.username);
    NSMutableArray *selStu = [[NSMutableArray alloc] init];
    for (User *user in self.stuSchArr) {
        if (user.isSelected) {
            [selStu addObject:user];
        }
    }
    NSLog(@"%li", selStu.count);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    Lesson *lesson = [[Lesson alloc] init];
    lesson.startTime = [dateFormatter dateFromString:start];
    lesson.endTime = [dateFormatter dateFromString:end];
    lesson.teacher = selTch;
    lesson.students = selStu;
    lesson.lessonType = self.lessonType;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:lesson, @"Lesson", nil];
    //NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:start, @"StartTime", end, @"EndTime", selTch, @"SelTeacher", selStu, @"SelStudent", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LessonConfirmed" object:nil userInfo:dict];
    [self dismissViewController:self];
}
//
//- (NSString *)typeToLesson:(int)type {
//    switch (type) {
//        case 1:
//            return @"听";
//            break;
//        case 2:
//            return @"说";
//            break;
//        case 3:
//            return @"读";
//            break;
//        case 4:
//            return @"写";
//            break;
//        default:
//            return nil;
//            break;
//    }
//}

/**
 #import "BVAppDelegate.h"
 
 
 static const NSSize buttonSize = { 80, 20 };
 static const NSSize itemSize = { 100, 40 };
 static const NSPoint buttonOrigin = { 10, 10 };
 
 
 @interface BVView : NSView
 @property (weak) NSButton *button;
 @end
 
 @implementation BVView
 @synthesize button;
 - (id)initWithFrame:(NSRect)frameRect {
 self = [super initWithFrame:(NSRect){frameRect.origin, itemSize}];
 if (self) {
 NSButton *newButton = [[NSButton alloc]
 initWithFrame:(NSRect){buttonOrigin, buttonSize}];
 [self addSubview:newButton];
 self.button = newButton;
 }
 return self;
 }
 @end
 
 
 @interface BVPrototype : NSCollectionViewItem
 @end
 
 @implementation BVPrototype
 - (void)loadView {
 [self setView:[[BVView alloc] initWithFrame:NSZeroRect]];
 }
 - (void)setRepresentedObject:(id)representedObject {
 [super setRepresentedObject:representedObject];
 [[(BVView *)[self view] button] setTitle:representedObject];
 }
 @end
 
 
 @interface BVAppDelegate ()
 @property (strong) NSArray *titles;
 @end
 
 @implementation BVAppDelegate
 
 @synthesize window = _window;
 @synthesize titles;
 
 - (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
 self.titles = [NSArray arrayWithObjects:@"Case", @"Molly", @"Armitage",
 @"Hideo", @"The Finn", @"Maelcum", @"Wintermute", @"Neuromancer", nil];
 
 NSCollectionView *cv = [[NSCollectionView alloc]
 initWithFrame:[[[self window] contentView] frame]];
 [cv setItemPrototype:[BVPrototype new]];
 [cv setContent:[self titles]];
 
 [cv setAutoresizingMask:(NSViewMinXMargin
 | NSViewWidthSizable
 | NSViewMaxXMargin
 | NSViewMinYMargin
 | NSViewHeightSizable
 | NSViewMaxYMargin)];
 [[[self window] contentView] addSubview:cv];
 }
 
 @end
 
 **/
@end
