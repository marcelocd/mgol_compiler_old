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
		rule =  @semantic_rules[@current_index]

		# 5 ------------------------------------
		if rule == 'LV => varfim PT_V'
			@target_code += "\n\n\n\n"
		# 6 ------------------------------------
		elsif rule == 'D => id TIPO PT_V'
			@id[:type] = @TIPO[:type]
			@target_code += "#{@TIPO[:lexeme]} #{@id[:lexeme]} ;"
		# 7 ------------------------------------
		elsif rule == 'TIPO => int'
			@TIPO[:type] = @int[:type]
		# 8 ------------------------------------
		elsif rule == 'TIPO => real'
			@TIPO[:type] = @real[:type]
		# 9 ------------------------------------
		elsif rule == 'TIPO => lit'
			@TIPO[:type] = @lit[:type]
		# 11 -----------------------------------
		elsif rule == 'ES => leia id PT_V'
			if @id[:type]
				if @id[:type] == 'lit'
					@target_code += "scanf(\"\%s\", #{@id[:lexeme]})"
				elsif @id[:type] == 'int'
					@target_code += "scanf(\"\%d\", #{@id[:lexeme]})"
				elsif @id[:type] == 'real'
					@target_code += "scanf(\"\%lf\", #{@id[:lexeme]})"
				end
			else
				errors << "Semantic Error: variable not declared."
			end
		# 12 -----------------------------------
		elsif rule == 'ES => escreva ARG PT_V'
			@target_code += "printf(\"#{@ARG[:lexeme]}\")"
		# 13 -----------------------------------
		elsif rule == 'ARG => lit'
			@ARG = @lit
		# 14 -----------------------------------
		elsif rule == 'ARG => num'
			@ARG = @num
		# 15 -----------------------------------
		elsif rule == 'ARG => id'
			if @id[:type]
				@ARG = @id
			else
				errors << "Semantic Error: variable not declared."
			end
		# 17 -----------------------------------
		elsif rule == 'CMD => id rcb LD PT_V'
			if @id[:type]
				if @id[:type] == @LD[:type]
					@target_code += "#{@id[:lexeme]} #{@rcb[:type]} #{@LD[:lexeme]}"
				else
					errors << "Semantic Error: different types for attribution."
				end
			else
				errors << "Semantic Error: variable not declared."
			end
		# 11 -----------------------------------
		elsif rule == ''
		# 11 -----------------------------------
		elsif rule == ''
		# 11 -----------------------------------
		elsif rule == ''
		# 11 -----------------------------------
		elsif rule == ''
		# 11 -----------------------------------
		elsif rule == ''
		# 11 -----------------------------------
		elsif rule == ''
		# 11 -----------------------------------
		elsif rule == ''
		# 11 -----------------------------------
		end
			
	end

	# FUNÇÕES DE AUXÍLIO --------------------------
	

	# FUNÇÕES DE ERRO -----------------------------
	

	# ---------------------------------------------
	# ---------------------------------------------
end