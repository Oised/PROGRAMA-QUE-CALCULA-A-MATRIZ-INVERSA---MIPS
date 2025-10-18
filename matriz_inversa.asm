.data
msg1: .asciiz "\nDigite o tamanho da Matriz: "			# msg que pede o tamanho da matriz
msg2: .asciiz "\nDigite a Matriz, elemento por elemento:\n"	# msg que pede os elementos da matriz
msg3: .asciiz "\nMatriz inserida:"				# msg p/ imprimir matriz
msg4: .asciiz "\n\nMatriz inversa:"				# msg p/ imprimir matriz i

msg_fim: .asciiz "\n\nFIM DO PROGRAMA"
msg_erro: .asciiz "\n\nERRO: A matriz não tem inversa (determinante zero)!\n"
msg_erro_n: .asciiz "\nERRO: Tamanho da matriz deve ser maior que zero!\n"

um:   .float 1.0		# valores auxiliares
zero: .float 0.0

.text
.globl main

main:
	# imprime a msg1 (pede o tamanho da matriz):
	la $a0, msg1
	li $v0, 4
	syscall

	# Recebe n da matriz:
	li $v0,5
	syscall
	move $s6, $v0		# Guardando n da matriz em s6

	# Verifica se n é válido (n > 0)
	bgtz $s6, n_valido	# se n > 0, pula para n_valido
    
	# Se n é inválido: mostra erro e encerra
	la $a0, msg_erro_n
	li $v0, 4
	syscall
	li $v0, 10
	syscall

n_valido:

	# calcula o tamanho do vertor (n*n*4):
	mul $s7, $s6, $s6
	sll $s7, $s7, 2

	move $s0, $gp
	addi $s0, $s0, 5000	# início do vetor
	move $s1, $s0
	add $s1, $s1, $s7	# fim do vetor (n elementos da matriz * 4 bytes)

	# imprime msg2 (pede a matriz):
	la $a0, msg2	
	li $v0, 4
	syscall	

ler_vetor:
	li $v0, 6
	syscall			#ler float, resultado em f0

	s.s $f0, 0($s0)		# guarda float no vetor

	addi $s0, $s0, 4	# próximo índice
	bne $s0, $s1, ler_vetor

	sub $s0, $s0, $s7	# restaura ponteiro para o início

	# imprime matriz:
	la $a0, msg3
	li $v0, 4		# imprime a msg3
	syscall
	
loop_coluna:
	li $v0, 11		# código para imprimir o char "\n" (10)
	li $a0, 10
	syscall

	li $t0, 0		# t0 é o contador de elementos da linha

loop_linha:
	l.s $f12, 0($s0)	# carrega float para f12
	li $v0, 2		# imprime float
	syscall

	li $a0, 9		# tab
	li $v0, 11
	syscall

	addi $s0, $s0, 4

	addi $t0, $t0, 1
			
	blt $t0, $s6, loop_linha

	bne $s0, $s1, loop_coluna

	sub $s0, $s0, $s7	# restaura ponteiro para o início

	l.s $f2, um		# f2 = 1.0
	l.s $f4, zero		# f4 = 0.0

	move $s2, $s1		# início do vetor (matriz identidade)
	move $s3, $s2
	add $s3, $s3, $s7	# fim do vetor (n elementos da matriz * 4 bytes)

	li $t0, 0
cria_i:
	s.s $f2, 0($s2)		# escreve 1
	addi $s2, $s2, 4
	beq $s2, $s3, fim_i

	li $t0, 0		# contador de zeros
loop_zeros:
	s.s $f4, 0($s2)		# escreve 0
	addi $s2, $s2, 4
	addi $t0, $t0, 1
	beq  $t0, $s6, cria_i
	j loop_zeros
fim_i:
	sub $s2, $s3, $s7

	# Algoritmo Gauss-Jordan para calcular matriz inversa:
	li $t0, 0		# contador de pivôs (linha atual)
    
loop_pivo:
	# Calcula endereço do elemento pivô na diagonal:
	mul $t1, $t0, $s6
	add $t1, $t1, $t0
	sll $t1, $t1, 2
    
	add $t2, $s0, $t1
	l.s $f6, 0($t2)		# f6 = valor do pivô

	# Verifica se matriz é singular (pivô zero):
	l.s $f4, zero
	c.eq.s $f6, $f4
	bc1f calculo_normal	# se pivô não é zero, continua
    
	# Matriz singular - mostra erro e encerra:
	la $a0, msg_erro
	li $v0, 4
	syscall
	li $v0, 10
	syscall

calculo_normal:
	# Divide linha da matriz original pelo pivô:
	move $t4, $t0
	mul $t5, $t4, $s6
	sll $t5, $t5, 2
	add $t6, $s0, $t5
	li $t7, 0
    
div_linha_original:
	l.s $f10, 0($t6)
	div.s $f10, $f10, $f6
	s.s $f10, 0($t6)
    
	addi $t6, $t6, 4
	addi $t7, $t7, 1
	blt $t7, $s6, div_linha_original
    
	# Divide linha da matriz identidade pelo pivô:
	move $t4, $t0
	mul $t5, $t4, $s6
	sll $t5, $t5, 2
	add $t6, $s2, $t5
	li $t7, 0
    
div_linha_identidade:
	l.s $f10, 0($t6)
	div.s $f10, $f10, $f6
	s.s $f10, 0($t6)
    
	addi $t6, $t6, 4
	addi $t7, $t7, 1
	blt $t7, $s6, div_linha_identidade

	# Zera elementos acima e abaixo do pivô:
	li $t1, 0		# contador de linhas a zerar
    
loop_zerar:
	beq $t1, $t0, prox_linha	# pula a linha do pivô
    
	# Calcula elemento a ser zerado:
	mul $t2, $t1, $s6
	add $t2, $t2, $t0
	sll $t2, $t2, 2
    
	add $t3, $s0, $t2
	l.s $f12, 0($t3)	# f12 = elemento a zerar
    
	# Se elemento já é zero, pula linha:
	l.s $f4, zero
	c.eq.s $f12, $f4
	bc1t prox_linha
    
	# Calcula multiplicador para operação de linha:
	l.s $f14, zero
	sub.s $f14, $f14, $f12	# f14 = -elemento (pivô é 1)
    
	# Aplica operação em todas as colunas:
	li $t6, 0		# contador de colunas
    
loop_colunas:
	# Operação na matriz original:
	mul $t7, $t1, $s6
	add $t7, $t7, $t6
	sll $t7, $t7, 2
	add $t8, $s0, $t7
    
	mul $t9, $t0, $s6
	add $t9, $t9, $t6
	sll $t9, $t9, 2
	add $k0, $s0, $t9
    
	l.s $f16, 0($t8)
	l.s $f18, 0($k0)
    
	mul.s $f18, $f18, $f14
	add.s $f16, $f16, $f18
	s.s $f16, 0($t8)
    
	# Operação na matriz identidade:
	add $t8, $s2, $t7
	add $k0, $s2, $t9
    
	l.s $f16, 0($t8)
	l.s $f18, 0($k0)
    
	mul.s $f18, $f18, $f14
	add.s $f16, $f16, $f18
	s.s $f16, 0($t8)
    
	addi $t6, $t6, 1
	blt $t6, $s6, loop_colunas
    
prox_linha:
	addi $t1, $t1, 1
	blt $t1, $s6, loop_zerar
    
	addi $t0, $t0, 1
	blt $t0, $s6, loop_pivo

	# imprime matriz inversa:
	la $a0, msg4
	li $v0, 4		# imprime a msg4
	syscall
	
loop_coluna_i:
	li $v0, 11		# código para imprimir o char "\n" (10)
	li $a0, 10
	syscall

	li $t0, 0		# t0 é o contador de elementos da linha

loop_linha_i:
	l.s $f12, 0($s2)	# carrega float para f12
	li $v0, 2		# imprime float
	syscall

	li $a0, 9		# tab
	li $v0, 11
	syscall

	addi $s2, $s2, 4

	addi $t0, $t0, 1
			
	blt $t0, $s6, loop_linha_i

	bne $s2, $s3, loop_coluna_i

	sub $s2, $s2, $s7	# restaura ponteiro para o início

	# msg_fim, anuncia o fim do programa:
	la $a0, msg_fim
	li $v0, 4     		
	syscall

	li $v0, 10
	syscall