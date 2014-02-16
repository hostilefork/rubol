Right now, "Rubol" is a small experiment to hybridize the Rebol and Ruby languages.  It leverages Rebol's unique adaptability to implement Ruby-like constructs at runtime.  The main goal is to strip away the surface differences of the languages, to sharpen the focus on the truly interesting ideas that Rebol brings to the table.

Admittedly it's a rather unusual way to use (abuse?) the interpreter.  You'd get better performance without going through an emulation of another language !  But it's interesting that this is even *possible*.  Most languages can't reshape themselves significantly, and Rebol does it with no external preprocessors or other crutches.

I kicked this project off after looking at the 20-minute Ruby tutorial:

http://www.ruby-lang.org/en/documentation/quickstart/

There are some other tutorials I'd like to use as a guide for first things to implement, so this will probably be next:

http://juixe.com/techknow/index.php/2007/01/22/ruby-class-tutorial/

It would obviously take a tremendous amount of time to feature-match Ruby.  So this is just a goal to develop a small subset to be used as a teaching tool.  
