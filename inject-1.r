Rebol [

	Description: {Another sample taken from

http://www.fincher.org/tips/Languages/Ruby/

	Section 21

primes = [1,3,5,7,11,13];

#using "inject" to sum.  We pass in "0" as the initial value

sum = primes.inject(0){|cumulative,prime| cumulative+prime}
puts sum  # =>40

#we pass in no initial value, so inject uses the first element

product = primes.inject{|cumulative,prime| cumulative*prime}
puts product  # =>15015

#just for fun let's sum all the numbers from 1 to, oh, say a million

sum = (1..1000000).inject(0){|cumulative,n| cumulative+n}
puts sum   # =>500000500000

#you can do interesting things like build hashes

hash = primes.inject({}) { |s,e| s.merge( { e.to_s => e } ) }
p hash  # =>  {"11"=>11, "7"=>7, "13"=>13, "1"=>1, "3"=>3, "5"=>5}
}]




do %rubol.r

primes: [1 3 5 7 11 13]

; using "inject" to sum.  We pass in "0" as the initial value

sum: inject/initial primes [ [ cumulative prime ] cumulative + prime ] 0
puts sum

;we pass in no initial value, so inject uses the first element

product: inject primes [ [ cumulative prime ] cumulative * prime ]
puts product    

;just for fun let's sum all the numbers from 1 to, oh, say a million

sum: inject/initial ruby-in [1 .. 1000000] [ [cumulative n] cumulative + n ] 0
puts sum

;you can do interesting things like build hashes

hash: inject/initial primes [ [s e] append s reduce [(to-string e) e] ] (make map! [])
p hash  



comment [{

The Rebol program currently outputs:

	40
	15015
	500000500000
	make map! [
		"1" 1
		"3" 3
		"5" 5
		"7" 7
		"11" 11
		"13" 13
	]

}]
