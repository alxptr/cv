;-----------------------------------------------------------------------------
;------------------�������� ������ ����� ������ � ������� ����----------------
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
 CURX DW 1                 ;[DI+12] - ��������� ������� X � ����� ������
 CURY DW 1                 ;[DI+14] - ��������� ������� Y � ����� ������
 BUF DW 0                  ;[DI+16] - �������� � ������
 POLOGENEI_KURSORA DW 0    ;[DI+18] - ��������� ������� � ����
 OPEN_OR_CLOSE_WINDOW DW 0 ;[DI+20]    
 OKNO ENDS
 ;----------------------------------------------------------------------------
.DATA
 GLOBAL KAX:WORD
 GLOBAL MAS1:OKNO
 GLOBAL PRED_AL:BYTE
 GLOBAL TEC_AH:BYTE
 GLOBAL TEC_AL:BYTE
 GLOBAL BUFER:WORD
 GLOBAL BBOD_WINDOW_USER:PROC
 ;-------������������ ���������� �������� �������� � ������� ����-------------
 KOL_SIMBOLOV_STROKA_MAX EQU 63           
.CODE
 EXTRN PROCEDURE_MAS:NEAR
 EXTRN PROCEDURE_CURSOR:NEAR
 EXTRN TEXT:NEAR
;-----------------------------------------------------------------------------
BBOD_WINDOW_USER PROC
                     ;--------------------------------------------------------
                     CALL PROCEDURE_MAS
                     LEA SI,BUFER
                     ADD SI,[DI+16]                         ;[DI+16]=���������
                     ;--------------------------------------------------------
                     ;---------���� ���� ����� ESC----------------------------
                     ;--------------------------------------------------------
                     CMP TEC_AL,27
                     JNE NET_27
                     JMP NEAR:EXIT_USER
                     NET_27:
                     ;--------------------------------------------------------
                     ;---------���� ���� ����� ENTER--------------------------
                     ;--------------------------------------------------------
                     CMP TEC_AH,72
                     JE EXT1
                     CMP TEC_AH,75
                     JE EXT2
                     CMP TEC_AH,77
                     JE EXT3
                     CMP TEC_AH,80
                     JE EXT4
                     JMP OK_USER
                     ;------------------���� ����� ������� ����---------------
                     EXT4:
                     MOV AX,[DI+18]
                     ADD AX,63
                     CMP AX,693
                     JGE NET_DOWN
                     MOV [DI+18],AX
                     NET_DOWN:
                     JMP NEAR:EXIT_USER
                     ;------------------���� ����� ������� �����--------------
                     EXT1:
                     MOV AX,[DI+18]
                     SUB AX,63
                     CMP AX,0
                     JL NET_UP
                     MOV [DI+18],AX
                     NET_UP:
                     JMP NEAR:EXIT_USER
                     ;------------------���� ����� ������� �����--------------
                     EXT2:
                     MOV AX,[DI+18]
                     DEC AX
                     CMP AX,0
                     JL NET_BLEBO
                     MOV [DI+18],AX
                     NET_BLEBO:
                     JMP NEAR:EXIT_USER
                     ;------------------���� ����� ������� ������-------------
                     EXT3:
                     MOV AX,[DI+18]
                     INC AX
                     CMP AX,693
                     JGE NET_BPRABO
                     MOV [DI+18],AX
                     NET_BPRABO:
                     JMP NEAR:EXIT_USER
                     ;--------------------���������� ����---------------------
                     OK_USER:
                     CMP TEC_AL,13
                     JNE NET_ENTER
                     ;--------------------------------------------------------
                     MOV AX,[DI+18]
                     PUSH AX
                     CIKL_FTOR:
                               CMP AX,KOL_SIMBOLOV_STROKA_MAX
                               JE ES_STOR
                               CMP AX,KOL_SIMBOLOV_STROKA_MAX
                               JL ES_FTOR
                               SUB AX,KOL_SIMBOLOV_STROKA_MAX
                     JMP CIKL_FTOR
                     ;----------������ �������� � ����� ���� ��� �������------
                     ES_STOR:
                     POP AX
                     MOV KAX,AX
                     ;---------
                     MOV AL,TEC_AL
                     CMP PRED_AL,AL
                     JNE NET_PRED_AL
                     ;---------------������ �������� �������------------------
                     MOV AX,KAX
                     ADD AX,KOL_SIMBOLOV_STROKA_MAX
                     ;-----------���� �� ������� �� ���������-----------------
                     CMP AX,693
                     JGE NET_FTOR@
                     MOV [DI+18],AX
                     NET_FTOR@:
                     ;-----------
                     NET_PRED_AL:
                     JMP NEAR:ES_BS
                     ;-----��� ��������� ������ ������������ �������----------
                     ES_FTOR:
                     MOV BX,AX          ;BX=������� ����� ���������� ������� �
                             ;������� ������ (������� ������ 2 ��� 4 ��������)                     
                     POP AX
                     MOV DX,KOL_SIMBOLOV_STROKA_MAX
                     SUB DX,BX
                     ADD AX,DX
                     ;-----------���� �� ������� �� ���������-----------------
                     CMP AX,693
                     JGE NET_FTOR
                     MOV [DI+18],AX
                     NET_FTOR:
                     ;--------
                     JMP ES_BS
                     ;-----------------�������� �� BS-------------------------
                     NET_ENTER:
                     CMP TEC_AL,8
                     JNE NET_BS
                     ;--------------------------------------------------------
                     ;---------���� ���� ����� BS-----------------------------
                     ;--------------------------------------------------------
                     MOV AX,[DI+18]
                     CMP AX,1
                     JL ES_BS                 ;���� ������� ������-������ ����
                     ;--------------------------------------------------------
                     ADD SI,[DI+18]
                     DEC SI
                     ;-------------
                     MOV AL,20H
                     MOV DS:[SI],AL                    
                     ;-------------
                     MOV AX,[DI+18]
                     DEC AX
                     MOV [DI+18],AX
                     ;-------------
                     JMP ES_BS
                     ;--------------------------------------------------------
                     ;--------------------------------------------------------
                     ;--------------------------------------------------------
                     NET_BS:
                     MOV AX,[DI+18]
                     CMP AX,693
                     JE ES_BS
                     ;--------------------------------------------------------
                     ADD SI,[DI+18]                  ;[DI+18]=����� ����������
                     MOV AX,[DI+18]
                     INC AX
                     MOV [DI+18],AX
                     ;-------------
                     MOV AL,TEC_AL
                     MOV DS:[SI],AL                    
                     ;--------------------------------------------------------
                     ES_BS:CALL TEXT
                           MOV AL,TEC_AL
                           MOV PRED_AL,AL
                     EXIT_USER:
                     CALL PROCEDURE_CURSOR
                     RET
BBOD_WINDOW_USER ENDP
;-----------------------------------------------------------------------------
END
