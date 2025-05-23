;-----------------------------------------------------------------------------
;----������, �������� ��������� ��� ��������� �������� ���� ������------------
;-----------------------------------------------------------------------------
.MODEL SMALL
.STACK 100H
 ;----------------------------------------------------------------------------
 OKNO STRUC
 X1 DW 0                   ;[DI]
 Y1 DW 0                   ;[DI+2] 
 X2 DW 0                   ;[DI+4]
 Y2 DW 0                   ;[DI+6]
 COLOR DW 30               ;[DI+8]                            
 NUMBER DW 0               ;[DI+10]
 CURX DW 1                 ;[DI+12] - ��������� ������� X
 CURY DW 1                 ;[DI+14] - ��������� ������� Y
 BUF DW 0                  ;[DI+16] - �������� � ������
 POLOGENEI_KURSORA DW 0    ;[DI+18] - ��������� ������� � ����
 OPEN_OR_CLOSE_WINDOW DW 0 ;[DI+20]    
 OKNO ENDS
 ;----------------------------------------------------------------------------
.DATA
 CSS EQU 22                                      ;�������� �� ������� ��������
 ;----------------------------------------------------------------------------
 GLOBAL ANTICD:WORD
 GLOBAL BUFER:BYTE
 GLOBAL MAS1:OKNO
 GLOBAL PAR1:WORD
 GLOBAL PAR2:WORD
 GLOBAL PAR3:WORD
 GLOBAL PAR4:WORD
 GLOBAL PAR5:BYTE
 GLOBAL PAR6:WORD
 ;----------------------------------------------------------------------------
 GLOBAL R:WORD
 GLOBAL CD:WORD
 GLOBAL MAS:WORD
 GLOBAL RISOBANIE_NEW_WINDOW:PROC
 CHISLO_BYTE EQU 693
.386
.CODE
 EXTRN NEW_WINDOW:NEAR
 EXTRN WINDOW:NEAR
 EXTRN USER:NEAR
 EXTRN PROCEDURE_MAS:NEAR
;-----------------------------���� ������-------------------------------------
RISOBANIE_NEW_WINDOW PROC
                 ;-----------------������� ���� ����� ��������----------------
                 PUSH SI
                 PUSH DI
                 PUSH CX
                 ;------------------------------------------------------------
                 LEA SI,MAS
                 MOV DI,[SI]
                 MOV AX,2
                 CMP [DI+20],AX
                 JNE NET_FLAGG_OLD                         ;������� ����� ����
                 ;----------------------[DI+20]=2-----------------------------
                 OPEN_OLD:
                          INC ANTICD
                          MOV AX,1
                          MOV [DI+20],AX
                 CMP CD,1
                 JE NET_OPEN_OLD
                 ;----------����� ������� ������ ���� ��������----------------
                 PUSH DX
                 PUSH CX
                 ;------
                 MOV DX,DI    
                 MOV CX,CD
                 DEC CX
                 LEA SI,MAS 
                 CIKL@: ;�������� ������ ���� ��� �������� (����� ����� �����)
                      MOV BX,[SI+2]                   ;��������� �������� ����
                      MOV [SI],BX
                      ADD SI,2
                 LOOP CIKL@
                 ;---------
                 LEA SI,MAS
                 MOV AX,CD
                 IMUL AX,2
                 ADD SI,AX
                 SUB SI,2
                 ;-------
                 MOV DI,DX
                 MOV [SI],DI ;���������� ���� �� �������
                 ;---------------������� ����� ������� ����-------------------
                 ;------� ������ ������ DI-�������� ��������� ����------------
                 CALL PROCEDURE_MAS
                 MOV AX,0
                 MOV [DI+18],AX
                 PUSH SI
                 LEA SI,BUFER
                 MOV DI,[DI+16]
                 ADD SI,DI
                 MOV CX,CHISLO_BYTE
                 CIKL_BUFER_20H@:
                                MOV AH,20H
                                MOV [SI],AH
                                INC SI
                 LOOP CIKL_BUFER_20H@
                 POP SI
                 POP CX
                 POP DX
                 CALL USER
                 ;------------------------------------------------------------
                 POP CX
                 POP DI
                 POP SI
                 JMP OK_OLD_WINDOW                      ;�� ������� ����� ����                
              ;---------------------------------------------------------------
              ;���� ���� ���� ������� ����, ��� �������� ��� ����� ������� ���
              NET_OPEN_OLD:
                 MOV AX,0
                 MOV [DI+18],AX
                 LEA SI,BUFER
                 MOV DI,[DI+16]
                 ADD SI,DI
                 MOV CX,CHISLO_BYTE
                 CIKL_BUFER_20H:
                                MOV AH,20H
                                MOV [SI],AH
                                INC SI
                 LOOP CIKL_BUFER_20H
                 ;------------------------------------------------------------
                 CALL USER
                 ;------------------------------------------------------------
                 POP CX
                 POP DI
                 POP SI
                 JMP OK_OLD_WINDOW                      ;�� ������� ����� ����
                 ;------------------------------------------------------------
                 ;------���� �� ������� �����, � �� ��������� ������ ����-----
                 ;------------------------------------------------------------
                 NET_FLAGG_OLD:
                 POP CX
                 POP DI
                 POP SI
                 ;-----
                 INC ANTICD
                 INC CD
                 CALL NEW_WINDOW                     
                 MOV DI,R
                 MOV AX,[DI]
                 MOV PAR3,AX          
                 MOV AX,[DI+4]
                 MOV PAR4,AX                 
                 MOV AX,[DI+2]
                 MOV PAR1,AX              
                 MOV AX,[DI+6]
                 MOV PAR2,AX                     
                 MOV AX,[DI+8]
                 MOV WORD PTR PAR5[SI],AX                   
                 MOV AX,[DI+10]
                 MOV PAR6,AX           
                 ADD DI,CSS        
                 MOV R,DI             
                 CALL WINDOW
                 ;------------------------------------------------------------
                 OK_OLD_WINDOW:RET
RISOBANIE_NEW_WINDOW ENDP
;-----------------------------------------------------------------------------
END
