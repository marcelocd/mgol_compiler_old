# Authors: Frank Douglas & Marcelo Dias
# Last modified: 12/13/2020

require "byebug"

class SemanticAnalyzer
	attr_accessor :current_index, :semantic_rules, :token_array,
								:target_code, :errors

	# FUNÇÕES PÚBLICAS ----------------------------
	# CONSTRUTOR ----------------------------------
	def initialize(args)
		@current_index = 0
		@semantic_rules = args[:semantic_rules]
		@token_array   = args[:token_array]
		@target_code   = ''
		@errors        = args[:errors]
	end

	# ---------------------------------------------

	def analyse
		byebug
		puts 'hello'
	end

	# FUNÇÕES DE AUXÍLIO --------------------------
	

	# FUNÇÕES DE ERRO -----------------------------
	

	# ---------------------------------------------
	# ---------------------------------------------
end