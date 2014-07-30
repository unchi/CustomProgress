//
//  CustomProgress.m
//  CustomProgress
//
//  Created by unchi on 2014/02/06.
//  Copyright (c) 2014年 sugiyama-mitsunari. All rights reserved.
//

#import "UNCCustomProgress.h"


@interface UNCCustomProgress ()

typedef enum {
    StateNone,
    StateStart,
    StateEnd,
} State;


@property UIView* nextMask;
@property UIView* nextDialog;

@property UIView* mask;
@property UIView* dialog;

@property State request;
@property State state;
@property bool isAnim;

@end

@implementation UNCCustomProgress

static const float Speed = 0.2f;

// インスタンス取得
+ (UNCCustomProgress*)instance {
    static UNCCustomProgress* sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[UNCCustomProgress alloc] initSharedInstance];
    });
    return sharedSingleton;
}

//
- (id)initSharedInstance {
    self = [super init];
    if (self) {
        _request = StateNone;
        _state = StateNone;
        _isAnim = false;
    }
    return self;
}

// 初期化したらエラー
- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)animStartWithView:(UIView*)userView mask:(UIView*)userMask {
    
    if (_state == StateStart) return;

    _isAnim = true;
    _state = StateStart;
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    // mask
    if (userMask != nil) {
        _mask = userMask;
    } else {
        CGFloat w = window.frame.size.width;
        CGFloat h = window.frame.size.height;
        UIView* mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        mask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0.75f];
        _mask = mask;
    }
    
    _mask.layer.opacity = 0;
    [window addSubview:_mask];
    [window bringSubviewToFront:_mask];

    
    // dialog
    if (userView != nil) {
        _dialog = userView;
        _dialog.center = window.rootViewController.view.center;
        _dialog.layer.opacity = 0.5f;
        _dialog.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
        [window addSubview:_dialog];
        [window bringSubviewToFront:_dialog];    }

    [UIView animateWithDuration:Speed
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if (_mask != nil) {
                             _mask.layer.opacity = 1.0f;
                         }
                         if (_dialog != nil) {
                             _dialog.layer.opacity = 1.0f;
                             _dialog.layer.transform = CATransform3DMakeScale(1, 1, 1);
                         }
                     }
                     completion:^(BOOL finished) {

                         _isAnim = false;
                         [self animWithView:_dialog mask:_mask];
                     }];
}

- (void)animEnd {
    
    if (_state == StateEnd) return;
    
    _isAnim = true;
    _state = StateEnd;

    CATransform3D currentTransform = _dialog.layer.transform;
    
    [UIView animateWithDuration:Speed
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         
                         if (_mask != nil) {
                             _mask.layer.opacity = 0.0f;
                         }
                         if (_dialog != nil) {
                             _dialog.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                             _dialog.layer.opacity = 0.0f;
                         }
					 }
					 completion:^(BOOL finished) {
                         if (_mask != nil) {
                             [_mask removeFromSuperview];
                             _mask = nil;
                         }
                         if (_dialog != nil) {
                             [_dialog removeFromSuperview];
                             _dialog = nil;
                         }

                         _isAnim = false;
                         [self animWithView:_nextDialog mask:_nextMask];
					 }
	 ];
}

- (void)animWithView:(UIView*)view mask:(UIView*)mask {
    
    if (_isAnim) return;
    
    if (_request == StateStart) {
        _request = StateNone;
        
        [self animStartWithView:view mask:mask];

    } else
    if (_request == StateEnd) {
        _request = StateNone;
        
        [self animEnd];
    }
    
}


- (void)showWithView:(UIView*)view {
    [self showWithView:view mask:nil];
}

- (void)showWithView:(UIView*)view mask:(UIView*)mask {
    
    _request = StateStart;
    _nextMask = mask;
    _nextDialog = view;
    
    [self animWithView:view mask:mask];
}

- (void)dismiss {

    _request = StateEnd;

    [self animWithView:nil mask:nil];
}

@end
