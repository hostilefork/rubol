REBOL [
	Title: "Rebol Functions with Static Locals"
	Purpose: "Easy-to-use alternative to closure for static local variables"
	Description: {Rebol 3 introduced closures as a native feature of the
	language.  However, working with the 2-step process and returning functions
	from within a closure can be a bit overwhelming.

	This defines func-static, which is for people who just want a function to
	accumulate state of its own but not pollute the parent context.

	!!!WARNING: This is very experimental right now and I would like some
	people with more experience writing these sorts of things to give it
	a look.  It needs error handling and a lot of other things.  (Also there 
	should be variants for the different function types and not just func)!!!

	As a further feature to test out, it can automatically provide a reset 
	refinement for resetting the static locals to the expressions that
	were used to initialize them
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
	; This analyzes that and gives you back an object with two fields.  One is 
	; a spec (suitable for use in a function definition) and the other is a
	; list of defaults.  In this case the result would be:
	;
	; [
	;	spec: [a b [block!] c d]
	; 	defaults [none none (3 + 4) ("hello")]
	; ]

	result: copy/deep [spec: [] defaults: []]

	pos: head parameters
	while [not tail? pos] [
		either set-word? first pos [
			; If we encounter a set-word, build an expression out of the
			; list members up until the next set-word

			expression: to-paren []
			append result/spec to-word first pos
			while [(not tail? next pos) and (not set-word? second pos)] [
				append expression second pos
				pos: next pos
			]
			append/only result/defaults expression
		] [
			; For everything else, just pass it through to the parameters.
			; If we see an unadorned word value then also put "none" in the 
			; defaults list

			append result/spec first pos
			if word? first pos [
				append result/defaults none
			]

			; TODO think about refinements.  They are not really compatible with
			; positional ideas like this
		]
		pos: next pos
	]

	return result
]

func-static: func [spec [block!] statics [block!] body [block!] /resettable /local paramInfo resetPreface originalContext] [
	paramInfo: get-parameter-information statics

	if resettable [
		; bind a throwaway word in the caller's context so we can hang onto that context
		FUNC-STATIC.dummy: none
		originalContext: bind? 'FUNC-STATIC.dummy
		unset 'FUNC-STATIC.dummy
	]

	resetPreface: either resettable [
		compose/deep [
			if reset [
				FUNC-STATIC.staticsCopy: [(statics)]
				foreach elem FUNC-STATIC.staticsCopy [
					if word? elem [
						bind elem FUNC-STATIC.originalContext
					]
				]
				do FUNC-STATIC.staticsCopy
			]
		]
	] [
		[]
	]

	return do reduce compose/deep [
		; when we reduce this we'll get a closure that produces functions if invoked
		closure [(either resettable [[FUNC-STATIC.originalContext]] []) (paramInfo/spec)] [
			func [(spec) (either resettable [[/reset]] [])] [
				(resetPreface) 
				(body)
			]
		]

		; ...and then these arguments will be passed to invoke it...
		(either resettable [originalContext] [[]]) (paramInfo/defaults)

		; ...returning the function with static members that the user wants!
	]
]

; Defaultible function, need to document

func-default: func [spec [block!] body [block!]] [

	return func-static [FUNC-DEFAULT.args [block!] /local FUNC-DEFAULT.reducedArgs] [FUNC-DEFAULT.initialized: false FUNC-DEFAULT.workhorse: none FUNC-DEFAULT.paramInfo: none] compose/deep [
		if not FUNC-DEFAULT.initialized [
			FUNC-DEFAULT.paramInfo: get-parameter-information [(spec)]
			FUNC-DEFAULT.workhorse: func FUNC-DEFAULT.paramInfo/spec [(body)]
			FUNC-DEFAULT.initialized: true
		]

		; evaluate the arguments in the caller's context

		FUNC-DEFAULT.reducedArgs: reduce FUNC-DEFAULT.args

		; If we reduced and didn't get enough args, add from the defaults

		if lesser? length? FUNC-DEFAULT.reducedArgs length? FUNC-DEFAULT.paramInfo/defaults [
			append FUNC-DEFAULT.reducedArgs compose skip tail FUNC-DEFAULT.paramInfo/defaults subtract length? FUNC-DEFAULT.reducedArgs length? FUNC-DEFAULT.paramInfo/defaults
		]

		return do append copy [FUNC-DEFAULT.workhorse] FUNC-DEFAULT.reducedArgs
	]
]
