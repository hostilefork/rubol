Rebol [
	Title: "Yield test"
    File: %yielder-1.reb

	Description: {
		This is a test of the yield feature, being added to Rubol. 
	}

	Usage: {
		As written, the program currently outputs:

		About to yield 10 integers!
		1
		2
		3
		4
		5
		6
		7
		8
		9
		10


		About to yield 5 integers!
		1
		2
		3
		4
		5


		employee : Milo Croton

		Note that Rebol defines "do" for running expressions, e.g. eval, so
		this uses ruby-do instead.  It would be possible to redefine do in
		Rubol but for the moment I'm avoiding that to make interoperability
		better.  But could we reverse this bias and make Rubol users able to
		use do in a Ruby sense and use rebol-do if they want Rebol's concept?
	}    
]

; Include the code that makes Rebol act more like Ruby
do %rubol.reb

class Yielder [
	def initialize [] [
	]
	def run_some_yields [num_yields] [
		puts compose ["About to yield " (num_yields) " integers!"]

		count: 0
		times num_yields ruby-do [
			count: count + 1
			yield [count]
		]
	]
	
	; This from sample at http://www.fincher.org/tips/Languages/Ruby/
	def employee_yield [empId] [
		; next 2 lines simulated from calling a database on the empId
		lastname: "Croton"
      		firstname: "Milo"

		yield [lastname firstname] ; multiple arguments sent to block
	]
]

y: Yielder/new []

; using the style where def comes first, but indicating it should be anonymous

y/run_some_yields [10] def anonymous [value] [
	print value
]
print newline

; make-def is a variation which does not take a name

y/run_some_yields [5] make-def [value] [
	print value
]
print newline

; Demonstration of support for Ruby's "block style" of function definition

y/employee_yield [4] [ [last first] puts compose ["employee : " (first) " " (last)] ]
