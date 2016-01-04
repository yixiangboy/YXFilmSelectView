//
//  ViewController.m
//  时光网选票UI
//
//  Created by yixiang on 15/11/27.
//  Copyright © 2015年 yixiang. All rights reserved.
//

#import "ViewController.h"
#import "YXFilmSelectView.h"

#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT    [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()<UIScrollViewDelegate,YXFilmSelectViewDelegate>

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *showLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    for (int i=0; i<12; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%zi.jpg",i+1]];
        [imageArray addObject:image];
    }
    _colorArray = @[[UIColor cyanColor],
                    [UIColor yellowColor],
                    [UIColor magentaColor],
                    [UIColor orangeColor],
                    [UIColor purpleColor],
                    [UIColor brownColor]
                    ];
    
    YXFilmSelectView *filmSelectView = [[YXFilmSelectView alloc] initViewWithImageArray:imageArray];
    filmSelectView.delegate = self;
    [self.view addSubview:filmSelectView];
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(filmSelectView.frame),SCREEN_WIDTH , SCREEN_HEIGHT-CGRectGetMaxY(filmSelectView.frame))];
    [self.view addSubview:_containerView];
    
    _showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_containerView.frame)/2-30, SCREEN_WIDTH, 60)];
    _showLabel.textColor = [UIColor blackColor];
    _showLabel.font = [UIFont systemFontOfSize:60.];
    _showLabel.textAlignment = NSTextAlignmentCenter;
    [_containerView addSubview:_showLabel];
    
    [self itemSelected:0];
}

- (void)itemSelected:(NSInteger)index{
    _containerView.backgroundColor = _colorArray[index%_colorArray.count];
    _showLabel.text = [NSString stringWithFormat:@"%zi",index];
}

@end
