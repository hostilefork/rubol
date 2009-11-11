Rebol [
	Title: "Greeter Ported From Ruby Step #4"
	Description: {There are a lot of nice subtle decisions in Rebol.  For 
	instance, like most languages these days it has two ways to express 
	a string.  But instead of choosing 'single quoted strings' and 
	"double quoted strings", Rebol has "double quoted strings" and 
	{strings in braces}.

	It might seem minor, but in practice it's a huge benefit.  Notice that
	braces do not tend to happen when people are writing natural language...
	whereas single and double quotes happen all the time.

		theString: {"It's just a fact," said The Fork}

	But what about strings representing code, where there are braces *and*
	single and double quotes?  Well, there's an interesting side-effect of 
	using an asymmetrical character to delimit strings.  It's not a problem
	if you nest them evenly!

	
		cppCode: {if (true) {cout << "Yup, it's true!"}}

	Rebol handles that with no problem, and it's rare that you have to get
	creative with switching back and forth.  Braces work almost all the time
	and I suggest them as a good default choice for almost anything but
	an unpaired brace (e.g. "{" or "}" in isolation)

	There are escaping methods for the weird characters as in other languages.
	However, another really nice touch in Rebol is to have defined English
	words that are bound to the space, tab, lf, cr, and null characters.  So long 
	as you're doing a "reduce" with your "join" these words will be reduced 
	to those strings.

	Notice how it's a bit of a challenge for the eye to tell what's going on in
	this line from greeter-3.  It can be hard to see if " .name " is a string or
	between strings!

		print rejoin ["Bye " .name ", come back soon."]
	
	You can tidy that up quite prettily:

		print rejoin [{Bye} space .name {,} space {come back soon.}]

	Rebol has been hand-optimized to work with such constructions.  So being
	this clear helps avoid mistakes and also helps call out patterns that
	you can capture with code that *generates* such sequences!!!
	}

    	File: %greeter-4.r
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

class Greeter [
	def initialize [name: {World}] [
		.name: name
	]
	def say_hi nil [
		print rejoin [{Hi} space .name {!}]
	]
	def say_bye nil [
		print rejoin [{Bye} space .name {,} space {come back soon.}]
	]
]

g: Greeter/new ["Pat"]

g/say_hi
g/say_bye