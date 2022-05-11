#t0 - liczba -> wyk�adnik
#t1 - wyk�adnik (licznik przesuni��)
#t2 - mantysa
#t3 - por�wnywanie bit�w
#t4 - znak

.data
	in_i: .word 157
	out_f: .float 0.0

.text
	lw $t0, in_i		#zapis liczby do konwersji
	beqz $t0, ending 	#je�eli 0 zako�cz
	
	bgtz $t0, no_neg	#t0<0 -> negacja wpp. pomijamy kolejn� linijk�
	neg $t0, $t0
	li $t4 0x80000000	#t4 - znak liczby (dodatnia - domy�lnie 0; ujemna - 1)
	no_neg:
	
	li $t1 127		#licznik przesuni�� -> pot�ga 2 (offset 127)
	li $t2 0x000000		#mantysa
	
	loop:
		beq $t0, 1, put_together 	#liczba = 1 -> koniec przesuwania
		andi $t3, $t0, 0x00000001		#ostatni bit = liczba & 1
		add $t1, $t1, 1			#wyk�adnik++
		srl $t0, $t0, 1			#przesuw liczby na prawo
		srl $t2, $t2, 1			#przesuw mantysy
		bnez $t3, inc_mantissa
		j loop
		
	inc_mantissa:
		ori $t2, $t2, 0x40000000 	#dopisz 1 z przodu mantysy
		j loop
	
	put_together:
		srl $t2, $t2, 8		#przesuw mantysy na prawo
		sll $t1, $t1, 23	#przesuw na odpowiedni� pozycj�	(do wyk�adnika)
		or $t2, $t2, $t1 	#zmontuj wyk�adnik i mantys�
		or $t2, $t2, $t4	#dodawanie zapami�tanego znaku
	
	ending:
		sw $t2, out_f
		li $v0, 2
		l.s $f12, out_f
		syscall
	
