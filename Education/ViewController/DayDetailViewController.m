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


@end

@implementation DayDetailViewController

#pragma -mark 界面初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *titleStr = [NSString stringWithFormat:@"%@年%@月%@日", [self.dateDict objectForKey:@"Year"], [self.dateDict objectForKey:@"Month"], [self.dateDict objectForKey:@"Day"]];
    self.title = titleStr;
    [self initHours];
    self.listenArray = [self funcArrayWithType:1];
    self.speakArray = [self funcArrayWithType:2];
    self.readArray = [self funcArrayWithType:3];
    self.writeArray =[self funcArrayWithType:4];
    self.timeArray = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < 24; i++) {
        [self.timeArray setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", i + 1]];
    }
    
    [self initButton];
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
    } else {
        
    }
}

#warning 从数据库读取
//听说读写 四列块的初始化
- (NSMutableArray *)funcArrayWithType:(int)type {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 24; i++) {
        FuncBlockView *func = [[FuncBlockView alloc] initWithFrame:NSMakeRect(100 * type, SCREEN_HEIGHT / 24 * i - i, 100, SCREEN_HEIGHT / 24) withType:type andEditable:self.isEditable];
        func.delegate = self;
        func.time = 24 - i;
        [array addObject:func];
        [self.view addSubview:func];
    }
    return array;
}
//根据块类型返回相应Array
- (NSMutableArray *)getFuncArrayByType:(int)type {
    switch (type) {
        case 1:
            return self.listenArray;
            break;
        case 2:
            return self.speakArray;
            break;
        case 3:
            return self.readArray;
            break;
        case 4:
            return self.writeArray;
            break;
        default:
            return nil;
            break;
    }
}
//24小时的初始化
- (void)initHours {
    for (int i = 0; i < 24; i++) {
        NSTextField *tf = [[NSTextField alloc] initWithFrame:NSMakeRect(0, SCREEN_HEIGHT / 24 * i - i, 100, SCREEN_HEIGHT / 24)];
        tf.stringValue = [NSString stringWithFormat:@"%i:00", 24 - i];
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
    NSMutableArray *column = [self getFuncArrayByType:(int)sender.tag];
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
        [self.timeArray setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", i + 1]];
        FuncBlockView *bv = self.listenArray[i];
        [bv didSelected:NO];
        bv = self.speakArray[i];
        [bv didSelected:NO];
        bv = self.readArray[i];
        [bv didSelected:NO];
        bv = self.writeArray[i];
        [bv didSelected:NO];
    }
}
//保存
- (void)saveChange:(NSButton *)sender {
    [self dismissViewController:self];
}

#pragma -mark 鼠标事件
- (void)mouseUp:(NSEvent *)theEvent {
    if (self.tempBlock.isSelected) {
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
                }
            }
        }
    }
}

- (void)clickBlock:(FuncBlockView *)blockView {
    self.tempBlock = blockView;
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
        pick.lessonType = self.tempBlock.type;
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