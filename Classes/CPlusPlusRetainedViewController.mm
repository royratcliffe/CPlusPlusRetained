// CPlusPlusRetained CPlusPlusRetainedViewController.m
//
// Copyright © 2010, Roy Ratcliffe, Pioneering Software, United Kingdom
// All rights reserved
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "CPlusPlusRetainedViewController.h"

@implementation CPlusPlusRetainedViewController

@synthesize textView;

- (void)log:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	NSString *text = textView.text;
	if ([text length])
	{
		text = [text stringByAppendingString:@"\n"];
	}
	textView.text = [text stringByAppendingString:formattedString];
	[formattedString release];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	textView.text = @"";
	[self log:@"Testing %d-%d-%d", 1, 2, 3];
}

@end
