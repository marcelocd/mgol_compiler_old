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
	def initialize token_array
		@current_state   = INITIAL_STATE
		@previous_state  = 'nil'
		@token_array     = token_array << '$'
		@current_index   = 0
		@ip              = nil
		@grammar         = initialize_grammar()
		@syntactic_table = initialize_syntactic_table()
		@errors          = []
	end

	# ---------------------------------------------

	def analyse
		stack = ['s0']

		ip = @token_array[@current_index]

		int = 0

		loop do
			int += 1
			# puts '---------'
			# puts stack
			# puts '---------'

			a  = ip['token']
			s  = stack.last

			sl = action(s, a)

			if(sl != nil)
				if(sl.match(/s\d+/))
					stack.push(a)
					stack.push(sl)

					@current_index += 1

					ip = @token_array[@current_index]
				elsif(sl.match(/r\d+/))
					goto_number = sl.match(/\d+/)[0]

					alpha = @grammar[goto_number]['left']
					beta  = @grammar[goto_number]['right']

					beta_length = count_symbols(beta)

					for i in 1..(2 * beta_length)
						stack.pop
					end

					sl = stack.last

					if(goto(sl, alpha) == nil)
						byebug
						puts 'hello'
					end

					stack.push(alpha)
					stack.push("s#{goto(sl, alpha)}")

					puts "#{alpha} => #{beta}"
				elsif(action(s, a) == 'acc')
					return
				else	
					error()
				end
			else
				error()

				return
			end
		end
	end

	def initialize_grammar
		return {
			'1' => {
				'left'  => 'Pl',
				'right' => 'P'
			},
			'2' => {
				'left'  => 'P',
				'right' => 'inicio V A'
			},
			'3' => {
				'left'  => 'V',
				'right' => 'varinicio LV'
			},
			'4' => {
				'left'  => 'LV',
				'right' => 'D LV'
			},
			'5' => {
				'left'  => 'LV',
				'right' => 'varfim'
			},
			'6' => {
				'left'  => 'D',
				'right' => 'id TIPO'
			},
			'7' => {
				'left'  => 'TIPO',
				'right' => 'int'
			},
			'8' => {
				'left'  => 'TIPO',
				'right' => 'real'
			},
			'9' => {
				'left'  => 'TIPO',
				'right' => 'lit'
			},
			'10' => {
				'left'  => 'A',
				'right' => 'ES A'
			},
			'11' => {
				'left'  => 'ES',
				'right' => 'leia id PT_V'
			},
			'12' => {
				'left'  => 'ES',
				'right' => 'escreva ARG PT_V'
			},
			'13' => {
				'left'  => 'ARG',
				'right' => 'literal'
			},
			'14' => {
				'left'  => 'ARG',
				'right' => 'num'
			},
			'15' => {
				'left'  => 'ARG',
				'right' => 'id'
			},
			'16' => {
				'left'  => 'A',
				'right' => 'CMD A'
			},
			'17' => {
				'left'  => 'CMD',
				'right' => 'id rcb LD PT_V'
			},
			'18' => {
				'left'  => 'LD',
				'right' => 'OPRD opm OPRD'
			},
			'19' => {
				'left'  => 'LD',
				'right' => 'OPRD'
			},
			'20' => {
				'left'  => 'OPRD',
				'right' => 'id'
			},
			'21' => {
				'left'  => 'OPRD',
				'right' => 'num'
			},
			'22' => {
				'left'  => 'A',
				'right' => 'COND A'
			},
			'23' => {
				'left'  => 'COND',
				'right' => 'CABEÇALHO CORPO'
			},
			'24' => {
				'left'  => 'CABEÇALHO',
				'right' => 'se AB_P EXP_R FC_P entao'
			},
			'25' => {
				'left'  => 'EXP_R',
				'right' => 'OPRD opr OPRD'
			},
			'26' => {
				'left'  => 'CORPO',
				'right' => 'ES CORPO'
			},
			'27' => {
				'left'  => 'CORPO',
				'right' => 'CMD CORPO'
			},
			'28' => {
				'left'  => 'CORPO',
				'right' => 'COND CORPO'
			},
			'29' => {
				'left'  => 'CORPO',
				'right' => 'fimse'
			},
			'30' => {
				'left'  => 'A',
				'right' => 'fim'
			}
		}
	end

	def initialize_syntactic_table
		return {
			's0' => {
				'P' => '1',
				'inicio' => 's2'
			},
			's1' => {
				'$' => 'acc'
			},
			's2' => {
				'varinicio' => 's4',
				'V' => '3'
			},
			's3' => {
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
			's4' => {
				'varfim;' => 's17',
				'id' => 's18',
				'LV' => '15',
				'D' => '16'
			},
			's5' => {
				'$' => 'r1'
			},
			's6' => {
				'id' => 's12',
				'leia' => 's10',
				'ecreva' => 's11',
				'se' => 's14',
				'fim' => 's9',
				'A' => '19',
				'ES' => '6',
				'CMD' => '7',
				'COND' => '8',
				'CABEÇALHO' => '13'
			},
			's7' => {
				'id' => 's12',
				'leia' => 's10',
				'ecreva' => 's11',
				'se' => 's14',
				'fim' => 's9',
				'A' => '19',
				'ES' => '6',
				'CMD' => '7',
				'COND' => '8',
				'CABEÇALHO' => '13'
			},
			's8' => {
				'id' => 's12',
				'leia' => 's10',
				'ecreva' => 's11',
				'se' => 's14',
				'fim' => 's9',
				'A' => '19',
				'ES' => '6',
				'CMD' => '7',
				'COND' => '8',
				'CABEÇALHO' => '13'
			},
			's9' => {
				'$' => 'r29'
			},
			's10' => {
				'id' => 's22'
			},
			's11' => {
				'id' => 's26',
				'literal' => 's24',
				'num' => 's25',
				'ARG' => '23'
			},
			's12' => {
				'rcb' => 's27'
			},
			's13' => {
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
			's14' => {
				'AB_P' => 's33'
			},
			's15' => {
				'id' => 'r2',
				'leia' => 'r2',
				'escreva' => 'r2',
				'se' => 'r2',
				'fim' => 'r2'
			},
			's16' => {
				'varfim' => 's17',
				'id' => 's18',
				'LV' => '34',
				'D' => '16'
			},
			's17' => {
				'PT_V' => 's35'
			},
			's18' => {
				'int' => 's37',
				'real' => 's38',
				'lit' => 's39',
				'TIPO' => '36'
			},
			's19' => {
				'$' => 'r9'
			},
			's20' => {
				'$' => 'r15'
			},
			's21' => {
				'$' => 'r21'
			},
			's22' => {
				'PT_V' => 's40'
			},
			's23' => {
				'PT_V' => 's41'
			},
			's24' => {
				'PT_V' => 'r12'
			},
			's25' => {
				'PT_V' => 'r13'
			},
			's26' => {
				'PT_V' => 'r14'
			},
			's27' => {
				'id' => 's44',
				'num' => 's45',
				'LD' => '42',
				'OPRD' => '43'
			},
			's28' => {
				'id' => 'r22',
				'leia' => 'r22',
				'escreva' => 'r22',
				'se' => 'r22',
				'fimse' => 'r22',
				'fim' => 'r22'
			},
			's29' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fimse' => 's32',
				'A' => '29',
				'CMD' => '30',
				'COND' => '31',
				'CABEÇALHO' => '13',
				'CORPO' => '46'
			},
			's30' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fimse' => 's32',
				'A' => '29',
				'CMD' => '30',
				'COND' => '31',
				'CABEÇALHO' => '13',
				'CORPO' => '47'
			},
			's31' => {
				'id' => 's12',
				'leia' => 's10',
				'escreva' => 's11',
				'se' => 's14',
				'fimse' => 's32',
				'A' => '29',
				'CMD' => '30',
				'COND' => '31',
				'CABEÇALHO' => '13',
				'CORPO' => '48'
			},
			's32' => {
				'id' => 'r28',
				'leia' => 'r28',
				'escreva' => 'r28',
				'se' => 'r28',
				'fimse' => 'r28',
				'fim' => 'r28'
			},
			's33' => {
				'id' => 's44',
				'num' => 's45',
				'OPRD' => '50',
				'EXP_R' => '49'
			},
			's34' => {
				'id' => 'r3',
				'leia' => 'r3',
				'escreva' => 'r3',
				'se' => 'r3',
				'fim' => 'r3'
			},
			's35' => {
				'id' => 'r4',
				'leia' => 'r4',
				'escreva' => 'r4',
				'se' => 'r4',
				'fim' => 'r4'
			},
			's36' => {
				'PT_V' => 's51'
			},
			's37' => {
				'PT_V' => 'r6'
			},
			's38' => {
				'PT_V' => 'r7'
			},
			's39' => {
				'PT_V' => 'r8'
			},
			's40' => {
				'id' => 'r10',
				'leia' => 'r10',
				'escreva' => 'r10',
				'se' => 'r10',
				'fimse' => 'r10',
				'fim' => 'r10'
			},
			's41' => {
				'id' => 'r11',
				'leia' => 'r11',
				'escreva' => 'r11',
				'se' => 'r11',
				'fimse' => 'r11',
				'fim' => 'r11'
			},
			's42' => {
				'PT_V' => 's52'
			},
			's43' => {
				'PT_V' => 'r18',
				'opm' => 's53'
			},
			's44' => {
				'PT_V' => 'r19',
				'opm' => 'r19',
				'FC_P' => 'r19',
				'opr' => 'r19'
			},
			's45' => {
				'PT_V' => 'r20',
				'opm' => 'r20',
				'FC_P' => 'r20',
				'opr' => 'r20'
			},
			's46' => {
				'id' => 'r25',
				'leia' => 'r25',
				'escreva' => 'r25',
				'se' => 'r25',
				'fimse' => 'r25',
				'fim' => 'r25'
			},
			's47' => {
				'id' => 'r26',
				'leia' => 'r26',
				'escreva' => 'r26',
				'se' => 'r26',
				'fimse' => 'r26',
				'fim' => 'r26'
			},
			's48' => {
				'id' => 'r27',
				'leia' => 'r27',
				'escreva' => 'r27',
				'se' => 'r27',
				'fimse' => 'r27',
				'fim' => 'r27'
			},
			's49' => {
				'FC_P' => 's54'
			},
			's50' => {
				'opr' => 's55'
			},
			's51' => {
				'varfim' => 'r5',
				'id' => 'r5'
			},
			's52' => {
				'id' => 'r16',
				'leia' => 'r16',
				'escreva' => 'r16',
				'se' => 'r16',
				'fimse' => 'r16',
				'fim' => 'r16'
			},
			's53' => {
				'id' => 's44',
				'num' => 's45',
				'OPRD' => '56'
			},
			's54' => {
				'entao' => 's57'
			},
			's55' => {
				'id' => 's44',
				'num' => 's45',
				'OPRD' => '58'
			},
			's56' => {
				'PT_V' => 'r17'
			},
			's57' => {
				'id' => 'r23',
				'leia' => 'r23',
				'escreva' => 'r23',
				'se' => 'r23',
				'fim' => 'r23'
			},
			's58' => {
				'FC_P' => 'r24'
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
	def error
		puts 'ERRO!'
	end

	# ---------------------------------------------
	# ---------------------------------------------
end