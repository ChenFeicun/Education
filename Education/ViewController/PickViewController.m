//
//  PickViewController.m
//  Education
//
//  Created by Feicun on 15/4/27.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "PickViewController.h"
#import "CollectionItem.h"

@interface PickViewController ()

//课程时间段
@property (strong, nonatomic) NSComboBox *startCB;
@property (strong, nonatomic) NSComboBox *endCB;
@property (strong, nonatomic) NSString *startMin;
@property (strong, nonatomic) NSString *endMin;
@property (strong, nonatomic) NSTextField *startTF;
@property (strong, nonatomic) NSTextField *endTF;

//学生 CollectionView Search
@property (strong, nonatomic) NSCollectionView *studentCV;
@property (strong, nonatomic) NSSearchField *studentSearch;
//老师一位  学生可以多位
#warning 从数据库中读取 加一个是否被选择字段(初始化为否)
@property (strong, nonatomic) NSMutableArray *studentArray;
//用于检索 联想时用  存名字
@property (strong, nonatomic) NSMutableArray *stuSchArr;
@end

@implementation PickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.lessonType;//[self typeToLesson:self.lessonType];
    self.startMin = @"00";
    self.endMin = @"00";
    [self loadDataFromCloud];
    [self initCombobox];
    if (![self.pageType isEqualToString:@"Check"]) {
        [self initButton];
    }
    [self initCollection];
    
    if (![self.pageType isEqualToString:@"Add"]) {
        [self initWithPassType];
    }
}

- (void)initWithPassType {
    self.startTF.stringValue = [NSString stringWithFormat:@"%02i:", self.startHour];
    self.endTF.stringValue = [NSString stringWithFormat:@"%02i:", self.endHour];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"mm"];
    [self.startCB selectItemAtIndex:[[formatter stringFromDate:self.pageLesson.startTime] intValue]];
    [self.endCB selectItemAtIndex:[[formatter stringFromDate:self.pageLesson.endTime] intValue]];
    
    
    if ([self.pageType isEqualToString:@"Check"]) {
        self.startCB.enabled = NO;
        self.endCB.enabled = NO;
        self.studentSearch.hidden = YES;
        
        NSButton *okBtn = [[NSButton alloc] initWithFrame:NSMakeRect(SCREEN_WIDTH - 100, 0, 100, 20)];
        okBtn.title = @"确定";
        [okBtn setButtonType:NSMomentaryPushInButton];
        [okBtn setAction:@selector(okToBack:)];
        [okBtn setTarget:self];
        okBtn.bezelStyle = NSRoundRectBezelStyle;
        [self.view addSubview:okBtn];
    }
}

- (void)okToBack:(NSButton *)sender {
    [self dismissViewController:self];
}

- (void)loadDataFromCloud {
    AVQuery *query = [AVUser query];
    if ([self.pageType isEqualToString:@"Check"]) {
        [query whereKey:@"objectId" containedIn:[self.pageLesson getStudentsIdOfLesson]];
    } else {
        [query whereKey:@"type" equalTo:@"Student"];
    }
    
    NSArray *arr = [query findObjects];
    self.studentArray = [[NSMutableArray alloc] init];
    self.stuSchArr = [[NSMutableArray alloc] init];
 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (![self.pageType isEqualToString:@"Add"]) {
        [dateFormatter setDateFormat:@"mm"];
        self.startMin = [dateFormatter stringFromDate:self.pageLesson.startTime];
        self.endMin = [dateFormatter stringFromDate:self.pageLesson.endTime];
    }
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *startStr = [NSString stringWithFormat:@"%@ %02i:%@:00", self.date, self.startHour, self.startMin];
    NSString *endStr = [NSString stringWithFormat:@"%@ %02i:%@:00", self.date, self.endHour, self.endMin];
    NSDate *start = [dateFormatter dateFromString:startStr];
    NSDate *end = [dateFormatter dateFromString:endStr];
    AVQuery *lessonsQuery = [AVQuery queryWithClassName:@"Lesson"];
    //开始时间比 结束时间小  结束时间比开始时间大
    [lessonsQuery whereKey:@"startTime" lessThan:end];
    [lessonsQuery whereKey:@"endTime" greaterThan:start];
    if (![self.pageType isEqualToString:@"Add"]) {
        [lessonsQuery whereKey:@"objectId" notEqualTo:self.pageLesson.objectId];
    }
    NSArray *dayLesson = [lessonsQuery findObjects];
    NSLog(@"%li", dayLesson.count);
    
#warning 应该放在云端处理
    for (AVUser *stu in arr) {
         User *user = [[User alloc] initWithAVUser:stu];
        BOOL isConflict = NO;
        for (AVObject *lesObj in dayLesson) {
            Lesson *lesTep = [[Lesson alloc] initWithCloudLesson:lesObj];
            for (NSString *stuId in [lesTep getStudentsIdOfLesson]) {
                if ([user.objectId isEqualToString:stuId]) {
                    //该学生有冲突
                    isConflict = YES;
                    NSLog(@"%@有冲突", user.username);
                    break;
                }
            }
            if (isConflict) {
                break;
            }
        }
        if (!isConflict) {
            NSImage *picture = [NSImage imageNamed:@"jc.jpg"];
            user.image = picture;
            if (![self.pageType isEqualToString:@"Edit"]) {
                user.isSelected = NO;
            } else {
                for (NSString *stuId in [self.pageLesson getStudentsIdOfLesson]) {
                    if ([user.objectId isEqualToString:stuId]) {
                        user.isSelected = YES;
                        break;
                    }
                }
            }
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:user, @"User", nil];
            if ([self.pageType isEqualToString:@"Check"]) {
                [tempDic setValue:@"Check" forKey:@"Check"];
            }
            
            [self.stuSchArr addObject:user];
            [self.studentArray addObject:tempDic];
        }
    }
    

//    for (int i = 0; i < [arr count]; i++) {
//        AVUser *tempUser = (AVUser *)arr[i];
//        User *user = [[User alloc] initWithAVUser:tempUser];
//        NSImage *picture = [NSImage imageNamed:@"jc.jpg"];
//        user.image = picture;
//        if (![self.pageType isEqualToString:@"Edit"]) {
//            user.isSelected = NO;
//        } else {
//            for (NSString *stuId in [self.pageLesson getStudentsIdOfLesson]) {
//                if ([user.objectId isEqualToString:stuId]) {
//                    user.isSelected = YES;
//                    break;
//                }
//            }
//        }
//        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:user, @"User", nil];
//        if ([self.pageType isEqualToString:@"Check"]) {
//            [tempDic setValue:@"Check" forKey:@"Check"];
//        }
//        
//        [self.stuSchArr addObject:user];
//        [self.studentArray addObject:tempDic];
//    }
}

- (void)initCollection {
#warning 从数据库读取数据 照片-姓名
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemClick:) name:@"ItemClick" object:nil];
    
    self.studentCV = [[NSCollectionView alloc] initWithFrame:NSMakeRect(0, 200, 520, 150)];
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

- (void)itemClick:(NSNotification *)notification {
    User *user = [notification.userInfo objectForKey:@"User"];
    if ([user.type isEqualTo:@"Student"]) {
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
    }
}

- (void)initCombobox {
    self.startTF = [[NSTextField alloc] initWithFrame:NSMakeRect(0, SCREEN_HEIGHT - 100, 30, 25)];
    self.startTF.backgroundColor = [NSColor clearColor];
    self.startTF.editable = NO;
    self.startTF.selectable = NO;
    self.startTF.bordered = NO;
    self.startTF.alignment = NSRightTextAlignment;
    self.startTF.font = [NSFont systemFontOfSize:17];
    self.startTF.stringValue = [NSString stringWithFormat:@"%i:", self.startHour];
    self.startCB = [[NSComboBox alloc] initWithFrame:NSMakeRect(30, SCREEN_HEIGHT - 100, 100, 25)];
    self.startCB.editable = NO;
    self.startCB.bordered = YES;
    
    self.endTF = [[NSTextField alloc] initWithFrame:NSMakeRect(0, SCREEN_HEIGHT - 70, 30, 25)];
    self.endTF.backgroundColor = [NSColor clearColor];
    self.endTF.editable = NO;
    self.endTF.selectable = NO;
    self.endTF.bordered = NO;
    self.endTF.alignment = NSRightTextAlignment;
    self.endTF.font = [NSFont systemFontOfSize:17];
    self.endTF.stringValue = [NSString stringWithFormat:@"%i:", self.endHour];
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
    
    [self.view addSubview:self.startTF];
    [self.view addSubview:self.endTF];
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
    if ([self.pageType isEqualToString:@"Add"]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.startHour], @"Start", [NSNumber numberWithInt:self.endHour], @"End", self.lessonType, @"LessonType", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LessonCancel" object:nil userInfo:dict];
    }
    [self dismissViewController:self];
}

- (void)saveAll:(NSButton *)sender {
    //传递 开始结束时间  老师 学生 以及课程类型
    self.startMin = [self.startCB itemObjectValueAtIndex:[self.startCB indexOfSelectedItem]];
    self.endMin = [self.endCB itemObjectValueAtIndex:[self.endCB indexOfSelectedItem]];
    NSString *start = [NSString stringWithFormat:@"%@ %02i:%@:00", self.date, self.startHour, self.startMin];
    NSString *end = [NSString stringWithFormat:@"%@ %02i:%@:00", self.date, self.endHour, self.endMin];

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
    lesson.teacher = self.teacher;
    lesson.students = selStu;
    lesson.lessonType = self.lessonType;
    if([self.pageType isEqualToString:@"Edit"]) {
        lesson.objectId = self.pageLesson.objectId;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:lesson, @"Lesson", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LessonConfirmed" object:nil userInfo:dict];
    [self dismissViewController:self];
}

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
