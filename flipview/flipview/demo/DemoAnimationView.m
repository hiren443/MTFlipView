//
//  DemoAnimationView.m
//  flipview
//
//  Created by zrz on 12-7-16.
//  Copyright (c) 2012年 Sctab. All rights reserved.
//

#import "DemoAnimationView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DemoAnimationView {
    UIImageView     *_topShadow,
                    *_downShadow;
}

static UIImage  *__image;
static UILabel  *__label;

@synthesize text = _text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!__image) {
            __image = [UIImage imageNamed:@"bg_detail_panelshadow"];
        }
        _topShadow = [[UIImageView alloc] initWithImage:__image];
        _topShadow.layer.transform = CATransform3DMakeRotation(- M_PI / 2, 0, 0, 1);
        _topShadow.frame = CGRectMake(0, -15, 320, 15);
        [self addSubview:_topShadow];
        
        _downShadow = [[UIImageView alloc] initWithImage:__image];
        _downShadow.layer.transform = CATransform3DMakeRotation(M_PI / 2, 0, 0, 1);
        _downShadow.frame = CGRectMake(0, 416, 320, 15);
        [self addSubview:_downShadow];
        
        self.backgroundColor = [UIColor blueColor];
        
        if (!__label) {
            __label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 220, 300)];
            __label.backgroundColor = [UIColor clearColor];
            __label.numberOfLines = 0;
            __label.textColor = [UIColor whiteColor];
        }
        
        //because of using global variables so it just suport one thread.
        self.mainQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
 */


/*-----------------------------------------------------
 *  when do over set data, call startRender it will 
 *  asynchronous render it.
 *-----------------------------------------------------
 */
- (void)setText:(NSString *)text
{
    _text = text;
    void (^block)(CGContextRef context) = ^(CGContextRef context){
        CGContextTranslateCTM(context, __label.frame.origin.x, __label.frame.origin.y);
        __label.text = text;
        [__label.layer renderInContext:context];
    };
    [self startRender:block];
}

- (void)setAnimationPercent:(CGFloat)percent coverdView:(MTFlipAnimationView *)coverdView
{
    CGRect bounds = self.bounds;
    CGFloat tp = 0;
    if (percent > 0) {
        tp = -percent;
        coverdView.frame = (CGRect){0, bounds.size.height * tp, bounds.size};
        self.frame = (CGRect){0,0,bounds.size};
    }else if (percent < 0){
        tp = -percent - 1;
        self.frame = (CGRect){0, bounds.size.height * tp, bounds.size};
    }else {
        self.frame = (CGRect){0,0,bounds.size};
    }
}

- (void)setPercent:(CGFloat)percent isUp:(BOOL)up isBorder:(BOOL)border
{
    CGRect bounds = self.bounds;
    if (border) {
        if (percent == 1) {
            percent = 1.1f;
        }
        if (percent == -1) {
            percent = -1.1;
        }
        percent = -percent / 2;
    }else {
        if (percent == -1) {
            percent = -1.1;
        }
        if (percent > 0) {
            percent = 0;
        }
    }
    self.frame = (CGRect){0, bounds.size.height * percent, bounds.size};
}

#pragma mark - override

- (void)moveUpOut:(MTFlipAnimationOverBlock)block 
       coverdView:(MTFlipAnimationView *)coverdView{
    [UIView transitionWithView:self
                      duration:0.4
                       options:UIViewAnimationCurveLinear
                    animations:^{
                        CGRect bounds = self.bounds;
                        self.frame = (CGRect){0, bounds.size.height * -1.1, bounds.size};
                    } completion:^(BOOL finished) {
                        if (block) block(finished);
                    }];
}

- (void)moveDownIn:(MTFlipAnimationOverBlock)block 
        coverdView:(MTFlipAnimationView *)coverdView{
    [UIView transitionWithView:self
                      duration:0.4
                       options:UIViewAnimationCurveLinear
                    animations:^{
                        CGRect bounds = self.bounds;
                        self.frame = (CGRect){0, 0, bounds.size};
                    } completion:^(BOOL finished) {
                        if (block) block(finished);
                    }];
}

- (void)restoreUp:(MTFlipAnimationView*)up
           down:(MTFlipAnimationView*)down
          block:(MTFlipAnimationOverBlock)block{
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect bounds = self.bounds;
                         self.frame = (CGRect){0, 0, bounds.size};
                         up.frame = (CGRect){0,-bounds.size.height * 1.1,bounds.size};
                     } completion:^(BOOL finished) {
                         if (block) {
                             block(finished);
                         }
                     }];
}

- (void)restoreAndShake:(MTFlipAnimationOverBlock)block{
    CGRect rect = self.frame;
    
    CGFloat hOffset = rect.origin.y;
    CGFloat sect = - hOffset / 3;
    [UIView animateWithDuration:0.25
                          delay:0 
                        options:UIViewAnimationCurveEaseOut
                     animations:^
     {
         CGRect bounds = self.bounds;
         self.frame = (CGRect){0, bounds.size.height * (sect / rect.size.height), bounds.size};
     } completion:^(BOOL finished) 
     {
         if (finished) {
             [UIView animateWithDuration:0.13
                                   delay:0
                                 options:UIViewAnimationCurveEaseInOut
                              animations:^
              {
                  CGRect bounds = self.bounds;
                  self.frame = (CGRect){0, 0, bounds.size};
              } completion:^(BOOL finished) 
              {
                  if (block) block(finished);
              }];
         }else {
             if (block) block(finished);
         }
     }];
}

@end