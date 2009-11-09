Rebol [
    Title: "Rubol"
    Purpose: "Extensions to Rebol to make it more Ruby-like"
    Description: { This was a thought experiment about how to ease a 
	developer who is familiar with Ruby into learning Rebol, and
	perhaps to help focus discussion on the essential differences
	between the languages.

	It employs some unusual hackery.  While such hackery is not a 
	great idea to use in practice, it helps in two ways:

	#1 - It shows Rebol doing some interesting-yet-cheap 
	acrobatics to let you redefine the language (in ways you
	simply could not do with other systems)

	#2 - It gives a boost in context so that Ruby programmers
	have a little bit less to absorb if they are going to try
	experimenting with Rebol

	!!!WARNING - This is so far a one-day hack that I'm just trying to
	put out for people to look at.  It might be a good tool
	and people might respond well to it.  At least it could
	focus certain conversations.!!!
    }

    Author: "Hostile Fork"
    Home: http://hostilefork.com
    License: mit

    File: %rubol.r
    Date: 9-Nov-2009
    Version: 0.1.0

    ; Header conventions: http://www.rebol.org/one-click-submission-help.r
    Type: function
    Level: intermediate
    
    Usage: { 
	See accompanying demo files.
    }

    History: [
        0.1.0 [9-Nov-2009 {Private deployment to Rebol community} "Fork"]
    ]
]

; I build on my experimental function with statics, but I'm sure others will have 
; better suggestions for how to implement this

do %func-static.r

class: func ['className blk [block!] "Object words and values." /local explicitMembers localAssignments implicitMembers accessor attribute attributeName defRule] [

	; Everywhere they say
	;	def x [spec] [body] 
	; what we really want to do is
	; 	func-default [spec] [body]
	
	; REVIEW: We could also look everywhere that they say
	;	def x [body]
	; followed by something that isn't a block and substitute with 
	;	x: does [body]
	; but I don't think that sets a very good educational precedent.  Better to
	; evangelize the idea of things being consistent in knowing their number of
	; arguments... more Rebol-y and less dialect-y.

	; Also everywhere they say
	;	attr_accessor .foo
	; we want to change this into
	;	foo: object [set: ... get: ...]
	; there's also a variant that will do this for several attributes
	; 	attr_accessor [.foo .bar .baz]

	; The parse dialect can handle this although I thought there was a more elegant
	; form of change.  It apparently isn't working...
	;
	; 	http://curecode.org/rebol3/ticket.rsp?id=1279&cursor=11
	;
	; Also the details of how to get it work in one pass are bogging me down so I will
	; leave that to someone else for now.

	defRule: [
		any [
			to [quote def] replaceStart: 
			skip [word!] replaceEnd: (
				replaceArg: first back replaceEnd 
				replaceEnd: change/part replaceStart compose [
					(to-set-word replaceArg) func-default 
				] replaceEnd
			) :replaceEnd
		] to end
	]

	attr_accessorRule: [
		any [
			to [quote attr_accessor] replaceStart: 
			skip [word! | block!] replaceEnd: (
				replaceArg: first back replaceEnd
				if word? replaceArg [
					replaceArg: to-block replaceArg
				]
				replaceWith: copy []
				foreach attributeRef replaceArg [
					append replaceWith compose/deep [
						(to-set-word next to-string attributeRef) object [
							set: func [value] [(to-set-word attributeRef) value]
							get: func [] [to-get-word (attributeRef)]
						]
					]
				]
				replaceEnd: change/part replaceStart replaceWith replaceEnd 
			) :replaceEnd
		] to end
	]

	use [replaceStart replaceEnd replaceArg replaceWith] [
		; REVIEW: throw if this does not succeed?
		; TODO: unify so it's one parse pass?
		parse blk defRule
		parse blk attr_accessorRule
	]

	; collect the set-words at the first level of the spec
	; these are the member functions and declared members

	explicitMembers: collect-words/set blk

	; get all the assignments that are at deeper levels
	; NOTE: this picks up defs too.  should check to make sure
	; they're not using dots?

	localAssignments: collect-words/deep/set/ignore blk explicitMembers

	; produce a list of implicit members that we saw
	; used in assignments whose names start with a period
	; We will explicitly add them to the object so that Rebol 
	; treats them as members.

	implicitMembers: copy []
	foreach w localAssignments [
		if (first to-string w) == #"." [
			append implicitMembers compose [
				(to-set-word w) none
			]
		]
	]

	; give the meta-class object a member "new" which is a function 
	; that will instantiate a Rebol object

	do reduce [to-set-word className object compose/deep [
		new: func [args [block!] /local newObject] [
			newObject: object [
				class: object [name: (to-string className)]
				(implicitMembers)
				(blk)
			]
			newObject/initialize args
			return newObject
		]
	]
	]
	none
]

; Ruby has an operation called puts that calls the to_s method on the passed in
; object explicitly.

puts: func [arg] [
	either object? arg [
		print arg/to_s
	] [
		print to-string arg
	]
]

; Note that when you put a colon on the end of a token, it's a "set-word"
; (e.g. an assignment).  But when you put a colon at the *beginning*
; of a word it becomes a "get-word".  This lets us differentiate
; between the desire to call the print function vs. fetching the
; function object itself.

; so you should read...
;
;     foo: :bar
;
; ...as "set the foo word to what the bar word is currently pointing to"

; Ruby uses nil, why not define it just to reduce speed bumps...?

nil: :none
nil?: :none?

; Ruby has a "join" method already, and although we could overwrite it with the Ruby
; notion of joining this seems better

rubol-join: func [iterable [series!] separator /local pos] [
	result: copy ""
	if not empty? iterable [
		pos: head iterable
		while [not tail? next pos] [
			append result to-string first pos
			append result separator
			pos: next pos
		]
		append result to-string first pos
	]
]
