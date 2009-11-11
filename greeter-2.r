Rebol [
	Title: "Greeter Ported From Ruby Step #2"
	Description: {One thing that Ruby programmers might find grating
	about the first crack at the Greeter conversion is the appearance 
	of empty parameter lists--both at the definition site of methods
	and at the call site.  Ruby allows you to omit those.

	Rebol has much more of a "one size fits all" attitude in parsing.
	This provides benefits similar to what you get by structuring
	information in a standard format like XML.  Though it's even
	more like JSON.  Which is appropriate, because it was one of
	the languages that inspired JSON's approach!  You can *reflect*
	the source code within the Rebol language, and that's really 
	powerful.

	On the other hand, Ruby has a diverse array of parser cues.  For
	instance:

		def initialize(name = "World")
			@name = name
		end
		def say_hi
			puts "Hi #{@name}!"
		end

	It's easy for Ruby to tell the difference between a method
	taking no parameters and one taking several.  there is a "def"/"end"
	bounding block for the method bodies and bounding parentheses for
	the parameters.

	You might think that Rebol should count how many blocks there 
	are after a def and make a decision on whether the block
	represents a call with no parameters:

		def initialize [name: "World"] [
			.name: name
		]
		def say_hi [
			puts compose ["Hi " (.name) "!"]
		]

	It would technically be possible for some enclosing context (such
	as "class") to detect this pattern and "under the hood" rewrite
	such situations.  But def itself, executing outside of any context,
	must have a fixed notion of its parameters.

	Since the goal of Rubol is to build a Ruby-like implementation
	which is compatible with Rebol concepts, I've avoided doing any
	such tricks.  But there's a compromise: you're able to specify
	nil as the parameters argument to indicate that you don't want
	to have to supply an empty list of arguments at the callsite.

	To me, the effect on callers is more important--as there is only
	one definition, but a potentially infinite number of callers.  So
	you'll see that issue cleaned up below.

	(Note: Though parentheses around this nil are not strictly necessary,
	you can use them if you feel it makes the code more readable.
	It's just serving the purpose of doing precedence and will be
	disposed by the evaluator.  I'll put them in this example but
	leave them off in future ones, because they're not really
	serving a practical purpose and might confuse people who don't
	realize that they really aren't the same as the brackets you
	use when you want a parameter list.)
	}

    	File: %greeter-2.r
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

class Greeter [
	def initialize [name: "World"] [
		.name: name
	]
	def say_hi (nil) [
		puts compose ["Hi " (.name) "!"]
	]
	def say_bye (nil) [
		puts compose ["Bye " (.name) ", come back soon."]
	]
]

g: Greeter/new ["Pat"]

g/say_hi
g/say_bye