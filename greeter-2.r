Rebol [
	Title: "Greeter Ported From Ruby Step #2"
	Description: {Although the Rebol evaluator requires operations to 
	take a consistent number of arguments, you can work around this in
	a couple of ways.  One way is using refinements (if you want to
	have additional optional parameters).  Another is just to use
	different words!

	In this case, I'm using the latter to avoid the superfluous brackets 
	that were showing up in the case of "def" definitions that took no
	arguments.  Rebol has a keyword called "does" for exactly this case...
	it takes a function body only and assumes no arguments.
	}

    	File: %greeter-2.r
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

Greeter: class [
	initialize: def [name: "World"] [
		.name: name
	]
	say_hi: does [
		puts to-string compose ["Hi " (.name) "!"]
	]
	say_bye: does [
		puts to-string compose ["Bye " (.name) ", come back soon."]
	]
]

g: Greeter/new ["Pat"]

g/say_hi
g/say_bye
