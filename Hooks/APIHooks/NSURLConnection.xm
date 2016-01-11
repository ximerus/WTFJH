#import "../SharedDefine.pch"
%group NSURLConnection
%hook NSURLConnection
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
	NSData *origResult = %orig(request, response, error);
	CallTracer *tracer = [[CallTracer alloc] initWithClass:@"NSURLConnection" andMethod:@"sendSynchronousRequest:returningResponse:error:"];
	[tracer addArgFromPlistObject:[PlistObjectConverter convertNSURLRequest:request] withKey:@"request"];
	[tracer addArgFromPlistObject:[RuntimeUtils propertyListForObject:*response] withKey:@"response"];
	[tracer addArgFromPlistObject:[RuntimeUtils propertyListForObject:*error] withKey:@"error"];
	[tracer addReturnValueFromPlistObject:origResult];
	[[SQLiteStorage sharedManager] saveTracedCall:tracer];
	 
	return origResult;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate {

	// Proxy the delegate so we can hook it
	NSURLConnectionDelegateProx *delegateProxy = [[NSURLConnectionDelegateProx alloc] initWithOriginalDelegate:delegate];
	id origResult = %orig(request, delegateProxy);

	CallTracer *tracer = [[CallTracer alloc] initWithClass:@"NSURLConnection" andMethod:@"initWithRequest:delegate:"];
	[tracer addArgFromPlistObject:[PlistObjectConverter convertNSURLRequest:request] withKey:@"request"];
	[tracer addArgFromPlistObject:[PlistObjectConverter convertDelegate:delegate followingProtocol:@"NSURLConnectionDelegate"] withKey:@"delegate"];
	[tracer addReturnValueFromPlistObject: objectTypeNotSupported];
	[[SQLiteStorage sharedManager] saveTracedCall:tracer];
	 
	return origResult;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate startImmediately:(BOOL)startImmediately {

	// Proxy the delegate so we can hook it
	NSURLConnectionDelegateProx *delegateProxy = [[NSURLConnectionDelegateProx alloc] initWithOriginalDelegate:delegate];
	id origResult = %orig(request, delegateProxy, startImmediately);

	CallTracer *tracer = [[CallTracer alloc] initWithClass:@"NSURLConnection" andMethod:@"initWithRequest:delegate:startImmediately:"];
	[tracer addArgFromPlistObject:[PlistObjectConverter convertNSURLRequest:request] withKey:@"request"];
	[tracer addArgFromPlistObject:[PlistObjectConverter convertDelegate:delegate followingProtocol:@"NSURLConnectionDelegate"] withKey:@"delegate"];
	[tracer addArgFromPlistObject:[NSNumber numberWithBool:startImmediately] withKey:@"startImmediately"];
	[tracer addReturnValueFromPlistObject: objectTypeNotSupported];
	[[SQLiteStorage sharedManager] saveTracedCall:tracer];
	 
	return origResult;
}


// The following methods are not explicitely part of NSURLConnection.
// However, when implementing custom cert validation using the NSURLConnectionDelegate protocol,
// the application sends the result of the validation (server cert was OK/bad) to [challenge sender].
// The class of [challenge sender] is NSURLConnection because it implements the NSURLAuthenticationChallengeSender
// protocol. So we're hooking this in order to find when the validation might have been disabled.

// The usual way of disabling SSL cert validation
- (void)continueWithoutCredentialForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	%orig(challenge);
	CallTracer *tracer = [[CallTracer alloc] initWithClass:@"NSURLConnection" andMethod:@"continueWithoutCredentialForAuthenticationChallenge:"];
	[tracer addArgFromPlistObject:[PlistObjectConverter convertNSURLAuthenticationChallenge: challenge] withKey:@"challenge"];
	[[SQLiteStorage sharedManager] saveTracedCall:tracer];
	 
}

// Might indicate client certificates or cert pinning. TODO: Investigate
- (void)useCredential:(NSURLCredential *)credential forAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	%orig(credential, challenge);
	CallTracer *tracer = [[CallTracer alloc] initWithClass:@"NSURLConnection" andMethod:@"useCredential:forAuthenticationChallenge:"];
	[tracer addArgFromPlistObject:[PlistObjectConverter convertNSURLCredential:credential] withKey:@"credential"];
	[tracer addArgFromPlistObject:[PlistObjectConverter convertNSURLAuthenticationChallenge: challenge] withKey:@"challenge"];
	[[SQLiteStorage sharedManager] saveTracedCall:tracer];
	 
}

%end
%end
extern void init_NSURLConnection_hook(){
%init(NSURLConnection);
}
