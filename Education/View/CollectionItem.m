//
//  CollectionItem.m
//  Education
//
//  Created by Feicun on 15/4/30.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "CollectionItem.h"

@interface ItemView ()

@property (strong, nonatomic) NSImageView *imageView;
@property (strong, nonatomic) NSTextField *textField;
@property (strong, nonatomic) User *user;
//@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL disable;//用于查看

@end

@implementation ItemView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:NSMakeRect(frameRect.origin.x, frameRect.origin.y, 120, 150)];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disClickItem:) name:@"DisOtherItem" object:nil];
        [self setTitlePosition:NSNoTitle];
        self.user = [[User alloc] init];
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 30, 120, 120)];
        self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 120, 30)];
        self.textField.font = [NSFont systemFontOfSize:15];
        self.textField.backgroundColor = [NSColor clearColor];
        self.textField.editable = NO;
        self.textField.selectable = NO;
        self.textField.bordered = NO;
        self.textField.alignment = NSCenterTextAlignment;
        
//        self.isSelected = NO;
//        //必须和属性名一致
//        [self setValue:[NSNumber numberWithBool:self.isSelected] forKey:@"isSelected"];
//        [self addObserver:self forKeyPath:@"isSelected" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        
        [self addSubview:self.imageView];
        [self addSubview:self.textField];
    }
    return self;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if([keyPath isEqualToString:@"isSelected"]) {
//        [self setNeedsDisplay:YES];
//    }
//}

- (void)disClickItem:(NSNotification *)notification {
#warning 联想之后 进来的self.user 为空  为什么?
    @try {
        User *tempUser = [notification.userInfo objectForKey:@"User"];
        NSLog(@"%@, %@, %@", self.user.username, self.user.type, self);
        if ([tempUser.type isEqualTo:self.user.type]) {
            if ([self.user.type isEqualTo:@"Teacher"]) {
                if (![tempUser.username isEqualTo:self.user.username]) {
                    self.user.isSelected = NO;
                } else {
                    self.user.isSelected = YES;
                }
            }
            [self setNeedsDisplay:YES];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
    }
}

- (void)setRepresentedObject:(id)representedObject {
    self.user = [representedObject objectForKey:@"User"];
    self.imageView.image = self.user.image;
    self.textField.stringValue = self.user.username;
    if ([representedObject objectForKey:@"Check"]) {
        self.disable = YES;
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    //self.isSelected = !self.isSelected;
#warning 出现过问题  是否需要根据 type不同发送不同通知
    if (!self.disable) {
        self.user.isSelected = !self.user.isSelected;
        [self setNeedsDisplay:YES];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.user, @"User", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ItemClick" object:nil userInfo:dict];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    if (self.user.isSelected) {
        [[NSColor grayColor] setFill];
    } else {
        [[NSColor whiteColor] setFill];
    }
    NSRectFill(dirtyRect);
}

@end


@interface CollectionItem ()

@property (strong, nonatomic, retain) ItemView *itemView;

@end

@implementation CollectionItem

- (void)viewDidLoad {
    [super viewDidLoad];
    self.identifier = @"CollectionItem";
    // Do view setup here.
}

- (void)loadView {
    self.itemView = [[ItemView alloc] initWithFrame:NSZeroRect];
//    self.itemView.delegate = self;
    [self setView:self.itemView];
//    @try {
//        //[self addObserver:self forKeyPath:@"SelfUser" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//        //[self setValue:self.itemView.user forKey:@"SelfUser"];
//    } @catch (NSException *exception) {
//        NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
//    }
//   
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    //NSLog(@"%@", ((User *)representedObject).username);
    if ([representedObject objectForKey:@"User"]) {
        [((ItemView *)[self view]) setRepresentedObject:representedObject];
    }
}

//- (void)itemClick:(ItemView *)item {
//    [self.delegate collectionItemClick:item];
//}

@end
