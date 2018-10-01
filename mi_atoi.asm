
    .data

mi_string:      .asciiz  "-2147483648"
    .text
    # mi_atoi(char* str);

main:
    la		$a0, mi_string
    jal		mi_atoi				# jump to mi_atoi and save position to $ra
    move 	$a0, $v0		# $a0 = $v0
    li      $v0, 1
    syscall
    li      $v0,10
    syscall


mi_atoi:
    li      $t5, 10     # $t5 = 10
    li      $t6, 45   # $t6 = '-'
    li      $t7, 43     # $t7 = '+'
    li      $t8, 10 # $t8 = '\n'
    li      $v0, 0      # result = 0
    li		$t1, 0		# $t1 = i = 0
    add		$t2, $t1, $a0		# $t2 = str = &str[0]
    lb		$t3, 0($t2)		# $t3 = str[0]
    beq		$t3, $t6, case_menos 	# if str[0] == '-' signo_menos then case_menos
    beq		$t3, $t6, case_mas	# if str[0] == '+' then case_mas
    li		$t4, 1		# $t4 = 1, $t4 representa el signo del numero (1 por default)
    b       loop    #branch always al loop
case_menos:
    li		$t4,-1 		# $t4 = -1
    b       inc_i       # branch to inc_i
case_mas:
    li      $t4,1       # $t4 = 1 (igual ya estaba en 1)
    b		inc_i			# branch to inc_i
    
loop:
    add     $t2,$t1,$a0 # $t2 = &str[i]
    lb      $t3,0($t2)     # $t3 = str[i]
    beq     $t3, 0, fin   # if str[i] = '\0' then fin
    beq		$t3, $t8, fin	# if str[i] == '\n' then fin
    mulo	$v0, $v0, $t5			# result*=10    
    addiu   $t3, $t3, -48
    beq     $t4, -1, negativo   # si $t4 == -1 then caso negativo
    add     $v0, $v0, $t3       #result+=str[i]-48
    b       inc_i
negativo:
    sub     $v0, $v0, $t3       #result-=str[i]-48
inc_i:
    addi	$t1, $t1, 1			# $t1 = $t1 + 1
    b		loop			# branch to loop
fin:
    j       $ra
