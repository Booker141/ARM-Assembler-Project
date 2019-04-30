	AREA	Trabajo_Funcion,CODE,READWRITE

EscribirCaracter	EQU		&0
Salir				EQU		&11
MostrarCadena		EQU		&2
LeerCaracter		EQU		&4
	
	ALIGN
	ENTRY
	
	
	SWI 	LeerCaracter		; Interrupcion de Soft. para leer un caracter de teclado
    MOV 	r0, r11				; Guarda la tecla pulsada en r11
	
	
	BL 		READ_DATA			; Ejecuta la rutina READ_DATA
	
	SWI		Salir				; Termina el programa

READ_DATA

	;INICIALIZACION DE REGISTROS
	MOV r1, r12 				; Inicializamos el cursor(r1) con el inicio del espacio de memoria
	MOV r2, r12 				; Inicializamos el final del dato(r2) con el inicio del espacio de memoria
	MOV r3, #0					; Inicializamos el contador de cifras (r3) a cero
	MOV r4, #1					; Inicializamos el registro que usaremos para identificar las diferentes cifras
	MOV r6, #1					; Inicializamos el registro que usaremos para identificar las diferentes cifras
	MOV r7, #10					; Constante multiplicativa 10
	MOV r13, #0					; Inicializamos r13 a cero
	
	;LLAMADAS A SUBRUTINAS
	CMP r11, #49				; Se ha pulsado 1?
	BEQ	CADENA
	CMP r11, #50				; Se ha pulsado 2?
	BEQ	ENTERO
	
	;//MOSTRAR ERROR//;
	
	MOV pc, r14

CADENA
	SWI LeerCaracter			; Interrupcion de Soft. para leer un caracter de teclado	
	CMP r0, #27					; Se ha pulsado ESC?
	BEQ	ESC
	CMP r0, #8					; Se ha pulsado DEL?
	BEQ DEL	
	CMP r0, #46					; Se ha pulsado SUP?
	BEQ SUP	
	CMP r0, #37					; Se ha pulsado DRCH?
	BEQ DRCH
	CMP r0, #39					; Se ha pulsado IZQ?
	BEQ IZQ

	
	;GUARDAR CARACTER EN MEMORIA
	
	;//COMPROBAR EN QUE CODIGO SE IMPRIME POR PANTALLA (ASCII?)//;
	STR r0, [r1], #1			; Guardamos el dato en la posicion de memoria marcada por el cursor y este avanza una posicion
	ADD r2, r2, #1				; Incrementamos el final del dato
	
	SUB r13, r2, r12			; Guardamos la logitud de la cadena en r13, posicion final(r2) - posicion inicial(r12)
	
	B CADENA
	
ENTERO	
	;COMPROBACION TECLAS ESPECIALES
	SWI LeerCaracter			; Interrupcion de Soft. para leer un caracter de teclado	
	CMP r0, #27					; Se ha pulsado ESC?
	BEQ	ESC
	CMP r0, #8					; Se ha pulsado DEL?
	BEQ DEL	
	CMP r0, #46					; Se ha pulsado SUP?
	BEQ SUP	
	CMP r0, #37					; Se ha pulsado DRCH?
	BEQ DRCH
	CMP r0, #39					; Se ha pulsado IZQ?
	BEQ IZQ
	CMP r0, #13					; Se ha pulsado ENTER_INT?
	BEQ ENTER_INT
	
	;COMPROBACION DATO CORRECTO
	CMP r0, #48
	BLT ENTERO
	CMP r0, #57
	BGT	ENTERO
	
	;GUARDAR DATO EN MEMORIA
	SUB r0, r0, #48				; transformamos el codigo de tecla aa digito decimal
	STR r0, [r1], #1			; Guardamos el dato en la posicion de memoria marcada por el cursor y este avanza una posicion
	ADD r2, r2, #1				; Incrementamos el final del dato
	
	ADD r3,	r3, #1 				; Incrementamos el contador de cifras
	CMP r3, #52					; Comprobamos que no haya mas de 4 cifras (32 bits)
	BLT ENTERO
	
ENTER_INT
	MOV r1, r2					; Colocamos el cursor(r1) al final del dato(r2)
	
	LDR r0, [r1]				; Cargamos el dato
	SUB r1, r1, #1				; Movemos el cursor
	
	MUL r5, r0, r6				; Multiplicamos por su cifra correspondiente
	ADD r13, r13, r5			; Añadimos el dato a r13
	
	MUL r6, r4, r7				; Preparamos el r4 para la siguiente cifra
	
	CMP r12, r1					; Comprobamos que se haya leido todo el dato
	BLE	ENTER_INT
	
	;//MENSAJE DE FINALIZACION//;
	
	MOV pc, r14
	
ESC
	SWI Salir
	
DEL

SUP

DRCH
	ADD r1, r1, #1
	
	CMP r11, #49
	BEQ	CADENA
	
	CMP r11, #50
	BEQ	ENTERO

IZQ
	SUB	r1, r1, #1
	
	CMP r11, #49
	BEQ	CADENA
	
	CMP r11, #50
	BEQ	ENTERO

	
	END

	