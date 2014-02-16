Rebol [
	Title: "Greeter Ported From Ruby Step #1"
	File: %greeter-1.reb

	Description: {
		This is a simple rote transformation of the code 
		for the Greeter in the Ruby quickstart tutorial into "Rubol"
		(e.g. something that has been brought in line with the required
		consistency that Rebol can parse, run, and reflect):

			http://www.ruby-lang.org/en/documentation/quickstart/2/

		Rebol is capable of more elegant expressions, which are shown as the 
		refinements in the files greeter-2.reb, greeter-3.reb, etc.
	}

	Usage: {
		Fire up a Rebol interpreter in the directory where these files
		are located.  Then at the command line, type:

			do %greeter-1.reb

		When it runs, you should get the output:

			Hi Pat!
			Bye Pat, come back soon.
	}
]

; Include the code that makes Rebol act more like Ruby
do %rubol.reb

class Greeter [
	def initialize [name: "World"] [
		.name: name
	]
	def say_hi [] [
		puts compose ["Hi " (.name) "!"]
	]
	def say_bye [] [
		puts compose ["Bye " (.name) ", come back soon."]
	]
]

g: Greeter/new ["Pat"]

g/say_hi []
g/say_bye []
