# Authors: Frank Douglas & Marcelo Dias
# Last modified: 10/05/2020

# require "byebug"

class LexicalAnalyzer
	attr_accessor :source_code, :current_state, :current_index, :current_character, :buffer, :current_line, :current_column, :transition_table, :final_states_table, :symbol_table, :take_token_table, :token_array

		@source_code
		@current_state
		@current_index
		@buffer
		@current_line
		@current_column
		@transition_table
		@final_states_table
		@symbol_table
		@token_array
		@state_token_table

		# FUNÇÕES PÚBLICAS ----------------------------
		# CONSTRUTOR ----------------------------------
		def initialize source_code_path
			file = File.open(source_code_path)
			@source_code = file.read
			file.close

			@current_state      = 's0'
			@current_index      = 0
			@current_character  = @source_code[@current_index]
			@buffer             = ''
			@current_line       = 1
			@current_column     = 1
			@transition_table   = initialize_transition_table()
			@final_states_table = initialize_final_states()
			@symbol_table       = initialize_symbol_table()
			@state_token_table  = initialize_state_token_table()
			@token_array        = []
		end

		# ---------------------------------------------
		# FUNÇÕES PRINCIPAIS --------------------------
		def process_next_character
			# Incrementador de linhas -------------------
			if(@current_character == "\n" && @current_state == 's0')
				@current_line   += 1
				@current_column  = 0
			end
			# -------------------------------------------

			key = define_current_key()

			next_state = @transition_table[@current_state][key]

			# Caso não tenha transição com o caracter processado
			# e o estado atual não seja final (erro)
			if(next_state == nil && !is_final_state(@current_state))
				STDERR.puts(get_error_message())

				exit(false)
			end
			# -------------------------------------------

			if(next_state == nil && is_final_state(@current_state))
				# Caso alguma letra diferente de 'e' e 'E' seja processada
				# a partir dos estados s1 e s3
				if(@current_state == 's1' || @current_state == 's3')
					if(@current_character.match(/[a-df-zA-DF-Z]/))
						STDERR.puts(get_error_message())

						exit(false)
					end
				# -----------------------------------------
				# Caso qualquer letra seja processada a partir
				# do estado s6 
				elsif(@current_state == 's6')
					if(@current_character.match(/[a-zA-Z]/))
						STDERR.puts(get_error_message())

						exit(false)
					end
				end
				# -----------------------------------------
				# Se os dois últimos casos mencionados acima não forem
				# satisfeitos, então significa que um token foi reconhecido,
				# pois estamos dentro do if onde não tem transição com o
				# caracter atual, e o estado atual é final.
				# -----------------------------------------

				token = get_token_from_state(@current_state)

				# Garante que os comentários não sejam
				# adicionados ao array de tokens.
				if(token != 'Comentário')
					@token_array << token

					# puts "#{@buffer}: #{token}"
				end
				# -----------------------------------------

				# Adiciona os identificadores à tabela de símbolos.
				if(@current_state == 's9')
					if(@symbol_table[@buffer] == nil)
						@symbol_table[@buffer] = {'token' => token}
					end
				end
				# -----------------------------------------
			end

			update_lex(next_state)
		end

		def analyse
			# print_info()

			loop do
				process_next_character()
				# print_info()

				# s12: EOF
				if(@current_state == 's12')
					break
				end
			end
		end
		# ---------------------------------------------
		# FUNÇÕES DE IMPRESSÃO ------------------------
		def to_s
			aux_string = "Current State: #{@current_state}"
			aux_string += "\nBuffer: '#{@buffer}'"
			aux_string += "\nCurrent Index: #{@current_index}"
			aux_string += "\nCurrent Character: '#{@source_code[@current_index]}'"
			aux_string += "\nCurrent Line: #{current_line}"
			aux_string += "\nCurrent Column: #{current_column}"
			aux_string += "\n"
		end

		def print_info
			puts '-' * 99
			puts self.to_s
			puts '-' * 99
		end

		def print_token_array
			puts 'Token Array'
			puts @token_array
		end

		def print_symbol_table
			puts 'Symbol Table'
			@symbol_table.each do |key, value|
			  value.each do |k,v|
			    puts "Lexeme: #{key}, Token: #{v}"
			  end
			end
		end

		# ---------------------------------------------
		# GETTERS -------------------------------------
		def get_current_state
			return @current_state
		end

		def get_current_index
			return @current_index
		end

		def get_current_character
			return @current_character
		end

		def get_buffer
			return @buffer
		end

		def get_current_line
			return @current_line
		end

		def get_current_column
			return @current_column
		end

		def get_transition_table
			return @transition_table
		end

		def get_transition_table
			return @transition_table
		end

		def get_final_states_table
			return @final_states_table
		end

		def get_symbol_table
			return @symbol_table
		end

		def get_state_token_table
			return @transition_table
		end

		def get_token_array
			return @token_array
		end

		# ---------------------------------------------
		# ---------------------------------------------
		# FUNÇÕES PRIVADAS ----------------------------
		private

		# FUNÇÕES DE AUXÍLIO --------------------------
		def define_current_key
			if(@current_character == nil)
				return "EOF"
			end

			# Caso nenhuma das condições abaixo sejam verdadeiras
			# o próprio caracter será a chave da tabela de transição
			key = @current_character

			# Caso qualquer caracter diferente de " seja
			# lido ao processar uma Constante Literal
			if(@current_state == "s7")
				if(@current_character != "\"")
					return "ANYTHING_ELSE"
				end
			# ------------------------------------------
			# Caso qualquer caracter diferente de } seja
			# lido ao processar um Comentário
			elsif(@current_state == "s10")
				if(@current_character != "}")
					return "ANYTHING_ELSE"
				end
			# ------------------------------------------
			# Caso os caracteres e ou E sejam processados
			# no meio de um numeral
			elsif((@current_state == "s1" || @current_state == "s3") && (@current_character == 'e' || @current_character == 'E'))
				return "E"
			# ------------------------------------------
			else
				if(@current_character.match(/[a-zA-Z]/))
					key = 'L'
				elsif(@current_character.match(/[0-9]/))
					key = 'D'
				elsif(@current_character == "\s" || @current_character == "\n" || @current_character == "\t")
					key = 'BLANK'
				end
			end

			return key
		end

		def get_token_from_state state
			# Caso o conteúdo do buffer seja um id
			# que já existe na tabela de símbolos,
			# o token retornado é o que consta na tabela.
			if(@symbol_table[@buffer])
				return @symbol_table[@buffer]['token']
			end

			# Caso contrário, o próprio estado do
			# DFA determina o token reconhecido
			return @state_token_table[state]
		end

		def is_final_state state
			return @final_states_table[state]
		end

		def update_lex next_state
			# Esta função atualiza o estado do DFA,
			# e das demais informações, como linha,
			# coluna, buffer, caracter atual...

			if(next_state == nil)
				if(is_final_state(@current_state))
					@current_state = 's0'
				else
					@current_state = 's26'

					return
				end
			else
				@current_state      = next_state
				@current_index     += 1
				@current_character  = @source_code[@current_index]
				@current_column    += 1
			end

			if(@current_state == 's0')
				@buffer = ''
			else
				if(@source_code[@current_index - 1] != nil)
					@buffer += @source_code[@current_index - 1]
				end
			end
		end

		# ---------------------------------------------
		# FUNÇÕES DE INICIALIZAÇÃO --------------------
		def initialize_final_states
			return {
				"s0" => false,
				"s1" => true,
				"s2" => false,
				"s3" => true,
				"s4" => false,
				"s5" => false,
				"s6" => true,
				"s7" => false,
				"s8" => true,
				"s9" => true,
				"s10" => false,
				"s11" => true,
				"s12" => true,
				"s13" => true,
				"s14" => true,
				"s15" => true,
				"s16" => true,
				"s17" => true,
				"s18" => true,
				"s19" => true,
				"s20" => true,
				"s21" => true,
				"s22" => true,
				"s23" => true,
				"s24" => true,
				"s25" => true,
				"s26" => false,
				"s27" => true,
			}
		end

		def initialize_state_token_table
			# A tabela retornada por essa função indica
			# qual token é reconhecido por cada estado final

			return {
				's1' => 'Num',
				's3' => 'Num',
				's6' => 'Num',
				's8' => 'Literal',
				's9' => 'id',
				's11' => 'Comentário',
				's12' => 'EOF',
				's13' => 'OPR',
				's14' => 'OPR',
				's15' => 'OPR',
				's16' => 'OPR',
				's17' => 'OPR',
				's18' => 'OPR',
				's19' => 'OPM',
				's20' => 'OPM',
				's21' => 'OPM',
				's22' => 'OPM',
				's23' => 'AB_P',
				's24' => 'FC_P',
				's25' => 'PT_V',
				's27' => 'RCB',
			}
		end

		def initialize_symbol_table
			return {
				'inicio'    => {'token' => 'inicio'},
				'varinicio' => {'token' => 'varinicio'},
				'varfim'    => {'token' => 'varfim'},
				'int'       => {'token' => 'int'},
				'real'      => {'token' => 'real'},
				'lit'       => {'token' => 'lit'},
				'leia'      => {'token' => 'leia'},
				'escreva'   => {'token' => 'escreva'},
				'se'        => {'token' => 'se'},
				'entao'     => {'token' => 'entao'},
				'fimse'     => {'token' => 'fimse'},
				'fim'       => {'token' => 'fim'}
			}
		end

		def initialize_transition_table
			return {
				"s0" => {
					"D"     => "s1",
					"\""    => "s7",
					"L"     => "s9",
					"{"     => "s10",
					"EOF"   => "s12",
					">"     => "s13",
					"="     => "s15",
					"<"     => "s16",
					"+"     => "s19",
					"-"     => "s20",
					"*"     => "s21",
					"/"     => "s22",
					"("     => "s23",
					")"     => "s24",
					";"     => "s25",
					"BLANK" => "s0"
				},
				"s1" => {
					"D" => "s1",
					"E" => "s4",
					"." => "s2"
				},
				"s2" => {"D" => "s3"},
				"s3" => {
					"D" => "s3",
					"E" => "s4"
				},
				"s4" => {
					"+" => "s5",
					"-" => "s5",
					"D" => "s6"
				},
				"s5" => {"D" => "s6"},
				"s6" => {"D" => "s6"},
				"s7" => {
					"\"" => "s8",
					"ANYTHING_ELSE" => "s7"
				},
				"s8" => {},
				"s9" => {
					"D" => "s9",
					"L" => "s9",
					"_" => "s9"
				},
				"s10" => {
					"}"  => "s11",
					"ANYTHING_ELSE" => "s10"
				},
				"s11" => {},
				"s13" => {"=" => "s14"},
				"s14" => {},
				"s15" => {},
				"s16" => {
					">" => "s17",
					"-" => "s27",
					"=" => "s18"
				},
				"s17" => {},
				"s18" => {},
				"s19" => {},
				"s20" => {},
				"s21" => {},
				"s22" => {},
				"s23" => {},
				"s24" => {},
				"s25" => {},
				"s26" => {},
				"s27" => {}
			}
		end

		# ---------------------------------------------
		# FUNÇÕES DE ERRO -----------------------------
		def get_error_message
			description = ''

			if(@current_state == 's0')
				description = "unexpected '#{current_character}' starting the lexeme."
			elsif(@current_state == 's2' or @current_state == 's5')
				description = "unexpected '#{current_character}'' instead of digit."
			elsif(@current_state == 's1' || @current_state == 's3')
				description = "'#{@current_character}' is not valid for a numeral."
			elsif(@current_state == 's4')
				description = "unexpected '#{current_character}'' instead of digit or sign (+,-)."
			end

			return "ERROR (line #{@current_line}, column #{@current_column}): #{description}"
		end

		# ---------------------------------------------
		# ---------------------------------------------
end

