# Authors: Frank Douglas & Marcelo Dias
# Last modified: 11/09/2020

require "byebug"

class SyntacticAnalyzer
	attr_accessor :current_state, :previous_state, :current_index, :syntactic_table, :errors

		@current_state
		@previous_state
		@current_index
		@syntactic_table
		@errors

		INITIAL_STATE = 's0'

		# FUNÇÕES PÚBLICAS ----------------------------
		# CONSTRUTOR ----------------------------------
		def initialize source_code_path
			@current_state      = INITIAL_STATE
			@previous_state     = 'nil'
			@current_index      = 0
			@errors             = []
		end

		# ---------------------------------------------
end