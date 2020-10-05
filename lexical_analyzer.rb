require "byebug"

class LexicalAnalyzer
	attr_accessor :source_code, :current_state, :current_index, :current_character, :current_line, :current_line_index, :transition_table, :final_state_table, :symbol_table, :token_array, :take_token_table

		@source_code
		@current_state
		@current_index
		@buffer
		@current_line
		@current_line_index
		@transition_table
		@final_state_table
		@symbol_table
		@token_array
		@state_token_table

		def initialize source_code_path
			file = File.open(source_code_path)
			@source_code = file.read
			file.close

			@current_state      = 's0'
			@current_index      = 0
			@current_character  = @source_code[@current_index]
			@buffer             = ''
			@current_line       = 1
			@current_line_index = 0
			@transition_table   = get_transition_table()
			@final_state_table  = define_final_states()
			@symbol_table       = initialize_symbol_table()
			@token_array        = []
			@state_token_table  = initialize_state_token_table()
		end

		def to_s
			aux_string = "Current State: #{@current_state}"
			aux_string += "\nBuffer: '#{@buffer}'"
			aux_string += "\nCurrent Index: #{@current_index}"
			aux_string += "\nCurrent Character: '#{@source_code[@current_index]}'"
			aux_string += "\nCurrent Line: #{current_line}"
			aux_string += "\nCurrent Line Index: #{current_line_index}"
			aux_string += "\n"
		end

		def get_current_character
			return @current_character
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

		def process
			if(@current_character == "\n" && @current_state == 's0')
				@current_line      += 1
				@current_line_index = -1
			end

			key = define_current_key()

			next_state = @transition_table[@current_state][key]

			if(next_state == nil && !is_final_state(@current_state))
				STDERR.puts(get_error_message())

				exit(false)
			end

			if(next_state == nil && is_final_state(@current_state))
				if(@current_state == 's1' || @current_state == 's3')
					if(@current_character.match(/[a-df-zA-DF-Z]/))
						STDERR.puts(get_error_message())

						exit(false)
					end
				elsif(@current_state == 's6')
					if(@current_character.match(/[a-zA-Z]/))
						STDERR.puts(get_error_message())

						exit(false)
					end
				end

				token = get_token_from_state(@current_state)

				if(token != 'Comentário')
					@token_array << token

					puts "#{@buffer}: #{token}"
				end

				if(@current_state == 's9')
					if(@symbol_table[@buffer] == nil)
						@symbol_table[@buffer] = {'token' => token}
					end
				end
			end

			update_lex(next_state)
		end

		private

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

			return "ERROR (line #{@current_line}, column #{@current_line_index}): #{description}"
		end

		def initialize_state_token_table
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

		def get_token_from_state state
			if(@symbol_table[@buffer])
				return @symbol_table[@buffer]['token']
			end

			return @state_token_table[state]
		end

		def is_final_state state
			return @final_state_table[state]
		end

		def define_final_states
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

		def define_current_key
			key = @current_character

			if(@current_state == "s7")
				if(@current_character != "\"")
					key = "ANYTHING_ELSE"
				end
			elsif(@current_state == "s10")
				if(@current_character != "}")
					key = "ANYTHING_ELSE"
				end
			elsif((@current_state == "s1" || @current_state == "s3") && (@current_character == 'e' || @current_character == 'E'))
				key = "E"
			else
				if(@current_character.match(/[a-zA-Z]/))
					key = 'L'
				elsif(@current_character.match(/[0-9]/))
					key = 'D'
				elsif(@current_character == "\s" || @current_character == "\n" || @current_character == "\t")
					key = 'BLANK'
				elsif(@current_character == nil)
					key = "EOF"
				end
			end

			return key
		end

		def get_transition_table
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

		def update_lex next_state
			if(next_state == nil)
				if(is_final_state(@current_state))
					@current_state = 's0'
				else
					@current_state = 's26'

					return
				end
			else
				@current_state       = next_state
				@current_index      += 1
				@current_character   = @source_code[@current_index]
				@current_line_index += 1
			end

			if(@current_state == 's0')
				@buffer = ''
			else
				@buffer += @source_code[@current_index - 1]
			end
		end
end

