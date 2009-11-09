Rebol [
	Title: "Greeter Ported From Ruby Step #1"
	Description: {This is one of the most basic rote transformations of the code 
	for the Greeter in the Ruby quickstart tutorial into "Rubol" (e.g. something
	that has been brought in line with the required consistency that Rebol can 
	parse, run, and reflect):

		http://www.ruby-lang.org/en/documentation/quickstart/2/

	Rebol is capable of more elegant expressions, which are shown as the 
	refinements in the files greeter-2.r, greeter-3.r, etc.
	}
	Usage: {Fire up a Rebol interpreter in the directory where these files
	are located.  Then at the command line, type:

		do %greeter-1.r

	When it runs, you should get the output:

		Hi Pat!
		Bye Pat, come back soon.
	}
    	File: %greeter-1.r
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

class Greeter [
	initialize: def [name: "World"] [
		.name: name
	]
	say_hi: def [] [
		puts compose ["Hi " (.name) "!"]
	]
	say_bye: def [] [
		puts compose ["Bye " (.name) ", come back soon."]
	]
]

g: Greeter/new ["Pat"]

g/say_hi []
g/say_bye []
