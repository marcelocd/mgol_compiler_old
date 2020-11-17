# Authors: Frank Douglas & Marcelo Dias
# Last modified: 11/17/2020

require "byebug"

class SyntacticAnalyzer
	attr_accessor :current_index, :syntactic_table, :first_follow_table, :errors

	@current_index
	@syntactic_table
	@first_follow_table
	@errors

	INITIAL_STATE = '0'

	# FUNÇÕES PÚBLICAS ----------------------------
	# CONSTRUTOR ----------------------------------
	def initialize token_array, errors
		@token_array        = token_array << {'token' => '$'}
		@current_index      = 0
		@ip                 = nil
		@grammar            = initialize_grammar()
		@syntactic_table    = initialize_syntactic_table()
		@first_follow_table = initialize_first_follow_table()
		@errors             = errors
	end

	# ---------------------------------------------

	def analyse
		stack = [INITIAL_STATE]

		ip = @token_array[@current_index]

		loop do
			# puts '---------'
			# puts stack
			# puts '---------'

			s = stack.last
			
			a = ip['token']

			if(action(s, a) != nil)
				if(action(s, a).match(/s/))
					stack.push(a)
					
					sl = action(s, a).match(/\d+/)[0]
					
					stack.push(sl)
					
					@current_index += 1

					ip = @token_array[@current_index]
				elsif(action(s, a).match(/r/))
					goto_number = action(s, a).match(/\d+/)[0]
					
					alpha = @grammar[goto_number]['left']
					
					beta  = @grammar[goto_number]['right']
					
					beta_length = count_symbols(beta)
					
					for i in 1..(2 * beta_length)
						stack.pop
					end

					sl = stack.last

					stack.push(alpha)
					
					stack.push("#{goto(sl, alpha)}")
					
					puts "#{alpha} => #{beta}"
				elsif(action(s, a) == 'acc')
					break
				else
					treat_error()
				end
			else
				if(a == 'EOF')
					@current_index += 1

					ip = @token_array[@current_index]

					next
				end
				
				if(@token_array[@current_index] == nil)
					return 
				end

				treat_error()
			end
		end
	end

	def initialize_grammar
		return {
			'0' => {
				'left'  => 'Pl',
				'right' => 'P'
			},
			'1' => {
				'left'  => 'P',
				'right' => 'inicio V A'
			},
			'2' => {
				'left'  => 'V',
				'right' => 'varinicio LV'
			},
			'3' => {
				'left'  => 'LV',
				'right' => 'D LV'
			},
			'4' => {
				'left'  => 'LV',
				'right' => 'varfim PT_V'
			},
			'5' => {
				'left'  => 'D',
				'right' => 'id TIPO PT_V'
			},
			'6' => {
				'left'  => 'TIPO',
				'right' => 'int'
			},
			'7' => {
				'left'  => 'TIPO',
				'right' => 'real'
			},
			'8' => {
				'left'  => 'TIPO',
				'right' => 'lit'
			},
			'9' => {
				'left'  => 'A',
				'right' => 'ES A'
			},
			'10' => {
				'left'  => 'ES',
				'right' => 'leia id PT_V'
			},
			'11' => {
				'left'  => 'ES',
				'right' => 'escreva ARG PT_V'
			},
			'12' => {
				'left'  => 'ARG',
				'right' => 'lit'
			},
			'13' => {
				'left'  => 'ARG',
				'right' => 'num'
			},
			'14' => {
				'left'  => 'ARG',
				'right' => 'id'
			},
			'15' => {
				'left'  => 'A',
				'right' => 'CMD A'
			},
			'16' => {
				'left'  => 'CMD',
				'right' => 'id RCB LD PT_V'
			},
			'17' => {
				'left'  => 'LD',
				'right' => 'OPRD OPM OPRD'
			},
			'18' => {
				'left'  => 'LD',
				'right' => 'OPRD'
			},
			'19' => {
				'left'  => 'OPRD',
				'right' => 'id'
			},
			'20' => {
				'left'  => 'OPRD',
				'right' => 'num'
			},
			'21' => {
				'left'  => 'A',
				'right' => 'COND A'
			},
			'22' => {
				'left'  => 'COND',
				'right' => 'CABEÇALHO CORPO'
			},
			'23' => {
				'left'  => 'CABEÇALHO',
				'right' => 'se AB_P EXP_R FC_P entao'
			},
			'24' => {
				'left'  => 'EXP_R',
				'right' => 'OPRD OPR OPRD'
			},
			'25' => {
				'left'  => 'CORPO',
				'right' => 'ES CORPO'
			},
			'26' => {
				'left'  => 'CORPO',
				'right' => 'CMD CORPO'
			},
			'27' => {
				'left'  => 'CORPO',
				'right' => 'COND CORPO'
			},
			'28' => {
				'left'  => 'CORPO',
				'right' => 'fimse'
			},
			'29' => {
				'left'  => 'A',
				'right' => 'fim'
			}
		}
	end

	def initialize_syntactic_table
		return {
			'0' => {
				'inicio' => 's2',
				'P' => '1'
			},
			'1' => {
				'$' => 'acc'
			},
			'2' => {
				'varinicio' => 's4',
				'V' => '3'
			},
			'3' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fim' => 's9',
				'A' => '5',
				'ES' => '6',
				'CMD' => '7',
				'COND' => '8',
				'CABEÇALHO' => '13'
			},
			'4' => {
				'varfim;' => 's17',
				'id' => 's18',
				'LV' => '15',
				'D' => '16'
			},
			'5' => {
				'$' => 'r1'
			},
			'6' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fim' => 's9',
				'A' => '19',
				'ES' => '6',
				'CMD' => '7',
				'COND' => '8',
				'CABEÇALHO' => '13'
			},
			'7' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fim' => 's9',
				'A' => '20',
				'ES' => '6',
				'CMD' => '7',
				'COND' => '8',
				'CABEÇALHO' => '13'
			},
			'8' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fim' => 's9',
				'A' => '21',
				'ES' => '6',
				'CMD' => '7',
				'COND' => '8',
				'CABEÇALHO' => '13'
			},
			'9' => {
				'$' => 'r29'
			},
			'10' => {
				'id' => 's22'
			},
			'11' => {
				'id' => 's26',
				'lit' => 's24',
				'num' => 's25',
				'ARG' => '23'
			},
			'12' => {
				'RCB' => 's27'
			},
			'13' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fimse' => 's32',
				'ES' => '29',
				'CMD' => '30',
				'COND' => '31',
				'CABEÇALHO' => '13',
				'CORPO' => '28'
			},
			'14' => {
				'AB_P' => 's33'
			},
			'15' => {
				'id' => 'r2',
				'leia' => 'r2',
				'escreva' => 'r2',
				'se' => 'r2',
				'fim' => 'r2'
			},
			'16' => {
				'varfim' => 's17',
				'id' => 's18',
				'LV' => '34',
				'D' => '16'
			},
			'17' => {
				'PT_V' => 's35'
			},
			'18' => {
				'int' => 's37',
				'real' => 's38',
				'lit' => 's39',
				'TIPO' => '36'
			},
			'19' => {
				'$' => 'r9'
			},
			'20' => {
				'$' => 'r15'
			},
			'21' => {
				'$' => 'r21'
			},
			'22' => {
				'PT_V' => 's40'
			},
			'23' => {
				'PT_V' => 's41'
			},
			'24' => {
				'PT_V' => 'r12'
			},
			'25' => {
				'PT_V' => 'r13'
			},
			'26' => {
				'PT_V' => 'r14'
			},
			'27' => {
				'id' => 's44',
				'num' => 's45',
				'LD' => '42',
				'OPRD' => '43'
			},
			'28' => {
				'id' => 'r22',
				'leia' => 'r22',
				'escreva' => 'r22',
				'se' => 'r22',
				'fimse' => 'r22',
				'fim' => 'r22'
			},
			'29' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fimse' => 's32',
				'ES' => '29',
				'CMD' => '30',
				'COND' => '31',
				'CABEÇALHO' => '13',
				'CORPO' => '46'
			},
			'30' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fimse' => 's32',
				'ES' => '29',
				'CMD' => '30',
				'COND' => '31',
				'CABEÇALHO' => '13',
				'CORPO' => '47'
			},
			'31' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fimse' => 's32',
				'ES' => '29',
				'CMD' => '30',
				'COND' => '31',
				'CABEÇALHO' => '13',
				'CORPO' => '48'
			},
			'32' => {
				'id' => 'r28',
				'leia' => 'r28',
				'escreva' => 'r28',
				'se' => 'r28',
				'fimse' => 'r28',
				'fim' => 'r28'
			},
			'33' => {
				'id' => 's44',
				'num' => 's45',
				'OPRD' => '50',
				'EXP_R' => '49'
			},
			'34' => {
				'id' => 'r3',
				'leia' => 'r3',
				'escreva' => 'r3',
				'se' => 'r3',
				'fim' => 'r3'
			},
			'35' => {
				'id' => 'r4',
				'leia' => 'r4',
				'escreva' => 'r4',
				'se' => 'r4',
				'fim' => 'r4'
			},
			'36' => {
				'PT_V' => 's51'
			},
			'37' => {
				'PT_V' => 'r6'
			},
			'38' => {
				'PT_V' => 'r7'
			},
			'39' => {
				'PT_V' => 'r8'
			},
			'40' => {
				'id' => 'r10',
				'leia' => 'r10',
				'escreva' => 'r10',
				'se' => 'r10',
				'fimse' => 'r10',
				'fim' => 'r10'
			},
			'41' => {
				'id' => 'r11',
				'leia' => 'r11',
				'escreva' => 'r11',
				'se' => 'r11',
				'fimse' => 'r11',
				'fim' => 'r11'
			},
			'42' => {
				'PT_V' => 's52'
			},
			'43' => {
				'PT_V' => 'r18',
				'OPM' => 's53'
			},
			'44' => {
				'PT_V' => 'r19',
				'OPM' => 'r19',
				'FC_P' => 'r19',
				'OPR' => 'r19'
			},
			'45' => {
				'PT_V' => 'r20',
				'OPM' => 'r20',
				'FC_P' => 'r20',
				'OPR' => 'r20'
			},
			'46' => {
				'id' => 'r25',
				'leia' => 'r25',
				'escreva' => 'r25',
				'se' => 'r25',
				'fimse' => 'r25',
				'fim' => 'r25'
			},
			'47' => {
				'id' => 'r26',
				'leia' => 'r26',
				'escreva' => 'r26',
				'se' => 'r26',
				'fimse' => 'r26',
				'fim' => 'r26'
			},
			'48' => {
				'id' => 'r27',
				'leia' => 'r27',
				'escreva' => 'r27',
				'se' => 'r27',
				'fimse' => 'r27',
				'fim' => 'r27'
			},
			'49' => {
				'FC_P' => 's54'
			},
			'50' => {
				'OPR' => 's55'
			},
			'51' => {
				'varfim' => 'r5',
				'id' => 'r5'
			},
			'52' => {
				'id' => 'r16',
				'leia' => 'r16',
				'escreva' => 'r16',
				'se' => 'r16',
				'fimse' => 'r16',
				'fim' => 'r16'
			},
			'53' => {
				'id' => 's44',
				'num' => 's45',
				'OPRD' => '56'
			},
			'54' => {
				'entao' => 's57'
			},
			'55' => {
				'id' => 's44',
				'num' => 's45',
				'OPRD' => '58'
			},
			'56' => {
				'PT_V' => 'r17'
			},
			'57' => {
				'id' => 'r23',
				'leia' => 'r23',
				'escreva' => 'r23',
				'se' => 'r23',
				'fimse' => 'r23'
			},
			'58' => {
				'FC_P' => 'r24'
			}
		}
	end

	def initialize_first_follow_table
	  return {
			'Pl' => {
				'first' => ['inicio'],
				'follow' => ['$']
			},
			'P' => {
				'first' => ['inicio'],
				'follow' => ['$']
			},
			'V' => {
				'first' => ['varinicio'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se']
			},
			'LV' => {
				'first' => ['varfim', 'id'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se']
			},
			'D' => {
				'first' => ['id'],
				'follow' => ['varfim', 'id']
			},
			'TIPO' => {
				'first' => ['int', 'real', 'lit'],
				'follow' => ['PT_V']
			},
			'A' => {
				'first' => ['fim', 'leia', 'escreva', 'id', 'se'],
				'follow' => ['$']
			},
			'ES' => {
				'first' => ['leia', 'escreva'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se', 'fimse']
			},
			'ARG' => {
				'first' => ['lit', 'num', 'id'],
				'follow' => ['PT_V']
			},
			'CMD' => {
				'first' => ['id'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se', 'fimse']
			},
			'LD' => {
				'first' => ['id', 'num'],
				'follow' => ['PT_V']
			},
			'OPRD' => {
				'first' => ['id', 'num'],
				'follow' => ['OPM', 'PT_V', 'OPR', 'FC_P']
			},
			'COND' => {
				'first' => ['se'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se', 'fimse']
			},
			'CABEÇALHO' => {
				'first' => ['se'],
				'follow' => ['leia', 'escreva', 'id', 'fimse', 'se']
			},
			'EXP_R' => {
				'first' => ['id', 'num'],
				'follow' => ['FC_P']
			},
			'CORPO' => {
				'first' => ['leia', 'escreva', 'id', 'fimse', 'se'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se', 'fimse']
			}
		}
	end

	# FUNÇÕES DE AUXÍLIO --------------------------
	def action s, a
		return @syntactic_table[s][a]
	end

	def goto s, a
		return @syntactic_table[s][a]
	end

	def count_symbols string
		return string.strip.split(' ').count
	end

	# FUNÇÕES DE ERRO -----------------------------
	def treat_error
		if(@token_array[@current_index]['lexeme'] != '')
			error = "Syntactic Error (line #{@token_array[@current_index]['line']}, column #{@token_array[@current_index]['column']}): unexpected '#{@token_array[@current_index]['lexeme']}'."
			
			@errors << error
		end

		token_array_length = @token_array.count

		@current_index += 1

		# Procura o índice do próximo delimitador (PT_V)
		# faz com que o @current_index seja o índice que vem depois
		for i in @current_index..(token_array_length - 1)
			if @token_array[@current_index]['token'] == 'PT_V'
				@current_index += 1

				return
			end

			@current_index += 1
		end
	end

	def print_errors
		errors_length = @errors.length()

		if(errors_length > 0)
			for i in 0..(errors_length - 1)
				puts @errors[i]
			end
		end
	end

	# ---------------------------------------------
	# ---------------------------------------------
end