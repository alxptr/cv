;-----------------------------------------------------------------------------
;------------------������ ��������� ����--------------------------------------
;-----------------------------------------------------------------------------
.MODEL SMALL
.STACK 100H
.DATA
 GLOBAL NASTROIKA_MOUSE:PROC
.CODE
;--------------------���� ������----------------------------------------------
NASTROIKA_MOUSE PROC
MOV AX,0
INT 33H
MOV AX,07H
MOV CX,1
MOV DX,639
INT 33H
MOV AX,08H
MOV CX,1
MOV DX,194
INT 33H
MOV AX,04
MOV CX,639
MOV DX,1
MOV AX,1
INT 33h
RET
NASTROIKA_MOUSE ENDP
;-----------------------------------------------------------------------------
END
