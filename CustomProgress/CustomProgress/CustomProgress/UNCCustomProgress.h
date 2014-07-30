//
//  CustomProgress.h
//  CustomProgress
//
//  Created by unchi on 2014/02/06.
//  Copyright (c) 2014年 sugiyama-mitsunari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UNCCustomProgress : NSObject

+ (id)instance;

- (void)showWithView:(UIView*)view;
- (void)showWithView:(UIView*)view mask:(UIView*)mask;
- (void)dismiss;

@end
