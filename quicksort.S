#include <mips/regdef.h>
#include <sys/syscall.h>


    .data
vec0:   .asciiz "14\n"
vec1:   .asciiz "-5\n"
vec2:   .asciiz "2\n"
vec3:   .asciiz "28\n"
vec4:   .asciiz "50\n"
vec5:   .asciiz "8\n"
vec6:   .asciiz "3\n"
vec7:   .asciiz "70\n"
vec8:   .asciiz "1\n"
vec9:   .asciiz "50\n"

vector: .word   vec0, vec1, vec2, vec3, vec4, vec5, vec6, vec7, vec8, vec9


## quicksort(char** a, char** b, int num);
## arreglo = [a,....,b]
## si num = 0 se ordena alfabeticamente
## si num != 0 se ordena como si fuesen enteros

    .text

    .abicalls
    .align 2                    # alineacion 2^2


main:
    la		a0, vector		#cargamos vector 
    add     a1, a0, 36
    li      t0,0
    move    s0,a0
    li      a2,0
    jal     quicksort
    li      s1,0
imprimir:
    bgt     s1,36,fin_main
    add    t0,s0,s1
    lw      a0,0(t0)
    li   v0,4
    syscall
    addi    s1,s1,4
    b		imprimir			# branch to imprimir
fin_main:
    li   v0,10
    syscall



    .globl  quicksort
    .ent    quicksort
    
## void quicksort(char** a, char** b, int mum);
quicksort:
    ## if (a>b) return;
    bgt		a0, a1, fin_quicksort	# if a0 > a1 then fin_quicksort  
    
##Prologo
    addiu   sp,sp,-24
    sw      s0,16(sp)     #en s0 guardaremos el resultado de partition
    sw      ra,20(sp)     #Guardamos la direccion de retorno

    ##Guardamos los argumentos en el stackframe del caller
    sw      a0,24(sp)
    sw      a1,28(sp)
    sw      a2,32(sp)
    jal     partition
    move    s0,v0         #s0 = char** x = partition(a,b,num)
    lw      a0,24(sp)     
    addi    a1,v0,-4
    lw      a2,32(sp)
    jal     quicksort       #quicksort(a,x-1,num)
    addi    a0,s0,4
    lw      a1,28(sp)
    lw      a2,32(sp)
    jal     quicksort       #quicksort(x+1,b,num)

##Epílogo
    lw      s0,16(sp)
    lw      ra,20(sp)
    addiu   sp,sp,24
fin_quicksort:
    jr		ra					# jump to ra

    .end    quicksort
    .size   quicksort,.-quicksort
    
## char** partition(char** a, char** b, int num)
partition:
##Prólogo
    addiu   sp,sp,-32    #manejo del stack
    sw		s0, 16(sp)	# en s0 guardaremos el pivot	
    sw      s1, 20(sp)    # en s1 guardaremos un contador i
    sw      s2, 24(sp)    # en s2 guardaremos un contador j
    sw      ra, 28(sp)    # guardamos la direccion de retorno
    
    ##guardamos los argumentos en el stackframe del caller
    sw      a0, 32(sp)    
    sw      a1, 36(sp)
    sw      a2, 40(sp)
    nop
    lw      s0, 0(a1)     # s0 = pivot (char*)
    li		s1, -4		    # s4 = i = -1 
    li		s2, 0		    # s5 = j = 0
    beq     a2, 0, loop   # si num==0 vamos al loop sin atoi al pivot
pivot_entero:
    move    a0,s0
    jal     mi_atoi
    move    s0,v0
loop:
    ##cargamos los argumentos desde el stackframe del caller
    lw      a0, 32(sp)        
    lw      a1, 36(sp)
    lw      a2, 40(sp)
    
    add		t0, s2, a0		# t0 = (char**) &a[j]
    beq     t0, a1, fin       # si &a[j] == b then fin
    lw      a1, 0(t0)         # a1 = (char*) a[j]
    move    a0, s0            # a0 = pivot
    beq     a2, 0, alfa       # si num == 0 comparar alfabeticamente
    move    a0, a1            # convertir a[j] en int
    jal     mi_atoi
    move 	a1,v0		        # a1 = v0 = atoi(a[j])
    move    a0,s0             # a0 = pivot (otra vez)
    jal		cmp_int             # cmp_int(int pivot,int a[j]);
    nop
    b		swap_decision			# branch to swap_decision
alfa:
    jal     cmp_alfa            #cmp_alfa(char*pivot,char*a[j]);
    nop
##cmp(pivot,a[j]): = 0 si pivot>=a[j]|| 1 si a[j]>pivot
swap_decision:
    bgt		v0,0, next	# si pivot >= a[j] hay swap, si no, next
    lw      a0, 32(sp)    # a0 = a
    addi    s1,s1,4   # i+=1
    add     a1,a0,s1 # a1 = &a[i]
    add     a0,a0,s2 # a0 = &a[j]
    jal     swap        # swap(char**&a[j],char**&a[i]);
    nop
next:
    addi    s2,s2,4   # j+=1
    b		loop		# branch to loop
fin:
    addi    s1,s1,4       # i+=1
    add     a0,a0,s1     # a0 = &a[i]
    jal     swap            # swap(char** a[i], char** &pivot);
    nop
    lw      a0, 32(sp)
    add     v0, a0, s1    #return &a[i] = a + i
##Epílogo
    lw		s0, 16(sp)	#reponemos el stack 
    lw      s1, 20(sp)
    lw      s2, 24(sp)
    lw      ra, 28(sp)
    addiu   sp,sp,32
    jr		ra				# jump to ra
    


##swap(void* a, void* b);
swap:
    lw  t0, 0(a0)  # t0 = *a;
    lw  t1, 0(a1)  # t1 = *b;
    sw  t0, 0(a1)  # *b  = t0;
    sw  t1, 0(a0)  # *a = t1;
    jr		ra		# jump to ra
    

##cmp_alfa(char*a,char*b); 1 si b>a, 0 si a>=b
cmp_alfa:
    ## no tiene data ni subrutinas, no hay manejo de stackframe
    li  t0,0   # t0 = i = 0
    li  t3,0   # t3 = 0 guardaremos a[i]
    li  t4,0   # t4 = 0 guardaremos b[i]
loop_cmp_alfa:
    add    t1,a0,t0  # t1 = &a[i]
    add    t2,a1,t0  # t2 = &b[i]
    lbu    t3,0(t1)   # t3 = a[i]
    lbu    t4,0(t2)   # t4 = b[i]
    beq    t4,0,a_mayor # si b[i] == '\0' return 0
    nop
    beq     t3,0,b_mayor # si a[i] == '\0' return 1
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
    


##cmp_int(int a,int b); 1 si b>a, 0 si a>=b
cmp_int:
    ##no tiene data ni subrutinas, no hay manejo de stackframe
    bgt		a1, a0, int_b_mayor	# if b > a then int_b_mayor
    nop
int_a_mayor:
    li		v0, 0		        # return 0
    b		fin_cmp_int			# branch to fin_cmp_int
    nop
int_b_mayor:
    li		v0, 1		        # return 1
fin_cmp_int:
    jr		ra					# jump to ra



## int mi_atoi(char* str)
mi_atoi:
    ##no tiene data ni subrutinas, no hay manejo de stackframe
    li      t5, 10     # t5 = 10
    li      t6, 45     # t6 = '-'
    li      t7, 43     # t7 = '+'
    li      v0, 0      # result = 0
    li		t1, 0		# t1 = i = 0
    add		t2, t1, a0		# t2 = str = &str[0]
    lb		t3, 0(t2)		    # t3 = str[0]
    beq		t3, t6, case_menos 	# if str[0] == '-' signo_menos then case_menos
    beq		t3, t6, case_mas	# if str[0] == '+' then case_mas
    li		t4, 0		        # t4 = signo = 0 (positivo por default)
    b       loop_atoi    #branch always al loop
case_menos:
    li		t4,1 		# t4 = 1 (negativo)
    b       inc_i       # branch to inc_i
case_mas:
    li      t4,1       # t4 = 1 (igual ya estaba en 1)
    b		inc_i			# branch to inc_i  
loop_atoi:
    add     t2,t1,a0         #t2 = &str[i]
    lb      t3,0(t2)          # t3 = str[i]
    beq     t3, 0, fin_atoi        # if str[i] = '\0' then fin
    beq		t3, t5, fin_atoi	    # if str[i] == '\n' then fin
    mulo	v0, v0, t5			# result*=10    
    addiu   t3, t3, -48
    bne     t4, 0, negativo       # si t4 == -1 then caso negativo
    add     v0, v0, t3           #result+=str[i]-48
    b       inc_i
negativo:
    sub     v0, v0, t3           #result-=str[i]-48
inc_i:
    addi	t1, t1, 1			    # t1 = t1 + 1
    b		loop_atoi			    # branch to loop
fin_atoi:
    j       ra