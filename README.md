##一、项目简介
该项目利用UIScrollView的各种滚动事件的监听，仿造时光网选择电影票的UI而开发的一个自定义View。使用简单，可扩展性很强。具备点击每个Item进行选票功能，选票居中功能，滑动时自动选择距离中间最近的View处于选中状态，而且对于滑动时松开手的时候是否有初始速度进行了区分处理。案例演示如下：<br/>![仿时光网选票UI](http://img.my.csdn.net/uploads/201601/05/1451968837_3300.gif)

##二、项目讲解
####1、初始化UIScrollView中每个Item的View，把每个View放到_viewArray数组中，方便接下来的定位和管理。每一个View中包含一个UIImageView，把每一个UIImageView放在_imageViewArray数组中，方便接下来的进行随着滑动的放大和缩小操作。

```
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

UIView *view = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, NORMAL_VIEW_WIDTH, NORMAL_VIEW_HEIGHT)];
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
```
####2、在滑动的过程中，我们实时的需要改变计算哪一个Item距离中间最近，在过渡到最中间的过程中，选中的Item距离中间越近，选中Item的frame越大，反则越小。

```
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
int currentIndex = scrollView.contentOffset.x/(NORMAL_VIEW_WIDTH+ITEM_SPACE);
if (currentIndex>_imageViewArray.count-2||currentIndex<0) {
return;
}
int rightIndex = currentIndex+1;
UIImageView *currentImageView = _imageViewArray[currentIndex];
UIImageView *rightImageView = _imageViewArray[rightIndex];


CGFloat scale =  (scrollView.contentOffset.x-currentIndex*(NORMAL_VIEW_WIDTH+ITEM_SPACE))/(NORMAL_VIEW_WIDTH+ITEM_SPACE);

//NSLog(@"%f",scale);

CGFloat width = SELECT_VIEW_WIDTH-scale*(SELECT_VIEW_WIDTH-NORMAL_VIEW_WIDTH);
CGFloat height = SELECT_VIEW_HEIGHT-scale*(SELECT_VIEW_HEIGHT-NORMAL_VIEW_HEIGHT);
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
CGRect rect = CGRectMake(-(width-NORMAL_VIEW_WIDTH)/2, 0, width, height);
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
rect = CGRectMake(-(width-NORMAL_VIEW_WIDTH)/2, 0, width, height);
NSLog(@"%@",NSStringFromCGRect(rect));
rightImageView.frame = rect;
}

```
####3、点击某一个Item，让Item处于中间选中状态。

```
-(void)clickImage:(UITapGestureRecognizer *)tap{
UIImageView *imageView = (UIImageView *)tap.view;
NSInteger tag = imageView.tag;

UIView *containerView = _viewArray[tag];

CGFloat offsetX = CGRectGetMidX(containerView.frame)-SCREEN_WIDTH/2;


[_scrollview scrollRectToVisible:CGRectMake(offsetX, 0, SCREEN_WIDTH, 120) animated:YES];

if (_delegate && [_delegate respondsToSelector:@selector(itemSelected:)]) {
[_delegate itemSelected:tag];
}

}
```
####4、当用户在滑动结束，并具有初始速度的时候，当滑动停止的时候，我们需要把距离中间最近Item定位到最中间。

```
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
int currentIndex = roundf(scrollView.contentOffset.x/(NORMAL_VIEW_WIDTH+ITEM_SPACE));
UIView *containerView = _viewArray[currentIndex];
CGFloat offsetX = CGRectGetMidX(containerView.frame)-SCREEN_WIDTH/2;
[_scrollview scrollRectToVisible:CGRectMake(offsetX, 0, SCREEN_WIDTH, 120) animated:YES];
if (_delegate && [_delegate respondsToSelector:@selector(itemSelected:)]) {
[_delegate itemSelected:currentIndex];
}
}
```
####5、当用户在滑动结束的时候，但是没有初始速度的时候，此时不会触发-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView方法，我们需要在-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate方法中，进行处理。

```
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
if (!decelerate) {
int currentIndex = roundf(scrollView.contentOffset.x/(NORMAL_VIEW_WIDTH+ITEM_SPACE));
UIView *containerView = _viewArray[currentIndex];
CGFloat offsetX = CGRectGetMidX(containerView.frame)-SCREEN_WIDTH/2;
[_scrollview scrollRectToVisible:CGRectMake(offsetX, 0, SCREEN_WIDTH, 120) animated:YES];
if (_delegate && [_delegate respondsToSelector:@selector(itemSelected:)]) {
[_delegate itemSelected:currentIndex];
}
}
}
```
####6、注意点，设置_scrollview.decelerationRate = UIScrollViewDecelerationRateFast;减慢UIScrollView滑动速度。会使用户体验更好。

##三、项目使用
####1、本项目支持CocosPod，引用工程代码如下：

```
pod 'YXFilmSelectView', '~> 0.0.1'
```
####2、使用方法

```
YXFilmSelectView *filmSelectView = [[YXFilmSelectView alloc] initViewWithImageArray:imageArray];
filmSelectView.delegate = self;
[self.view addSubview:filmSelectView];
```
####3、提供YXFilmSelectViewDelegate代理，用于每一个Item处于选中状态的处理。

```
- (void)itemSelected:(NSInteger)index{
_containerView.backgroundColor = _colorArray[index%_colorArray.count];
_showLabel.text = [NSString stringWithFormat:@"%zi",index];
}
```

##四、Demo下载地址
[Demo下载地址](https://github.com/yixiangboy/YXFilmSelectView)<br/>如果对你有点帮助，star一下吧。


##五、联系方式
微博：[新浪微博](http://weibo.com/5612984599/profile?topnav=1&wvr=6)<br/>博客：[http://blog.csdn.net/yixiangboy ](http://blog.csdn.net/yixiangboy)<br/>github：[https://github.com/yixiangboy](https://github.com/yixiangboy)