# Authors: Frank Douglas & Marcelo Dias
# Last modified: 10/04/2020

# REQUIREMENTS -----------------------------------
load    "lexical_analyzer.rb"
require "byebug"

# ------------------------------------------------

# PROBLEM SOLVING FUNCTIONS ----------------------

# ------------------------------------------------

# SAVING FUNCTIONS -------------------------------

# ------------------------------------------------

# URL FUNCTIONS ----------------------------------

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

	lex.analyse()

	# lex.print_token_array()
	# lex.print_symbol_table()
end

main()
# ------------------------------------------------