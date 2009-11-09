REBOL [
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

	!!!WARNING - This is a one-day hack that I'm just trying to
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

class: func [blk [block!] "Object words and values." /local explicitMembers localAssignments implicitMembers accessor attribute attributeName] [

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

	; look for patterns like 
	; 	[attr_accessor .names]
	; and replace with a definition for names as a member of the 
	; object which has get and set functions

	accessor: head blk
	while [found? accessor: find accessor 'attr_accessor] [
		attribute: take next accessor
		attributeName: next to-string attribute
		poke accessor 1 to-set-word attributeName
		accessor: insert next accessor compose/deep [
			object [
				set: func [value] [(to-set-word attribute) value]
				get: func [] [to-get-word (attribute)]
			]
		]
	]

	; give the meta-class object a member "new" which is a function 
	; that will instantiate a Rebol object

	return object compose/deep [
		new: func [args [block!] /local newObject] [
			newObject: object [
				(implicitMembers)
				(blk)
			]
			newObject/initialize args
			return newObject
		]
	]
]

; funny RUBOL-DEF. names here because we run a reduce on the arguments
; In general we'll have the same evaluative context as the caller
; but there will be these little extra words.  Trying to make
; sure they won't collide... maybe there's a better way

def: func [spec [block!] body [block!]] [

	return func-static [RUBOL-DEF.args [block!] /local RUBOL-DEF.reducedArgs] [RUBOL-DEF.initialized: false RUBOL-DEF.workhorse: none RUBOL-DEF.paramInfo: none] compose/deep [
		if not RUBOL-DEF.initialized [
			RUBOL-DEF.paramInfo: get-parameter-information [(spec)]
			RUBOL-DEF.workhorse: func RUBOL-DEF.paramInfo/spec [(body)]
			RUBOL-DEF.initialized: true
		]

		; evaluate the arguments in the caller's context

		RUBOL-DEF.reducedArgs: reduce RUBOL-DEF.args

		; If we reduced and didn't get enough args, add from the defaults

		if lesser? length? RUBOL-DEF.reducedArgs length? RUBOL-DEF.paramInfo/defaults [
			append RUBOL-DEF.reducedArgs compose skip tail RUBOL-DEF.paramInfo/defaults subtract length? RUBOL-DEF.reducedArgs length? RUBOL-DEF.paramInfo/defaults
		]

		return do append copy [RUBOL-DEF.workhorse] RUBOL-DEF.reducedArgs
	]
]



; Note that when you put a colon on the end of a token, it's a "set-word"
; (e.g. an assignment).  But when you put a colon at the *beginning*
; of a word it becomes a "get-word".  This lets us differentiate
; between the desire to call the print function vs. fetching the
; function object itself.

; ...so you should read this as "set the puts word to what the print word is 
; currently pointing to"

puts: :print

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
