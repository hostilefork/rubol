Rebol [
	Title: "Greeter Ported From Ruby Step #2"
	Description: {One thing that is grating about the first crack at
	the Greeter is the appearance of empty parameter lists.  In the
	original Ruby, def was flexible and sensed when there were
	parentheses and when there were not.

	I deliberately left out additional syntax tokens to make this
	distinction in Rubol (even though I could have) because the goal
	is to showcase how Rebol deals with these issues.  In the case
	of functions that take arguments, you simply have different
	words for defining them.

	So although there are generic tools for defining functions:
	
		sum: functor [a b] [a + b]
		say-hello: functor [] [print "Hello"]

	There's also special shorthand you can use:

		say-goodbye: does [print "Hello"]

	You also see that Rebol's preferred way of declaring variables,
	members, or assigning pretty much anything is to put the name first
	and then a colon.  As you see with what I was able to do in making "class"
	and "def" it's not the only way to get the job done when you're defining
	an abstraction.  It's just the *preferred* way.

	As you can see, this small change cleans up the extra braces on both
	the callsites and the method declarations.
	}

    	File: %greeter-2.r
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

class Greeter [
	def initialize [name: "World"] [
		.name: name
	]
	say_hi: does [
		puts compose ["Hi " (.name) "!"]
	]
	say_bye: does [
		puts compose ["Bye " (.name) ", come back soon."]
	]
]

g: Greeter/new ["Pat"]

g/say_hi
g/say_bye
