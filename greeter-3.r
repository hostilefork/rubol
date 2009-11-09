Rebol [
	Title: "Greeter Ported From Ruby Step #3"
	Description: {Learning Rebol's compose is a very general way
	of doing a lot of tricks that are like Ruby's ability to embed
	expressions into strings.  But there are lots of shortcuts if
	you are in-the-know.

	There's an operation called "rejoin" in Rebol that is short for
	"reduce and join together".  Reduce is a way of invoking the
	evaluator in cases where it wouldn't be run by default.  For
	instance:

		>> x: 10

		>> probe [x]
		== [x]

		>> probe reduce [x]
		== [10]

	Whether you want to reduce or not depends on what you are doing.
	It's the classic use/mention distinction... sometimes you want to be
	talking *about* x and sometimes you want to actually get the value
	associated with "x".

	But to look at how "rejoin" makes our life easier, let's go back to 
	how we used to use compose to write our hello:
	
		puts compose ["Hi " (.name) "!"]

	With rejoin we can take for granted the fact that it produces a
	string, and we can avoid using the parentheses.  Because we know no
	call to a to-string is needed, we can use Rebol's native print
	function:

		print rejoin ["Hi " .name "!"]

	That's a little purer.  But Rebol has some other nice tricks up its sleeve.
	To name one that I think helps readability, there are english words
	defined for for the space, tab, lf, cr, and null characters.  So long 
	as you're doing a "reduce" with your "join" these words will be reduced 
	to those strings:

		print rejoin ["Hi" space .name "!"]

	This Step 3 transformation does that upgrade.
	}

    	File: %greeter-3.r
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

class Greeter [
	initialize: def [name: "World"] [
		.name: name
	]
	say_hi: does [
		print rejoin  ["Hi" space .name "!"]
	]
	say_bye: does [
		print rejoin ["Bye" space .name "," space "come back soon."]
	]
]

g: Greeter/new ["Pat"]

g/say_hi
g/say_bye
