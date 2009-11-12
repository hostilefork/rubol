Rebol [
	Title: "Yield test"
	Description: {This is a test of the yield feature, being added to Rubol. 
	}
	Usage: {As written, the program currently outputs:

		About to yield 10 integers!
		1
		2
		3
		4
		5
		6
		7
		8
		9
		10

	Note that Rebol defines "do" for running expressions, e.g. eval, so this
	uses ruby-do instead.  It would be possible to redefine do in Rubol but
	for the moment I'm avoiding that to make interoperability better.  But
	could we reverse this bias and make Rubol users able to use do in a Ruby
	sense and then use rebol-do if they want Rebol's concept?

	}
    	File: %yielder-1.r
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

class Yielder [
	def initialize [] [
	]
	def run_some_yields [num_yields] [
		puts compose ["About to yield " (num_yields) " integers!"]

		count: 0
		times num_yields ruby-do [
			count: count + 1
			yield [count]
		]
	]
]

g: Yielder/new []

g/run_some_yields [10] def [value] [
	print value
]