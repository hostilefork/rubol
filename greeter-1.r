Rebol [
	Title: "Greeter Ported From Ruby Step #1"
	Description: {This is a very basic transformation of the code for the "Greeter"
	in the Ruby samples into something that Rebol can successfully parse.  It's
	not Rebol programming in the traditional sense... it's using some definitions
	that allow the Rebol interpreter--at runtime--to execute something that
	differs only superficially in its structure.

	The files greeter-2.r, greeter-3.r, etc. demonstrate some more refinements
	that let you see how much cleaner even this simple example can get in Rebol.
	}
    	File: %greeter-1.r
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

Greeter: class [
	initialize: def [name: "World"] [
		.name: name
	]
	say_hi: def [] [
		puts to-string compose ["Hi " (.name) "!"]
	]
	say_bye: def [] [
		puts to-string compose ["Bye " (.name) ", come back soon."]
	]
]

g: Greeter/new ["Pat"]

g/say_hi []
g/say_bye []
