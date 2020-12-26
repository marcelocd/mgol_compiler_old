# REQUIREMENTS -----------------------------------
load "lexical_analyzer.rb"
load "syntactic_analyzer.rb"
# load "semantic_analyzer.rb"

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

	# lex.analyse

	syntactic_analyzer = SyntacticAnalyzer.new(lex: lex,
																						 errors: lex.errors)
	syntactic_analyzer.analyse

	syntactic_analyzer.print_errors

	# syntactic_analyzer.print_token_array

	# semantic_analyzer = SemanticAnalyzer.new(token_array: syntactic_analyzer.token_array,
	# 																				 semantic_rules: syntactic_analyzer.semantic_rules,
	# 																				 errors: syntactic_analyzer.errors)
	# semantic_analyzer.analyse
	# semantic.print_errors
end

main()
# ------------------------------------------------