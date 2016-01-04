//
//  YXFilmSelectView.m
//  时光网选票UI
//
//  Created by yixiang on 15/12/27.
//  Copyright © 2015年 yixiang. All rights reserved.
//

#import "YXFilmSelectView.h"

#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT    [[UIScreen mainScreen] bounds].size.height

#define NORMAL_VIEW_WIDTH 60
#define NORMAL_VIEW_HEIGHT 80

#define SELECT_VIEW_WIDTH 90
#define SELECT_VIEW_HEIGHT 120

#define ITEM_SPACE 30
#define LEFT_SPACE (SCREEN_WIDTH/2-NORMAL_VIEW_WIDTH/2)

@interface YXFilmSelectView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *viewArray;

@end

@implementation YXFilmSelectView

-(instancetype)initViewWithImageArray:(NSArray *)imageArray{
    if (!imageArray) {
        return nil;
    }
    if (imageArray.count<1) {
        return nil;
    }
    
    NSInteger totalNum = imageArray.count;
    self = [super initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 120)];
    if (self) {
        _scrollview = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollview.contentSize = CGSizeMake(LEFT_SPACE*2+SELECT_VIEW_WIDTH+(totalNum-1)*NORMAL_VIEW_WIDTH+(totalNum-1)*ITEM_SPACE, 120);
        _scrollview.delegate = self;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.decelerationRate = UIScrollViewDecelerationRateFast;
        [self addSubview:_scrollview];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, 0, _scrollview.contentSize.width+SCREEN_WIDTH*2, _scrollview.contentSize.height-20)];
        backView.backgroundColor = [UIColor lightGrayColor];
        [_scrollview addSubview:backView];
        
        _imageViewArray = [NSMutableArray array];
        _viewArray = [NSMutableArray array];
        
        CGFloat offsetX = LEFT_SPACE;
        for (int i=0; i<totalNum; i++) {
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, NORMAL_VIEW_HEIGHT, NORMAL_VIEW_HEIGHT)];
            [_scrollview addSubview:view];
            [_viewArray addObject:view];
            offsetX += NORMAL_VIEW_WIDTH+ITEM_SPACE;
            
            
            CGRect rect;
            if (i==0) {
                rect = CGRectMake(-(SELECT_VIEW_WIDTH-NORMAL_VIEW_WIDTH)/2, 0, SELECT_VIEW_WIDTH, SELECT_VIEW_HEIGHT);
            }else{
                rect = CGRectMake(0, 0, NORMAL_VIEW_WIDTH, NORMAL_VIEW_HEIGHT);
            }
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
            imageView.image = imageArray[i];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
            [imageView addGestureRecognizer:tap];
            [view addSubview:imageView];
            [_imageViewArray addObject:imageView];
        }

    }
    return self;
}

-(void)clickImage:(UITapGestureRecognizer *)tap{
    UIImageView *imageView = (UIImageView *)tap.view;
    NSInteger tag = imageView.tag;
    
    CGFloat offsetX = tag*(NORMAL_VIEW_WIDTH+ITEM_SPACE);
    
    
    [_scrollview scrollRectToVisible:CGRectMake(offsetX, 0, SCREEN_WIDTH, 120) animated:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(itemSelected:)]) {
        [_delegate itemSelected:tag];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int currentIndex = scrollView.contentOffset.x/(NORMAL_VIEW_WIDTH+ITEM_SPACE);
    if (currentIndex>_imageViewArray.count-2||currentIndex<0) {
        return;
    }
    int rightIndex = currentIndex+1;
    UIImageView *currentImageView = _imageViewArray[currentIndex];
    UIImageView *rightImageView = _imageViewArray[rightIndex];
    
    
    CGFloat scale =  (scrollView.contentOffset.x-currentIndex*(NORMAL_VIEW_WIDTH+ITEM_SPACE))/(NORMAL_VIEW_WIDTH+ITEM_SPACE);
    
    CGFloat width = SELECT_VIEW_WIDTH-scale*(SELECT_VIEW_WIDTH-NORMAL_VIEW_WIDTH);
    CGFloat height = SELECT_VIEW_HEIGHT-scale*(SELECT_VIEW_HEIGHT-NORMAL_VIEW_WIDTH);
    if (width<NORMAL_VIEW_WIDTH) {
        width = NORMAL_VIEW_WIDTH;
    }
    if (height<NORMAL_VIEW_HEIGHT) {
        height = NORMAL_VIEW_HEIGHT;
    }
    if (width>SELECT_VIEW_WIDTH) {
        width = SELECT_VIEW_WIDTH;
    }
    if (height>SELECT_VIEW_HEIGHT) {
        height = SELECT_VIEW_HEIGHT;
    }
    CGRect rect = CGRectMake(-(width-NORMAL_VIEW_HEIGHT)/2, 0, width, height);
    currentImageView.frame = rect;
    
    width = NORMAL_VIEW_WIDTH+scale*(SELECT_VIEW_WIDTH-NORMAL_VIEW_WIDTH);
    height = NORMAL_VIEW_HEIGHT+scale*(SELECT_VIEW_HEIGHT-NORMAL_VIEW_HEIGHT);
    if (width<NORMAL_VIEW_WIDTH) {
        width = NORMAL_VIEW_WIDTH;
    }
    if (height<NORMAL_VIEW_HEIGHT) {
        height = NORMAL_VIEW_HEIGHT;
    }
    if (width>SELECT_VIEW_WIDTH) {
        width = SELECT_VIEW_WIDTH;
    }
    if (height>SELECT_VIEW_HEIGHT) {
        height = SELECT_VIEW_HEIGHT;
    }
    rect = CGRectMake(-(width-NORMAL_VIEW_HEIGHT)/2, 0, width, height);
    rightImageView.frame = rect;
    
    
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        int currentIndex = roundf(scrollView.contentOffset.x/(NORMAL_VIEW_WIDTH+ITEM_SPACE));
        CGFloat offsetX = currentIndex*(NORMAL_VIEW_WIDTH+ITEM_SPACE);
        [_scrollview scrollRectToVisible:CGRectMake(offsetX, 0, SCREEN_WIDTH, 120) animated:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(itemSelected:)]) {
            [_delegate itemSelected:currentIndex];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int currentIndex = roundf(scrollView.contentOffset.x/(NORMAL_VIEW_WIDTH+ITEM_SPACE));
    CGFloat offsetX = currentIndex*(NORMAL_VIEW_WIDTH+ITEM_SPACE);
    [_scrollview scrollRectToVisible:CGRectMake(offsetX, 0, SCREEN_WIDTH, 120) animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(itemSelected:)]) {
        [_delegate itemSelected:currentIndex];
    }
}

@end
