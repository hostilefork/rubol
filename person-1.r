Rebol [
	Title: "Person Ported From Juixe.com Tutorial"
	Description: {Very early test of multiple attr_accessor, to_s,
	and some starting work, adapted from the website:

		http://juixe.com/techknow/index.php/2007/01/22/ruby-class-tutorial/

	The original code didn't make it quite clear to me what the object
	lifetime was, so I'll have to look into that.
	}
	
]

; Include the code that makes Rebol act more like Ruby
do %rubol.r

class Person [
	attr_accessor [.fname .lname]
 
	def initialize [fname lname] [
		.fname: fname
		.lname: lname
	]
 
	def to_s [] [
		to-string compose [(.lname) ", " (.fname)]
	]
 
	; Not ready yet, just prototyping?  Where do we put the "self" tag on 
	; class methods as opposed to instance methods?  ObjectSpace/etc.
	comment [
		def find_by_name [fname] [
			found: nil
			foreach o (ObjectSpace Person) [
				if o/fname == fname [
					found: o
				]
			]
			found
		]
	]
]

matz: Person/new["Yukihiro" "Matsumoto"]

; class name is working
puts matz/class/name

; so is calling the to_s member
puts matz

; why did the demo seem unconcerned about the garbage collection of these?
Person/new["David" "Thomas"]
Person/new["David" "Black"]
Person/new["Bruce" "Tate"]

; NOTE: Need to implement ObjectSpace concept not yet worked out
comment [
	; Find matz!
	puts Person/find_by_fname["Yukihiro"]
]