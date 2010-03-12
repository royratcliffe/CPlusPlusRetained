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

// Importing CPlusPlus library headers assumes you have this
//
//	HEADER_SEARCH_PATHS = ../..
//
// within the project build settings. Adjust this to coincide with your own
// folder layout. By default, the CPlusPlusRetained iPhone app project lives
// within the CPlusPlus library project folder; hence ../.. searches for
// non-user headers start in the parent folder and therefore finds
// <CPlusPlus/c_plus_plus_retained.h>.
#import <CPlusPlus/c_plus_plus_retained.h>

class TestClass : public c_plus_plus_retained
{
public:
	TestClass(CPlusPlusRetainedViewController *controller) : controller(controller)
	{
		log("hello");
	}
	~TestClass()
	{
		log("goodbye");
	}
private:
	CPlusPlusRetainedViewController *controller;
	void log(const char *message)
	{
		[controller log:[NSString stringWithFormat:@"this=%p %s", this, message]];
	}
};

@implementation CPlusPlusRetainedViewController

@synthesize textView;

- (void)log:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	NSString *text = textView.text;
	if ([text length]) text = [text stringByAppendingString:@"\n"];
	textView.text = [text stringByAppendingString:formattedString];
	[formattedString release];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	textView.text = @"";
	[self log:@"Testing %d-%d-%d", 1, 2, 3];
	
	// leak
	[self log:@"\n--- leaking test"];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	new TestClass(self);
	// Running the Leaks instrument, you will find a 16-byte leak for this
	// object. You will see something like this in the leak log:
	//
	//	Leaked Object	Address		Size	Responsible Library	Responsible Frame
	//	TestClass	 	0x12a790	16		CPlusPlusRetained	-[CPlusPlusRetainedViewController viewDidLoad]
	//
	[pool release];
	
	// no leak
	[self log:@"\n--- non-leaking test"];
	pool = [[NSAutoreleasePool alloc] init];
	c_plus_plus_retained *retained = &(new TestClass(self))->retain();
	[pool release];
	[self log:@"retained=%p retainCount=%d", retained, [(id)retained->retainer() retainCount]];
	retained->release();
	
	// manually released
	[self log:@"\n--- manual releasing test"];
	pool = [[NSAutoreleasePool alloc] init];
	retained = &(new TestClass(self))->retain();
	[self log:@"retained=%p retainCount=%d", retained, [(id)retained->retainer() retainCount]];
	retained->release();
	// At this point, the object at "retained" has been de-allocated. Attempting
	// to access the memory at the pointer will typically crash the software.
	[pool release];
	
	// auto-released
	[self log:@"\n--- auto-releasing test"];
	pool = [[NSAutoreleasePool alloc] init];
	(new TestClass(self))->retain().autorelease();
	[pool release];
}

@end
