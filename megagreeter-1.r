Rebol [
	Title: "MegaGreeter From Ruby Language Tutorial Step #1"
	File: %megagreeter-1.r

	Usage: {Fire up a Rebol interpreter in the directory where these files
        are located.  Then at the command line, type:

                do %megagreeter-1.r

        When it runs, you should get the output:

		Hello World!
		Goodbye World.  Come back soon!
		Hello Zeke!
		Goodbye Zeke.  Come back soon!
		Hello Albert!
		Hello Brenda!
		Hello Charles!
		Hello Dave!
		Hello Englebert!
		Goodbye Albert, Brenda, Charles, Dave, Englebert.  Come back soon!
		...
		...
	}
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

class MegaGreeter [
	attr_accessor .names

	; Create the object
	def initialize [names: "World"] [
		.names: names
	]

	; Say hi to everybody
	def say_hi [] [
		either nil? .names [
			puts "..."
		] [
			either block? .names [
				; .names is a list of some kind, iterate!
				foreach name .names [
					puts to-string compose ["Hello " (name) "!"]
				]
			] [
				puts to-string compose ["Hello " (.names) "!"]
			]
		]
	]

	; Say bye to everybody
	def say_bye [] [
		either nil? .names [
			puts "..."
		] [
    			either block? .names [
				; join the list elements with commas
				puts to-string compose ["Goodbye " (ruby-join .names ", ") ".  Come back soon!"]
			] [
      				puts to-string compose ["Goodbye " (.names) ".  Come back soon!"]
			]
		]
	]
]

mg: MegaGreeter/new []
mg/say_hi []
mg/say_bye []

; Change name to be "Zeke"
mg/names/set "Zeke"
mg/say_hi []
mg/say_bye []

; Change the name to an array of names
mg/names/set ["Albert" "Brenda" "Charles"
    "Dave" "Englebert"]
mg/say_hi []
mg/say_bye []

; Change to nil
mg/names/set nil
mg/say_hi []
mg/say_bye []