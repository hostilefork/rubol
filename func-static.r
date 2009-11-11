REBOL [
	Title: "Rebol Functions with Static Locals"

	Purpose: "Easy-to-use alternative to closure for static local variables"

	Description: {Rebol 3 introduced closures as a native feature of the
	language and shows examples of using them to declare functions which 
	capture and retain state between function calls.  However, working with
	the 2-step process and having to think in terms of returning functions
	from within a closure can be overwhelming.

	This defines func-static, which is for people who just want a function to
	accumulate state of its own but not pollute the parent context.  As a
	further feature to test out, it can automatically provide a reset 
	refinement for resetting the static locals to the expressions that
	were used to initialize them.

	I've also added something called "funct-def" as a helper for Ruby
	interoperability which can accept defaults.  It may be useful in its
	own right, although it does diverge from Rebol's model of every
	function callsite having the argument count in advance.

	!!!WARNING: This is very experimental right now and I would like some
	people with more experience writing these sorts of things to give it
	a look.  It needs error handling and a lot of other things.  (Also there 
	should be variants for the different function types and not just func)
	Locals are not being handled in proper "funct" form yet!!!
	}

	Author: "Hostile Fork"
	Home: http://hostilefork.com
	License: mit

	File: %func-static.r
	Date: 9-Nov-2009
	Version: 0.1.0

	; Header conventions: http://www.rebol.org/one-click-submission-help.r
	Type: function
	Level: advanced
    
	Usage: { Imagine you want a function that prints out a string and also
	counts the number of times it is called:

		printAndCount: func-static [s [string!]] [numCalls: 0] [
			print s
			numCalls: numCalls + 1 
			print rejoin ["(numCalls: " numCalls ")"]
		]

	The first block is the usual function spec.  The second is a list of
	static local variables and their initial values.

		>> printAndCount "Hello"
		Hello
		(numCalls: 1)

		>> printAndCount "Goodbye" 
		Goodbye
		(numCalls: 2)

	Additionally, if you would like to be able to make a call reset the static
	variables, use the resettable refinement.

		printAndCount: func-static/resettable [s [string!]] [numCalls: 0] [
			print s
			numCalls: numCalls + 1 
			print rejoin ["(numCalls: " numCalls ")"]
		]

		>> printAndCount "Hello"
		Hello
		(numCalls: 1)

		>> printAndCount "Goodbye" 
		Goodbye
		(numCalls: 2)

		>> printAndCount/reset "World" 
		World
		(numCalls: 1)

	You can use expressions to initialize the defaults of the local variables.  They
	will be evaluated in the context where you defined the static function, and this
	context is remembered for when you reset:

		globalString: "Hello"
		doubleAndAppend: func-static/resettable [arg [integer!]] [
			onePlusOne: 1 + 1 
			message: globalString
		] [
			print rejoin ["onePlusOne * arg = " onePlusOne * arg]
			append message " World" 
			print rejoin ["message: " message newline]
		]

		doubleAndAppend 3
		doubleAndAppend 4

		globalString: "Goodbye"

		use [globalString] [
			globalString: "Reset should capture {Goodbye} instead!!!"

			doubleAndAppend/reset 5
		]

	The code above will output:

		onePlusOne * arg = 6
		message: Hello World

		onePlusOne * arg = 8
		message: Hello World World

		onePlusOne * arg = 10
		message: Goodbye World
    }

    History: [
        0.1.0 [9-Nov-2009 {Private deployment to Rebol community for feedback.} "Fork"]
    ]
]

get-parameter-information: func [parameters [block!] /local result expression pos] [

	; Imagine you have something like:
	;
	;	[a b [block!] c: 3 + 4 d: "hello"]
	;
	; This routine analyzes that and gives you back an object with two fields.  One is 
	; a spec (suitable for use in a function definition) and the other is a
	; list of defaults.  In this case the result would be:
	;
	; [
	;	spec: [a b [block!] c d]
	; 	defaults: [none none (3 + 4) ("hello")]
	; ]

	result: copy/deep [spec: [] defaults: []]

	pos: head parameters
	while [not tail? pos] [
		either set-word? first pos [
			; If we encounter a set-word, build an expression out of the
			; list members up until the next set-word

			expression: to-paren []
			append/only result/spec to-word first pos
			while [(not tail? next pos) and (not set-word? second pos)] [
				append/only expression second pos
				pos: next pos
			]
			append/only result/defaults expression
		] [
			; For everything else, just pass it through to the parameters.
			; If we see an unadorned word value then also put "none" in the 
			; defaults list

			append/only result/spec first pos
			if word? first pos [
				append/only result/defaults none
			]

			; TODO think about refinements.  They are not really compatible with
			; positional ideas like this
		]
		pos: next pos
	]

	return result
]

funct-static: func [spec [block!] statics [block!] body [block!] /with withObject /resettable /local objSpec staticsInfo] [

	; We are going to make an object which initializes some local members to look
	; just like the statics parameter

	objSpec: copy statics

	; There is some overhead to resetting, because we have to save a copy of the
	; initial statics specification.  We don't pay for this by default and disable
	; the reset refinement, but if the user wants it then it is there

	if resettable [
		append objSpec compose/deep [
			FUNC-STATIC.reset: func [] [
				do [(statics)]
			]
		]
	]

	; We return a generated function which is actually going to be a member in
	; an object... the object where the static state is stored.

	staticsInfo: get-parameter-information statics

	append objSpec compose/deep [

		; The main funct is NOT a bound to the object that contains the statics
		; which we are declaring here.  It defaults to the caller's notion of
		; context, or the caller-specified "with" context.
		; so we must explicitly pass the statics as parameters

		FUNC-STATIC.main: (either with [[funct/with]] [[funct]]) [(spec) (staticsInfo/spec)] [
			(body)
		] (either with [[withObject]] [[]]) 

		; Unlike the main funct, the run function *IS* bound inside the object
		; we are declaring.  Thus it can read the statics long enough to proxy
		; them as parameters to the main, which runs in the context desired by
		; the caller at the point of definition.

 		FUNC-STATIC.run: funct/with [(spec) (either resettable [[/reset]] [[]])] [
			(either resettable [
				[if reset [FUNC-STATIC.reset]]
			] [[]])
			FUNCT-STATIC.mainArgs: copy [(staticsInfo/spec)]

			; This is a bit tricky.  If one declares a static member that is a
			; function assignment, you can't simply use the word you assigned
			; that function to as a parameter to main because it will try to
			; call the function.  Here's the temporary solution: turn any
			; words into get words, probably something better...

			FUNCT-STATIC.argIterator: FUNCT-STATIC.mainArgs
			while [not tail? FUNCT-STATIC.argIterator] [
				if word? first FUNCT-STATIC.argIterator [
					change FUNCT-STATIC.argIterator to-get-word first FUNCT-STATIC.argIterator
				]
				FUNCT-STATIC.argIterator: next FUNCT-STATIC.argIterator
			]

			insert FUNCT-STATIC.mainArgs [(collect-words spec)] 

			;print "Calling funct-static.main with arguments"
			;probe FUNCT-STATIC.mainArgs

			return do append to-block 'FUNC-STATIC.main FUNCT-STATIC.mainArgs
		] self
	]

	;print "Object specification for funct-static"
	;probe objSpec
	;print newline

	return select make object! objSpec 'FUNC-STATIC.run
]