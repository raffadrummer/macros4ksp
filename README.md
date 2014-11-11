# Macros 4 KSP

This repository contains a simple *macro system* for
"[Kontakt](http://www.native-
instruments.com/en/products/komplete/samplers/kontakt-5/) Scripting Language"
scripts.

The purpose of a *macro system* is to make code cleaner and simpler by defining
sort of functions and shortcuts that help organize code and make it more
readable. This system is based on [GNU make utility](http://www.gnu.org/software/make/) and on the [GNU C pre-processor](https://gcc.gnu.org/onlinedocs/cpp/), part of the [GNU complier collection](https://gcc.gnu.org/).

Such a system is particularly useful in the case of the KSP language given its
limitations in terms of code modularization.

## A short introduction to C pre-processor macros

A pre-processor macro is a directive of the form

	#define MACRO definition

where `MACRO` is the *name* of the macro (and can be any valid C *identifier*)
and `definition` is the *replacement*; the idea is that the pre-processor will
replace every occurence of `NAME` with `definition`. This is useful, for
instance, to introduce named constants in the code; for example, one can use

	#define MAX_PITCH 127
	...
	declare %notes[ MAX_PITCH ]

to define an array having a position for every possible pitch.

More interestingly, macros can have *parameters* allowing to use them as a
sort of function. In this case, one can write, for instance

	#define FUNCT( PARAM ) definition

where every occurence of `PARAM` in the replacement will be substituted by the
value appearing within parenthesis where the macro is used. For example, one
can use

	#define PLAY( PITCH ) play_note( PITCH, 127, 0, 0 )
	...
	PLAY( 64 )
	PLAY( 66 )
	PLAY( 58 )

to play notes at the given pitch, maximum velocity, and for the total length
of the sample.

We observe that C macros can be split among multiple lines by appending a `\`
as the last character of the line, for instance to improve readability. For
instance, one would like to write

	#define MENU( CTRL, ENTRIES, DEFAULT ) \
		declare ui_menu CTRL \
		$_idx := 0 \
		while ( $_idx < num_elements( ENTRIES ) ) \
			add_menu_item( CTRL, ENTRIES[ $_idx ], $_idx ) \
			inc( $_idx ) \
		end while \
		set_control_par( get_ui_id( CTRL ), $CONTROL_PAR_VALUE, DEFAULT )

to define a menu interface element populated with entries from the given
array, for instance as in

	declare !grid_names[ 6 ]
	!grid_names[ 0 ] := "1/8"
	!grid_names[ 1 ] := "1/8 tr"
	!grid_names[ 2 ] := "1/16"
	!grid_names[ 3 ] := "1/16 tr"
	!grid_names[ 4 ] := "1/32"
	!grid_names[ 5 ] := "1/32 tr"

	MENU( $grid_selector, !grid_names, 2 )

to create a menu with various musical figures. Unfortunately, KSP does not
support multiple instruction per line, so we need a way to re-introduce line
breaks after macro substitution. A way to achieve this is to use a sequence of
special characters, such as for instance `@@@` and then use a regular
expression matcher tool (such as [Perl](http://www.perl.org/)) to map such sequence back to a newline, for instance with the following command

	  perl -0777 -p -e 's/@@@\s*/\n/msg;'

To facilitate the process of invoking the C pre-processor and then such
command, one can use a `Makefile`.

## Modularizing code in files

Another very useful capability of the C pre-processor is to glue together
multiple files using the `#include` directive. Given that KSP does not support
splitting a script in files, thie can be very useful to modularize and
organize large scripts.

Moreover, given that usually variables must be defined in the `on init`
*callback*, one can use conditional inclusion to split every file in two
parts: one to be included in the `on init` callback, and the rest to be added
out out it.

### A worked out example

Assume we want to build a sciprt that creates a button and a label that shows
the number of time such button has been hit.

We modularize the code in two files named:

- [ui_i.ksp](example/ui_i.ksp), containing the variables and callbacks
  used by   the "user interface" and the file;
- [model_i.ksp](example/model_i.ksp), containing the variable counting the
  number of hits and a function that updates it (and will be called by
  the button callback).

Then we use the [main.ksp](example/main.ksp) file to glue them together (in a
way that the initialization code goes into the `on init` callback, while the
rest of the code is appended at the end).

Finally, by calling

	make -f ../Makefile main.txt

we will invoce the toolchain that transoforms such three files in the
`main.txt` file corresponding to the final KSP script.
