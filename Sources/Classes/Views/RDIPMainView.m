//
//  RDIPMainView.m
//  radikker
//
//  Created by saiten on 10/03/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "RDIPMainView.h"
#import "graphics_util.h"

@interface RDIPMeterView : UIView
@end


@implementation RDIPMeterView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	self.backgroundColor = [UIColor clearColor];
	return self;
}

- (void)createPath:(CGRect)rect context:(CGContextRef)context pinSize:(CGFloat)pinSize
{
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, rect.size.width/2, 0);
	CGContextAddLineToPoint(context, rect.size.width/2 + pinSize, pinSize);
	CGContextAddLineToPoint(context, rect.size.width, pinSize);
	CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
	CGContextAddLineToPoint(context, 0, rect.size.height);
	CGContextAddLineToPoint(context, 0, pinSize);
	CGContextAddLineToPoint(context, rect.size.width/2 - pinSize, pinSize);
	CGContextAddLineToPoint(context, rect.size.width/2, 0);
	CGContextClosePath(context);
}

- (void)drawRect:(CGRect)rect
{
	CGFloat pinSize = 16.0f;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);

	[self createPath:rect context:context pinSize:pinSize];
	CGContextClip(context);
	
	CGContextSimpleGradationDraw(context, rect, 
								 [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor,
								 [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0].CGColor);

	CGContextClipToRect(context, CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, pinSize+1.0f));
	[self createPath:rect context:context pinSize:pinSize];
	[[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0] set];
	CGContextStrokePath(context);
	
	CGContextRestoreGState(context);	
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)ev
{
	return nil;
}

@end

@implementation RDIPMainView

@synthesize tunerView, footerView, bannerView;

- (void)createShadows
{
	CGColorRef lightColorRef = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor;
	CGColorRef darkColorRef  = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2].CGColor;
	NSArray *downColors = [NSArray arrayWithObjects:(id)darkColorRef, (id)lightColorRef, nil];
	NSArray *upColors = [NSArray arrayWithObjects:(id)lightColorRef, (id)darkColorRef, nil];

	NSNumber *one  = [NSNumber numberWithFloat:1.0f];
	NSNumber *zero = [NSNumber numberWithFloat:0.0f];
	NSArray *locations = [NSArray arrayWithObjects:zero, one, nil];
		
	navigationBarShadowLayer = [[CAGradientLayer layer] retain];
	navigationBarShadowLayer.colors = downColors;
	navigationBarShadowLayer.locations = locations;
	navigationBarShadowLayer.zPosition = 10.0f;

	footerShadowLayer = [[CAGradientLayer layer] retain];
	footerShadowLayer.colors = upColors;
	footerShadowLayer.locations = locations;
	footerShadowLayer.zPosition = 10.0f;
	
	[self.layer addSublayer:navigationBarShadowLayer];
	[self.layer addSublayer:footerShadowLayer];
}

- (void)createViews
{
	self.backgroundColor = [UIColor blackColor];
	
	tunerView = [[RDIPTunerView alloc] initWithFrame:CGRectZero];
	meterView = [[RDIPMeterView alloc] initWithFrame:CGRectZero];
	containerView = nil;
	footerView = [[RDIPFooterView alloc] initWithFrame:CGRectZero];
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];

	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 260, 24)] autorelease];	
	UIImageView *iconView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speaker-white.png"]] autorelease];
	UIBarButtonItem *iconItem = [[[UIBarButtonItem alloc] initWithCustomView:iconView] autorelease];															
	UIBarButtonItem *volumeItem = [[[UIBarButtonItem alloc] initWithCustomView:volumeView] autorelease];	

	volumeBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	volumeBar.barStyle = UIBarStyleBlackTranslucent;
	volumeBar.items = [NSArray arrayWithObjects:iconItem, volumeItem, nil];
	[self hideVolumebar];
	
	[self addSubview:tunerView];
	//[self addSubview:footerView];
	[self addSubview:meterView];
    [self addSubview:bannerView];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self createViews];
		[self createShadows];
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat statusBarHeight = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame);
	CGRect rect = CGRectInset(self.frame, 0, 0);
    rect.origin.y = statusBarHeight;
    rect.size.height -= statusBarHeight;

    tunerView.frame     = CGRectMake(0, statusBarHeight, rect.size.width, 72);
	meterView.frame     = CGRectMake(0, statusBarHeight + 56, rect.size.width, rect.size.height - 56);
	containerView.frame = CGRectMake(0, statusBarHeight + 74, rect.size.width, rect.size.height - 74 - 50);
    bannerView.frame    = CGRectMake(0, statusBarHeight + rect.size.height - 50, rect.size.width, 50);
	//footerView.frame    = CGRectMake(0, statusBarHeight + rect.size.height - 16, rect.size.width, 16);
	volumeBar.frame     = CGRectMake(0, statusBarHeight + rect.size.height - 44, rect.size.width, 44);
	
	navigationBarShadowLayer.frame = CGRectMake(0, statusBarHeight, rect.size.width, 10);
	footerShadowLayer.frame        = CGRectMake(0, statusBarHeight + rect.size.height - 60, rect.size.width, 10);
}

- (UIView*)containerView
{
	return containerView;
}

- (void)setContainerView:(UIView *)v
{
	[containerView removeFromSuperview];
	[containerView release];
	containerView = [v retain];
	
	[self addSubview:v];
	[self layoutSubviews];
}

- (void)dealloc {
	[footerShadowLayer release];
	[navigationBarShadowLayer release];
	
	[meterView release];
	
	[tunerView release];
	[containerView release];
	[footerView release];
	
    [super dealloc];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *view = [super hitTest:point withEvent:event];
	if([self isShowVolumebar]) {
		BOOL isHit = ((point.x >= volumeBar.frame.origin.x && point.x < volumeBar.frame.origin.x + volumeBar.frame.size.width) 
					  && (point.y >= volumeBar.frame.origin.y && point.y < volumeBar.frame.origin.y + volumeBar.frame.size.height));
		if(!isHit)
			[self hideVolumebar];
	}
	return view;
}

- (BOOL)isShowVolumebar
{
	return volumeBar.alpha > 0 ? YES : FALSE;
}

- (void)showVolumebar
{
	[UIView beginAnimations:nil context:NULL];
	volumeBar.alpha = 1.0f;
	[self addSubview:volumeBar];
	[UIView commitAnimations];
}

- (void)hideVolumebar
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	volumeBar.alpha = 0.0f;
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[volumeBar removeFromSuperview];
}

@end
