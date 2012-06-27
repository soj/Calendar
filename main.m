//
//  main.m
//  calendar
//
//  Created by Fravic Fernando on 12-03-20.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, nil);
        return retVal;
    }
}

BOOL timesIntersect(NSTimeInterval s1, NSTimeInterval e1, NSTimeInterval s2, NSTimeInterval e2) {
	return (s1 > s2 && s1 < e2) || (e1 > s2 && e1 < e2) || (s1 < s2 && e1 > e2);
}
