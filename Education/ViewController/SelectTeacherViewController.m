//
//  SelectTeacherViewController.m
//  Education
//
//  Created by Feicun on 15/5/4.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "SelectTeacherViewController.h"
#import "CollectionItem.h"

@interface SelectTeacherViewController ()

@property (strong, nonatomic) NSCollectionView *teacherCV;
@property (strong, nonatomic) NSSearchField *teacherSearch;
@property (strong, nonatomic) NSMutableArray *teacherArray;
//用于检索 联想时用  存名字
@property (strong, nonatomic) NSMutableArray *tchSchArr;
@property (strong, nonatomic) User *selTch;

@end

@implementation SelectTeacherViewController

- (void)viewDidLoad {
    [self loadDataFromCloud];
    [super viewDidLoad];
    [self initTeacher];
    [self initButton];
    // Do view setup here.
}

- (void)initButton {
    NSButton *tchBtn = [[NSButton alloc] initWithFrame:NSMakeRect(0, 250, 100, 25)];
    tchBtn.title = @"选择老师";
    [tchBtn setButtonType:NSMomentaryPushInButton];
    //响应点击事件 需要设置 action 和 target
    [tchBtn setAction:@selector(save:)];
    [tchBtn setTarget:self];
    tchBtn.bezelStyle = NSRoundRectBezelStyle;
    [self.view addSubview:tchBtn];
}

- (void)save:(NSButton *)sender {
    if (self.selTch) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.selTch, @"Teacher", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TeacherSelected" object:nil userInfo:dict];
        [self dismissViewController:self];
    }
}

- (void)loadDataFromCloud {
    AVQuery *query = [AVUser query];
    //[query whereKey:@"type" equalTo:@"Student"];
    NSArray *arr = [query findObjects];
    self.teacherArray = [[NSMutableArray alloc] init];
    self.tchSchArr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [arr count]; i++) {
        AVUser *tempUser = (AVUser *)arr[i];
        
        User *user = [[User alloc] initWithAVUser:tempUser];
        
        NSImage *picture = [NSImage imageNamed:@"jc.jpg"];
        user.image = picture;
        user.isSelected = NO;
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:user, @"User", nil];
        if ([user.type isEqualTo:@"Teacher"]) {
            [self.tchSchArr addObject:user];
            [self.teacherArray addObject:tempDic];
        }
    }
}

- (void)itemClick:(NSNotification *)notification {
    self.selTch = [notification.userInfo objectForKey:@"User"];
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DisOtherItem" object:nil userInfo:notification.userInfo];
    } @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
    }
//    for (NSMutableDictionary *dict in self.teacherArray) {
//        User *tchUser = [dict objectForKey:@"User"];
//        //NSLog(@"%@", tchUser.username);
//        if ([self.selTch.username isEqualTo:tchUser.username]) {
//            //tchUser.isSelected = self.selTch.isSelected;
//        } else {
//            tchUser.isSelected = NO;
//            self.selTch.isSelected = NO;
//        }
//    }

}

- (void)initTeacher {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemClick:) name:@"ItemClick" object:nil];
    self.teacherCV = [[NSCollectionView alloc] initWithFrame:NSMakeRect(0, 0, 420, 150)];
    //self.teacherCV.delegate = self;
    [self.teacherCV setItemPrototype:[CollectionItem new]];
    [self.teacherCV setContent:self.teacherArray];
    [self.teacherCV setMaxNumberOfRows:1];
    //[self.teacherCV setAutoresizingMask:(NSViewMinXMargin | NSViewWidthSizable | NSViewMaxXMargin | NSViewMinYMargin  | NSViewHeightSizable| NSViewMaxYMargin)];
    //[self.teacherCV setAutoresizesSubviews:YES];
    self.teacherCV.selectable = YES;
    self.teacherCV.allowsMultipleSelection = NO;
    NSScrollView *teacherScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 420, 150)];
    teacherScroll.hasVerticalScroller = YES;
    teacherScroll.hasHorizontalScroller = YES;
    [teacherScroll setAutohidesScrollers:YES];
    [teacherScroll setDocumentView:self.teacherCV];
    [self.view addSubview:teacherScroll];
    
    self.teacherSearch = [[NSSearchField alloc] initWithFrame:NSMakeRect(20, 200, 100, 20)];
    self.teacherSearch.target = self;
    self.teacherSearch.action = @selector(searchTeacher:);
    [self.view addSubview:self.teacherSearch];
}

//实现单选  点击item 发送通知传入item信息   接收通知后 返回一个通知 回传给所有item  将之前选择的item清空
#warning 联想过后 点击会出问题
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
    NSLog(@"temArr count:%li", tempArr.count);
}

@end
