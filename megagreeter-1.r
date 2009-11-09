Rebol [
	Title: "MegaGreeter From Ruby Language Tutorial Step #1"
	File: %megagreeter-1.r
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

MegaGreeter: class [
	attr_accessor .names

	; Create the object
	initialize: def [names: "World"] [
		.names: names
	]

	; Say hi to everybody
	say_hi: def [] [
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
	say_bye: def [] [
		either nil? .names [
			puts "..."
		] [
    			either block? .names [
				; join the list elements with commas
				puts to-string compose ["Goodbye " (rubol-join .names ", ") ".  Come back soon!"]
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
