# Authors: Frank Douglas & Marcelo Dias
# Last modified: 10/05/2020

# REQUIREMENTS -----------------------------------
load    "lexical_analyzer.rb"
require "byebug"

# ------------------------------------------------

# PATH FUNCTIONS ---------------------------------
def source_code_path
	ARGV[0]
end

# ------------------------------------------------

# PRINTING FUNCTIONS -----------------------------
def log message
	puts '-' * 99
	puts message
	puts '-' * 99
end

# ------------------------------------------------

# TEST -------------------------------------------
def main
	lex = LexicalAnalyzer.new(source_code_path)

	# lex.print_info()

	# for i in 1..50
	# 	lex.process_next_character()

	# 	lex.print_info()
	# end

	lex.analyse()

	lex.print_token_array()
	lex.print_symbol_table()
end

main()
# ------------------------------------------------