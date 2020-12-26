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
		@token_array   = args[:token_array]
		@target_code   = ''
		@errors        = args[:errors]
		# VARIÁVEIS DA TABELA
		@LD = {}
		@TIPO = {}
		@OPRD1 = {}
		@OPRD2 = {}
		@EXP_R = {}
		@ARG = {}
		@Tx = []
		@id = {}
		@num = {}
		@opr = {}
	end

	# ---------------------------------------------

	def analyse rule
		tmp = (lexeme = alfa, token = alfa, type, line, column)
		resultado do lexico



		# 5 ------------------------------------
		if rule == 'LV => varfim PT_V'
		# 6 ------------------------------------
		elsif rule == 'D => id TIPO PT_V'
			# id = validation.pop
			# TIPO = validation.pop
			# PT_V = validation.pop

			symbol_table_reference.ids[id['lexeme']]['type'] = TIPO['type']
			@id[:type] = @TIPO[:type]
			@target_code += "#{@TIPO[:lexeme]} #{@id[:lexeme]} ;"
		# 7 ------------------------------------
		elsif rule == 'TIPO => int'
			@TIPO[:type] = 'int'
		# 8 ------------------------------------
		elsif rule == 'TIPO => real'
			@TIPO[:type] = 'real'
		# 9 ------------------------------------
		elsif rule == 'TIPO => lit'
			@TIPO[:type] = 'lit'
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
				@errors << "Semantic Error: variable not declared."
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
				@errors << "Semantic Error: variable not declared."
			end
		# 17 -----------------------------------
		elsif rule == 'CMD => id rcb LD PT_V'
			if @id[:type]
				if @id[:type] == @LD[:type]
					@target_code += "#{@id[:lexeme]} #{@rcb[:type]} #{@LD[:lexeme]}"
				else
					@errors << "Semantic Error: different types for attribution."
				end
			else
				@errors << "Semantic Error: variable not declared."
			end
		# 18 -----------------------------------
		elsif rule == 'LD => OPRD opm OPRD'
			# opr1 = validation.pop
			# opm = validation.pop
			# opr2 = validation.pop

			if oprd_types_are_equivalent_and_not_lit
				
			else
			end
	end

	# FUNÇÕES DAS REGRAS --------------------------
	def rule5
		@target_code += "\n\n\n\n"
	end

	def rule6
		@id[:type] = @TIPO[:type]
		@target_code += "#{@TIPO[:lexeme]} #{@id[:lexeme]} ;"
	end

	def rule7
		@TIPO[:type] = 'int'
	end

	def rule8
		@TIPO[:type] = @real[:type]
	end

	def rule9
		@TIPO[:type] = @lit[:type]
	end

	def rule11
		if @id[:type]
			if @id[:type] == 'lit'
				@target_code += "scanf(\"\%s\", #{@id[:lexeme]})"
			elsif @id[:type] == 'int'
				@target_code += "scanf(\"\%d\", #{@id[:lexeme]})"
			elsif @id[:type] == 'real'
				@target_code += "scanf(\"\%lf\", #{@id[:lexeme]})"
			end
		else
			@errors << "Semantic Error: variable not declared."
		end
	end

	def rule12
		@target_code += "printf(\"#{@ARG[:lexeme]}\")"
	end

	def rule13
		@ARG = @lit
	end

	def rule14
		@ARG = @num
	end

	def rule15
		if @id[:type]
			@ARG = @id
		else
			@errors << "Semantic Error: variable not declared."
		end
	end

	def rule17
		if @id[:type]
			if @id[:type] == @LD[:type]
				@target_code += "#{@id[:lexeme]} #{@rcb[:type]} #{@LD[:lexeme]}"
			else
				@errors << "Semantic Error: different types for attribution."
			end
		else
			@errors << "Semantic Error: variable not declared."
		end

		@errors <<
	end

	def rule18
		if oprd_types_are_equivalent_and_not_lit
			@Tx << @Tx.count + 1
			@LD[:lexeme] = @Tx.last
			@target_code += "T#{@Tx.last} = #{@OPRD[:lexeme]} #{@opm[:type]} #{@OPRD[:lexeme]}"
		else
			@errors << "Semantic Error: operands with incompatible types."
		end
	end

	def rule19
		@LD = @OPRD1
	end

	def rule20
		if @id[:type]
			if @OPRD1.empty?
				@OPRD1 = @id
			else
				@OPRD2 = @id
			end
		else
		end
	end

	def rule21
		if @OPRD1.empty?
			@OPRD1 = @num
		else
			@OPRD2 = @num
		end
	end

	def rule23
		@target_code += "}"
	end

	def rule24
		@target_code += "if(#{@EXP_R[:lexeme]}){"
	end

	def rule25
		if oprd_types_are_equivalent
			@Tx << @Tx.count + 1
			@EXPR_R[:lexeme] = @Tx.last
			@target_code += "T#{@Tx.last.to_s} = #{@OPRD1[:lexeme]} #{@opr[:type]} #{@OPRD2[:lexeme]}"
		else
			@errors << "Semantic Error: operands with incompatible types."
		end
	end

	
	# FUNÇÕES DE AUXÍLIO --------------------------
	def oprd_types_are_equivalent_and_not_lit
		return false if @OPRD1[:type].nil?
		return false if @OPRD2[:type].nil?
		return false if @OPRD1[:type] == 'lit' || @OPRD2[:type] == 'lit'
		return false if @OPRD1[:type] != @OPRD2[:type]
		true
	end

	def oprd_types_are_equivalent
		return false if @OPRD1[:type].nil?
		return false if @OPRD2[:type].nil?
		return false if @OPRD1[:type] != @OPRD2[:type]
		true
	end

	# FUNÇÕES DE ERRO -----------------------------
	

	# ---------------------------------------------
	# ---------------------------------------------
end