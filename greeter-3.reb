Rebol [
	Title: "Greeter Ported From Ruby Step #3"
    File: %greeter-3.reb

	Description: {
		Rather than try and mimic Ruby's #{@variable}
		notation for embedding variables into strings, I went straight to
		using "compose".  Compose is a very powerful tool and it's good
		for you to know about it sooner rather than later.  However, it
		was actually a bit heavy-handed for this case.

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
		call of to-string is needed, we can use Rebol's native print
		function:

			print rejoin ["Hi " .name "!"]

		That's how most Rebol programmers would think about this kind of problem.
		You'll notice that this pattern is used a lot more than building long
		chains of concatenations using plus signs.
	}
]

; Include the code that makes Rebol act more like Ruby
do %rubol.reb

class Greeter [
	def initialize [name: "World"] [
		.name: name
	]
	def say_hi nil [
		print rejoin ["Hi " .name "!"]
	]
	def say_bye nil [
		print rejoin ["Bye " .name ", come back soon."]
	]
]

g: Greeter/new ["Pat"]

g/say_hi
g/say_bye
