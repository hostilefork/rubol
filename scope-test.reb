Rebol [
	Title: "Rubol Scope Test"

	Purpose: "Demonstrate Rubol's simulated Ruby Scoping"

	Description: {Rebol has a reputation for making all variables global.
	This is not really the case, rather it lets you build your own scoping
	in the interpreter.  This shows Rebol following Ruby's rules, basically.}

	Author: "Hostile Fork"
	Home: http://hostilefork.com/
	License: mit
	
	File: %scope-test.reb
	Date: 10-Nov-2009
	Version: 0.1.1
]

do %rubol.reb
do %checkpoint.reb

checkpoint A [x y z]

y: "global assign Y"
z: "global assign Z"

checkpoint B [x y z]

class ScopeTest [
	attr_accessor [.x .y]

	def initialize (nil) [
		.x: "member init .X"
		.y: "member init .Y"
	]

	def set_XYZ [y] [
		checkpoint E [.x .y .z]

		.x: "set_XYZ assign .X"
		.y: y
		.z: "set_XYZ assign .Z"

		; If you don't have some local scope, the existence of an
		; accessor on a member creates an implicit ScopeTest/x
		; It is protected and cannot be overwritten.

		; this would cause an exception
		; x: "set_XYZ assign X"

		; Having a named parameter makes it okay to
		; assign to it in this scope.  The assignment changes the
		; value of the parameter during this call, and leaves
		; the accessor alone

		y: "set_XYZ assign Y"

		; If no accessor is defined then there is no z member and
		; it is free to use as a local by default

		z: "set_XYZ assign Z"

		checkpoint F [.x .y .z]
	]
]

checkpoint C [(test/x/get) (test/y/get) (test/z/get)]
checkpoint D [x y z]

test: ScopeTest/new []

test/set_XYZ ["param to set_XYZ[y]"]

checkpoint G [x y z]
checkpoint H [(test/x/get) (test/y/get) (test/z/get)]

unset 'y
unset 'z
unset 'test

checkpoint I [x y z]
checkpoint J [.x .y .z]


comment [{

	This gives output consistent with the expectations of programmers familiar with
	the scoping concepts of other languages.

	A: [[x = unset!] [y = unset!] [z = unset!]]
	B: [[x = unset!] [y = "global assign Y"] [z = "global assign Z"]]
	C: [[(test/x/get) = *exception*] [(test/y/get) = *exception*] [(test/z/get) = *exception*]]
	D: [[x = unset!] [y = "global assign Y"] [z = "global assign Z"]]
	E: [[.x = "member init .X"] [.y = "member init .Y"] [.z = none]]
	F: [[.x = "set_XYZ assign .X"] [.y = "param to set_XYZ[y]"] [.z = "set_XYZ assign .Z"]]
	G: [[x = unset!] [y = "global assign Y"] [z = "global assign Z"]]
	H: [[(test/x/get) = "set_XYZ assign .X"] [(test/y/get) = "param to set_XYZ[y]"] [(test/z/get) = *exception*]]
	I: [[x = unset!] [y = unset!] [z = unset!]]
	J: [[.x = unset!] [.y = unset!] [.z = unset!]]

}]
