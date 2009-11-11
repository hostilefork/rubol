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

; funct-def implements a variant of funct where you can put expressions in the spec and 
; they will be handled as defaults.  This feature requires a departure from Rebol's policy
; of knowing the expected number of parameters in advance, and callers must pass in a block.

; if you want a caller to not require a block at the call site, you explicitly use none
; as the specDef

funct-def: func [specDef [block! none!] body [block!] /with withObject /local paramInfo functSpec] [

	if none? specDef [
		either with [
			return funct/with [] body withObject
		] [
			return funct [] body
		]
	]

	paramInfo: get-parameter-information specDef
	functSpec: compose/deep [funct-static [
			FUNCT-DEF.args [block!]
		] [
			FUNCT-DEF.defaults: [(paramInfo/defaults)]
			FUNCT-DEF.main: (either with [[funct/with]] [[funct]]) [(paramInfo/spec)] [(body)] (either with [[withObject]] [[]]) 
		] [
			; evaluate the arguments in the caller's context
			FUNCT-DEF.mainArgs: reduce FUNCT-DEF.args

			; If we reduced and didn't get enough args, add from the defaults
			if lesser? length? FUNCT-DEF.mainArgs length? FUNCT-DEF.defaults [
				append FUNCT-DEF.mainArgs compose skip tail FUNCT-DEF.defaults subtract length? FUNCT-DEF.mainArgs length? FUNCT-DEF.defaults
			]

			;print "Calling funct-def.main with arguments"
			;probe FUNCT-DEF.mainArgs

			return do append to-block 'FUNCT-DEF.main FUNCT-DEF.mainArgs 
		] 
	]

	;print "Function specification for funct-def translated into funct-static"
	;probe functSpec
	;print newline

	return do functSpec
]

class: func ['className blk [block!] "Object words and values." /local explicitMembers localAssignments implicitMembers accessor attribute attributeName defRule] [

	; Everywhere they say
	;	def x [spec] [body] 
	; what we really want to do is
	; 	funct-def/with [spec] [body] self
	; although if Rebol would implement "method" as a way of automatically capturing self, 
	; this could be reduced to:
	;	method-def [spec] [body]
	
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
	; leave that to someone else for now, this should all be possible more
	; elegantly.

	defRule: [
		any [
			to [quote def] replaceStart: 
			4 skip replaceEnd: (
				use [name spec body] [
					body: first back replaceEnd 
					spec: first back back replaceEnd
					name: first back back back replaceEnd
					replaceEnd: change/part replaceStart compose/deep/only [
						(to-set-word name) funct-def/with (spec) (body) self
					] replaceEnd
				]
			) :replaceEnd
		] to end
	]

	protectAccessors: copy []

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
					use [attributeWithoutDot] [
						attributeNameWithoutDot: next to-string attributeRef
						append protectAccessors 'protect
						append protectAccessors to-lit-word attributeNameWithoutDot
						append replaceWith compose/deep [
							(to-set-word attributeNameWithoutDot) object [
								set: func [value] [(to-set-word attributeRef) value]
								get: func [] [(attributeRef)]
							]
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
				(protectAccessors)
			]

			; probe newObject

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
