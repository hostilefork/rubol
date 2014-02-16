Rebol [
	File: %cubes.reb

	Description: {
		This one taken from http://www.fincher.org/tips/Languages/Ruby/
		Section 21

			def cubes(max)
			   i=1
			   while i < max
			      yield i**3
			      i += 1
			   end
			end
			cubes(8) { |x| print x, ", "}   => 1, 8, 27, 64, 125, 216, 343,
			sum = 0
			cubes(8) { |y| sum += y}
			print "\nsum=",sum              => sum=784
			product = 1
			cubes(8) { |z| product *= z}
			print "\nproduct=",product      => product=128024064000
	}

	Notes: {
		When Rebol has been loaded with the "Rubol" translation layer, this
		program outputs the same thing as the Ruby version:

			1, 8, 27, 64, 125, 216, 343, 
			sum=784
			product=128024064000

		This is not how people would natively program in Rebol, but it is
		generally compatible!

		If this piques your interest you should learn how Rebol programmers
		would do it differently, and why...
	}
]

do %rubol.reb

def cubes [max] [
	i: 1
	while [i < max] [
		yield [to-integer (i ** 3)]
		i: i + 1
	]
]
cubes [8] [ [x] ruby-print [x ", "] ]
sum: 0
cubes [8] [ [y] sum: sum + y ]
ruby-print [newline "sum=" sum ]
product: 1
cubes [8] [ [z] product: product * z ]
ruby-print [newline "product=" product ]
