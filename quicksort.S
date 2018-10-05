#include <mips/regdef.h>
#include <sys/syscall.h>

    .data
vec0:   .asciiz "14\n"
vec1:   .asciiz "-5\n"
vec2:   .asciiz "2\n"
vec3:   .asciiz "28\n"
vec4:   .asciiz "11\n"
vec5:   .asciiz "8\n"
vec6:   .asciiz "3\n"
vec7:   .asciiz "70\n"
vec8:   .asciiz "1\n"
vec9:   .asciiz "50\n"

vector: .word   vec0, vec1, vec2, vec3, vec4, vec5, vec6, vec7, vec8, vec9

    .text

    .abicalls
    .align 2                    # alineacion 2^2

main:
    la		a0, vector		#cargamos vector 
    add     a1, a0, 36
    li      t0,0
    move    s0,a0
    li      a2,1
    jal     quicksort
    li      s1,0
imprimir:
    bgt     s1,36,fin_main
    add     t0,s0,s1
    lw      a0,0(t0)
    li      v0, 4
    syscall
    addi    s1,s1,4
    b		imprimir			# branch to imprimir
fin_main:
    li   v0,10
    syscall

    .globl  quicksort
    .ent    quicksort

quicksort:

    bgt		a0, a1, fin_quicksort	# if a0 > a1 then fin_quicksort  
    addi    sp,sp,-20
    sw      s0,16(sp)
    sw      s1,12(sp)
    sw      s2,8(sp)
    sw      s3,4(sp)
    sw      s4,0(sp)

    move    s0,a0
    move    s1,a1
    move    s2,a2
    move    s3,ra
    jal     partition
    move    s4,v0
    move    a0,s0
    addi    a1,s4,-4
    move    a2,s2
    jal     quicksort
    addi    a0,s4,4
    move    a1,s1
    move    a2,s2
    jal     quicksort
    move    ra, s3
    lw      s0,16(sp)
    lw      s1,12(sp)
    lw      s2,8(sp)
    lw      s3,4(sp)
    lw      s4,0(sp)
    addi    sp,sp,20
fin_quicksort:
    jr		ra					# jump to ra

    .end    quicksort
    .size   quicksort,.-quicksort
    

partition:
    addi    sp,sp,-28    #manejo del stack
    sw		s0, 24(sp)		
    sw      s1, 20(sp)
    sw      s2, 16(sp)
    sw		s3, 12(sp)		 
    sw      s4, 8(sp)
    sw      s5, 4(sp)
    sw      s6, 0(sp)
    nop
    move 	s0, a0		# s0 = (char** a)
    move 	s1, a1		# s1 = (char**b)
    move    s2, a2        # s2 = num
    lw      s3, 0(s1)        # s3 = pivot (char*)
    li		s4, -4		# s4 = i = -1 
    li		s5, 0		# s5 = j = 0
    move    s6,ra
    beq     s2, 0, loop
pivot_entero:
    move    a0,s3
    jal     mi_atoi
    move    s3,v0
loop:
    add		t0, s5, s0		# t0 = (char**) &a[j]
    beq     t0, s1, fin       # &a[j]== b then fin
    lw      t1, 0(t0)            # t1 = (char*) a[j]
    move    a0, t1             # a1 = a[j]
    move    a1, s3             # a1 = pivot
    beq     s2, 0, alfa          # si num = 0 comparar alfabeticamente
    jal     mi_atoi
    move 	a0,v0		# ta0,v0
    jal		cmp_int             # cmp_int(char*pivot,char*a[j]);
    nop
    b		swap_decision			# branch to swap_decision
alfa:
    jal     cmp_alfa            #cmp_alfa(char*pivot,char*a[j]);
    nop

swap_decision:                  #cmp(pivot,a[j]) = 0 si pivot >= a[j] || 1 si pivot<a[j]
    beq		v0, 0, next	# if v0 != 0 (a[j]>pivot) no hay swap
    add     a0,s5,s0 # a0 = &a[j]
    addi    s4,s4,4   # i+=1
    add     a1,s0,s4 # a1 = &a[i]
    jal     swap        # swap(char**&a[j],char**&a[i]);
    nop
next:
    addi    s5,s5,4   # j+=1
    b		loop		# branch to loop
fin:
    addi    s4,s4,4       # i+=1
    add     a0,s0,s4     # a0 = &a[i]
    move    a1,s1         # a1 = &pivot
    jal     swap            # swap(char** a[i], char** pivot);
    nop 
    add    v0, s0, s4    #return &a[i]
    move    ra, s6        # ra = s6
    lw		s0, 24(sp)	#reponemos el stack 
    lw      s1, 20(sp)
    lw      s2, 16(sp)
    lw		s3, 12(sp)		 
    lw      s4, 8(sp)
    lw      s5, 4(sp)
    lw      s6, 0(sp)
    addi    sp,sp,28
    jr		ra				# jump to ra
    



swap:                   #swap(void* a, void* b);
    lw  t0, 0(a0)  # t0 = *a;
    lw  t1, 0(a1)  # t1 = *b;
    sw  t0, 0(a1)  # *b  = t0;
    sw  t1, 0(a0)  # *a = t1;
    jr		ra		# jump to ra
    


cmp_alfa:               #cmp_alfa(char*a,char*b); 1 si b>a, 0 si a>=b
    li  t0,0   # t0 = i = 0
    li  t3,0   # t3 = 0 guardaremos a[i]
    li  t4,0   # t4 = 0 guardaremos b[i]
    li  t5,0   # t5 = 0 (usado para comparar)
loop_cmp_alfa:
    add    t1,a0,t0  # t1 = &a[i]
    add    t2,a1,t0  # t2 = &b[i]
    lbu    t3,0(t1)   # t3 = a[i]
    lbu    t4,0(t2)   # t4 = b[i]
    beq    t4,t5,a_mayor # si b[i] == '\0' return 0
    nop
    beq    t3,t5,b_mayor # si a[i] == '\0' return 1
    bgt		t3, t4, a_mayor	# if a[i] > b[i] then a_mayor
    bgt     t4, t3, b_mayor   # if b[i] > a[i] then b_mayor
    addi    t0, t0, 1         # i += 1
    b loop_cmp_alfa
    nop
a_mayor:
    li  v0,0       #return 0
    b   fin_cmp_alfa
    nop
b_mayor:                            
    li v0,1       #return 1
    b fin_cmp_alfa
    nop
fin_cmp_alfa:
    jr		ra					# jump to ra
    



cmp_int:                #cmp_int(int a,int b); 1 si b>a, 0 si a>=b
    addi    sp,sp,-12  #manejo del stack
    sw      s0,8(sp)
    sw      s1,4(sp)
    sw      s2,0(sp)
    nop
    move    s0,a0     # s0 = a
    move    s1,a1     # s1 = b
    move    s2,ra     # s2 = ra
    bgt		a1, a0, int_b_mayor	# if s1 > s0 then int_b_mayor
    nop
int_a_mayor:
    li		v0, 0		# return 0
    b		fin_cmp_int			# branch to fin_cmp_int
    nop
int_b_mayor:
    li		v0, 1		# return 1
    b		fin_cmp_int			# branch to fin_cmp_int
    nop
fin_cmp_int:
    move    ra,s2 # recuperamos ra
    lw  s0, 8(sp) #reponemos el stack
    lw  s1, 4(sp)
    lw  s2, 0(sp)
    addi	sp, sp, 12			# sp = sp + 8
    jr		ra					# jump to ra




mi_atoi:
    li      t5, 10     # t5 = 10
    li      t6, 45   # t6 = '-'
    li      t7, 43     # t7 = '+'
    li      t8, 10 # t8 = '\n'
    li      v0, 0      # result = 0
    li		t1, 0		# t1 = i = 0
    add		t2, t1, a0		# t2 = str = &str[0]
    lb		t3, 0(t2)		# t3 = str[0]
    beq		t3, t6, case_menos 	# if str[0] == '-' signo_menos then case_menos
    beq		t3, t6, case_mas	# if str[0] == '+' then case_mas
    li		t4, 1		# t4 = 1, t4 representa el signo del numero (1 por default)
    b       loop_atoi    #branch always al loop
case_menos:
    li		t4,-1 		# t4 = -1
    b       inc_i       # branch to inc_i
case_mas:
    li      t4,1       # t4 = 1 (igual ya estaba en 1)
    b		inc_i			# branch to inc_i
    
loop_atoi:
    add     t2,t1,a0 # t2 = &str[i]
    lb      t3,0(t2)     # t3 = str[i]
    beq     t3, 0, fin_atoi   # if str[i] = '\0' then fin
    beq		t3, t8, fin_atoi	# if str[i] == '\n' then fin
    mulo	v0, v0, t5			# result*=10    
    addiu   t3, t3, -48
    beq     t4, -1, negativo   # si t4 == -1 then caso negativo
    add     v0, v0, t3       #result+=str[i]-48
    b       inc_i
negativo:
    sub     v0, v0, t3       #result-=str[i]-48
inc_i:
    addi	t1, t1, 1			# t1 = t1 + 1
    b		loop_atoi			# branch to loop
fin_atoi:
    j       ra
