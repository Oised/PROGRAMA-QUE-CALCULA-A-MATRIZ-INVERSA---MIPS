.data
msg1: .asciiz "\nDigite o tamanho da Matriz: "			# msg que pede o tamanho da matriz
msg2: .asciiz "\nDigite a Matriz, elemento por elemento:\n"	# msg que pede os elementos da matriz
msg3: .asciiz "\nMatriz inserida:"				# msg p/ imprimir matriz
msg_fim: .asciiz "\n\n--- FIM DO PROGRAMA ---"			# msg p/ o fim do programa

.text
.globl main

main:
	# imprime a msg1 (pede o tamanho da matriz)
	la $a0, msg1
	li $v0, 4
	syscall

	# Recebe n da matriz
	li $v0,5
	syscall
	move $s6, $v0	# Guardando n da matriz em s6

	# calcula o tamanho do vertor (n*n*4)
	mul $s7, $s6, $s6
	sll $s7, $s7, 2

	move $s0, $gp
	addi $s0, $s0, 5000      # início do vetor
	move $s1, $s0
	add $s1, $s1, $s7        # fim do vetor (n elementos da matriz * 4 bytes)

	# imprime msg2 (pede a matriz)
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

	#imprime matriz

	#imprime a msg3
	la $a0, msg3
	li $v0, 4
	syscall
	
loop_coluna:
	li $v0, 11	# código para imprimir o char "\n" (10)
	li $a0, 10
	syscall

	li $t0, 0	# t0 é o contador de elementos da linha

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

	#inicio do vetor I
	move $s2, $s1		# início do vetor (matriz identidade)
	move $s3, $s2
	add $s3, $s3, $s7	# fim do vetor (n elementos da matriz * 4 bytes)
cria_i:
	

	# msg_fim, anuncia o fim do programa
	la $a0, msg_fim
	li $v0, 4     		
	syscall

	li $v0, 10
	syscall