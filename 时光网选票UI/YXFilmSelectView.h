//
//  YXFilmSelectView.h
//  时光网选票UI
//
//  Created by yixiang on 15/12/27.
//  Copyright © 2015年 yixiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YXFilmSelectViewDelegate <NSObject>

-(void)itemSelected : (NSInteger)index;

@end

@interface YXFilmSelectView : UIView

@property (nonatomic, weak) id<YXFilmSelectViewDelegate> delegate;

-(instancetype)initViewWithImageArray:(NSArray *)imageArray;

@end
