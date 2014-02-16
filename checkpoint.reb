Rebol [
	Title: "Checkpoint helper"
	Description: {
		A little helper to dump variables at 
		named locations.  It dumps the name of the location,
		a mold of the expression, and evaluates it.  For
		instance...

			x: 10
			checkpoint A 'x

		...will print...

			A: [x = 10]
		
		If you would like it to not print output but return a
		block containing this expression, pass in the /silent
		refinement.

		You can do a block of values as well, and then you don't
		need the lit-word.  It can also process expressions in
		parentheses.

			x: 10
			y: "Hello"
			checkpoint B [x y (x * 2)]

		That would give you:

			B: [[x = 10] [y = "Hello"] [(x * 2) = 20]]

		It's better than print statements when you are trying to 
		illustrate the changes of values over time, and it also
		lets you accumulate structured blocks of information which
		could be compared automatically in regression tests.
	}
]

checkpoint: function [
	{Checkpoint expressions, variables, and paths at a named location.}
	'location [word!]
	arg [word! path! block! paren!]
	/silent "Do not print, just assign"
] [
	checkpoint-core: func [
		variable [word! path! paren!]
	] [
		compose/deep [(variable) = (try/except [
			v: either paren? variable [
				reduce to-block variable
			] [
				either value? variable [
					get variable
				] [
					[unset!]
				]
			]
		] [[*exception*]])]
	]

	either block? arg [
		tempResult: copy []
		foreach a arg [
			append/only tempResult checkpoint-core a
		]
	] [
		tempResult: checkpoint-core arg
	]
	result: append/only to-block to-set-word location tempResult
	if not silent [
		print mold/only result
	]
	result
]
