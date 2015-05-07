//
//  SelectTeacherViewController.m
//  Education
//
//  Created by Feicun on 15/5/4.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "SelectTeacherViewController.h"
#import "CollectionItem.h"

@interface SelectTeacherViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) NSCollectionView *teacherCV;
@property (strong, nonatomic) NSSearchField *teacherSearch;
@property (strong, nonatomic) NSMutableArray *teacherArray;
//用于检索 联想时用  存名字
@property (strong, nonatomic) NSMutableArray *tchSchArr;
@property (strong, nonatomic) User *selTch;

@property (strong, nonatomic) NSTableView *teacherTV;
@property (strong, nonatomic) NSMutableArray *tableArr;

@end

@implementation SelectTeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDataFromCloud];
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
        
//        NSImage *picture = [NSImage imageNamed:@"jc.jpg"];
//        user.image = picture;
        user.isSelected = NO;
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:user, @"User", nil];
        if ([user.type isEqualTo:@"Teacher"]) {
            [self.tchSchArr addObject:user];
            [self.teacherArray addObject:tempDic];
        }
    }
    self.tableArr = self.tchSchArr;
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
    //[self.view addSubview:teacherScroll];
    
    self.teacherSearch = [[NSSearchField alloc] initWithFrame:NSMakeRect(20, 200, 100, 20)];
    self.teacherSearch.target = self;
    self.teacherSearch.action = @selector(searchTeacher:);
    [self.view addSubview:self.teacherSearch];

    self.teacherTV = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    self.teacherTV.dataSource = self;
    self.teacherTV.delegate = self;
    
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"NameCol"];
    [[column headerCell] setStringValue:@"结果"];
    //[[column headerCell] setHidden:YES];
    [column setWidth:100.0];
    [column setEditable:NO];
    [column setResizingMask:NSTableColumnAutoresizingMask | NSTableColumnUserResizingMask];
    [self.teacherTV addTableColumn:column];
    
    
    NSScrollView *tableScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 100, 100, 100)];
    teacherScroll.hasVerticalScroller = YES;
    teacherScroll.hasHorizontalScroller = NO;
    [teacherScroll setAutohidesScrollers:YES];
    [tableScroll setDocumentView:self.teacherTV];
    [self.view addSubview:tableScroll];
}

//实现单选  点击item 发送通知传入item信息   接收通知后 返回一个通知 回传给所有item  将之前选择的item清空
- (void)searchTeacher:(id)sender {
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:self.tchSchArr];
    if ([self.teacherSearch.stringValue isEqualToString:@""] || !self.teacherSearch.stringValue) {
        //[self.teacherCV setContent:self.teacherArray];
        self.tableArr = self.tchSchArr;
        [self.teacherTV reloadData];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realName like[c] %@",[NSString stringWithFormat:@"%@*",self.teacherSearch.stringValue]];
        //联想
        [tempArr filterUsingPredicate:predicate];
        self.tableArr = tempArr;
        [self.teacherTV reloadData];
//        NSMutableArray *arr = [[NSMutableArray alloc] init];
//        for (int i = 0; i < tempArr.count; i++) {
//            [arr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:tempArr[i], @"User", nil]];
//        }
//        [self.teacherCV setContent:arr];
    }
    //NSLog(@"temArr count:%li", tempArr.count);
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
    NSLog(@"%@", ((User *)self.tableArr[sender.tag]).realName);
}
@end
