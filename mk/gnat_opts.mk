# Set custom ADC file, ignore local one
CC_ADA_OPT += -gnatec=$(REP_DIR)/mk/componolit.adc
CC_ADA_OPT += -gnatA	 # Avoid processing gnat.adc, if present file will be ignored

# Assertions are not supported right now.
# We should eventually enable runtime checks.
#
#CC_ADA_OPT += -gnata     # Enable pragma Assert/Debug

CC_ADA_OPT += -gnatA     # Aliasing checks on subprogram parameters
CC_ADA_OPT += -gnatef    # Full source path in brief error messages
CC_ADA_OPT += -gnateV    # Validity checks on subprogram parameters
CC_ADA_OPT += -gnatE     # Dynamic elaboration checking mode enabled
CC_ADA_OPT += -gnatf     # Full errors. Verbose details, all undefined references
CC_ADA_OPT += -gnatU     # Enable unique tag for error messages
CC_ADA_OPT += -gnatv     # Verbose mode. Full error output with source lines to stdout

# Validity checks
CC_ADA_OPT += -gnatVa    # turn on all validity checking options

# Warnings
CC_ADA_OPT += -gnatwa    # turn on all info/warnings marked with + in gnatmake help
CC_ADA_OPT += -gnatwe    # treat all warnings (but not info) as errors
CC_ADA_OPT += -gnatwd    # turn on warnings for implicit dereference
CC_ADA_OPT += -gnatwh    # turn on warnings for hiding declarations
CC_ADA_OPT += -gnatwk    # turn on warnings for standard redefinition
CC_ADA_OPT += -gnatwt    # turn on warnings for tracking deleted code
CC_ADA_OPT += -gnatwu    # turn on warnings for unordered enumeration

CC_ADA_OPT += -gnatwX    # turn off warnings for non-local exception

# Style checks
CC_ADA_OPT += -gnaty4    # Check indentation (4 spaces)
CC_ADA_OPT += -gnatya    # check attribute casing
CC_ADA_OPT += -gnatyA    # check array attribute indexes
CC_ADA_OPT += -gnatyb    # check no blanks at end of lines
CC_ADA_OPT += -gnatyc    # check comment format (two spaces)
CC_ADA_OPT += -gnatyd    # check no DOS line terminators
CC_ADA_OPT += -gnatye    # check end/exit labels present
CC_ADA_OPT += -gnatyf    # check no form feeds/vertical tabs in source
CC_ADA_OPT += -gnatyh    # check no horizontal tabs in source
CC_ADA_OPT += -gnatyi    # check if-then layout
CC_ADA_OPT += -gnatyI    # check mode in
CC_ADA_OPT += -gnatyk    # check casing rules for keywords
CC_ADA_OPT += -gnatyl    # check reference manual layout
CC_ADA_OPT += -gnatyL5   # check max nest level < nn
CC_ADA_OPT += -gnatyM120 # check line length <= nn characters
CC_ADA_OPT += -gnatyn    # check casing of package Standard identifiers
CC_ADA_OPT += -gnatyO    # check overriding indicators
CC_ADA_OPT += -gnatyp    # check pragma casing
CC_ADA_OPT += -gnatyr    # check casing for identifier references
CC_ADA_OPT += -gnatys    # check separate subprogram specs present
CC_ADA_OPT += -gnatyS    # check separate lines after THEN or ELSE
CC_ADA_OPT += -gnatyt    # check token separation rules
CC_ADA_OPT += -gnatyu    # check no unnecessary blank lines
CC_ADA_OPT += -gnatyx    # check extra parentheses around conditionals
