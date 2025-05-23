;-----------------------------------------------------------------------------
;-----------------��������� ����� � ���� OPEN---------------------------------
;-----------------------------------------------------------------------------
.MODEL SMALL
.STACK 100H
.DATA
 AXT DW 0
 GLOBAL CD:WORD
 GLOBAL CHISLO_BYTE:WORD
 BUFER_OPEN_FILE DB 693 DUP (20H)              ;������ ������ �� ����� � �����
 KOL_SIMBOL_MENU EQU 43
 GLOBAL BUFER:BYTE
 GLOBAL BUFER_OPEN:BYTE
 ;----------------------------------------------------------------------------
 GLOBAL RAM1:WORD
 GLOBAL RAM2:WORD
 GLOBAL RAM3:WORD
 ;----------------------------------------------------------------------------
 GLOBAL OI_TEC:WORD
 GLOBAL PAR1:WORD
 GLOBAL PAR2:WORD
 GLOBAL PAR3:WORD
 GLOBAL PAR4:WORD
 GLOBAL PAR5:BYTE
 ;----------------------------------------------------------------------------
 GLOBAL FLAG_OPEN:BYTE
 GLOBAL TEC_AL:BYTE
 GLOBAL TEC_AH:BYTE
 GLOBAL FLAG_OPEN_ESC:BYTE
 GLOBAL FLAG_OPEN_OK:BYTE
 GLOBAL BBOD_WINDOW_OPEN:PROC
.CODE
 EXTRN PROCEDURE_MAS:NEAR
 EXTRN WINDOW_ZAGOLOBOK:NEAR
 EXTRN RAMA:NEAR
 EXTRN USER:NEAR
 EXTRN RISOBANIE_NEW_WINDOW:NEAR
;-----------------------------------------------------------------------------
BBOD_WINDOW_OPEN PROC
                 ;---------------������� �� ������� �� OK---------------------
                 CMP FLAG_OPEN_OK,1
                 JNE NET_ES_OPEN_ENTER
                 JMP NEAR:ES_OPEN_ENTER
                 NET_ES_OPEN_ENTER:
                 ;---------------������� �� ������� �� ESC--------------------
                 CMP FLAG_OPEN_ESC,1
                 JE NET_NET_ESC_MOUSE
                 JMP NEAR:NET_ESC_MOUSE
                 NET_NET_ESC_MOUSE:
                 ;---------------��, ���� ����� ESC �����---------------------
                 JMP NEAR:EXIT_OPEN@                           ;������ �������
                 ;------------------------------------------------------------
                 NET_ESC_MOUSE:
                 CMP TEC_AL,20H
                 JE EXIT 
                 CMP TEC_AH,72
                 JE EXIT 
                 CMP TEC_AH,75
                 JE EXIT
                 CMP TEC_AH,77
                 JE EXIT
                 CMP TEC_AH,80
                 JE EXIT
                 JMP NET_EXIT
                 EXIT:RET
                 ;------------------------------------------------------------
                 NET_EXIT:
                 CMP TEC_AL,27
                 JE NET_NET_ESC
                 JMP NEAR:NET_ESC
                 NET_NET_ESC:
                 ;---------------��, ���� ����� ESC---------------------------
                 MOV FLAG_OPEN,0
                 JMP NEAR:EXIT_OPEN@                           ;������ �������
                 ;-----------------�������� �� ENTER--------------------------
                 NET_ESC:
                 CMP TEC_AL,13
                 JNE NET_NET_ES_OPEN_ENTER
                 JMP NEAR:ES_OPEN_ENTER
                 NET_NET_ES_OPEN_ENTER:
                 ;------------------------------------------------------------
                 ;-----------------���, ���� �� ������� ENTER-----------------
                 ;-----------------�������� �� BS-----------------------------
                 ;------------------------------------------------------------
                 CMP TEC_AL,8
                 JNE NET_BS_OPEN
                 ;----------------��, ���� ����� BS---------------------------
                 CMP OI_TEC,0
                 JNE NET_EXIT_OPEN              ;���� ������� ������, �� �����
                 JMP NEAR:EXIT_OPEN
                 NET_EXIT_OPEN:
                 ;------------------------------------------------------------
                 ;----------------���������� ��������-------------------------
                 ;----------------�������� ���� �������-----------------------
                 ;------------------------------------------------------------
                 MOV CX,OI_TEC
                 MOV DI,1322
                 CIKL_OPEN_TOCH:
                          MOV AL,46
                          MOV AH,120
                          MOV ES:[DI],AX
                          ADD DI,2
                          INC SI
                 LOOP CIKL_OPEN_TOCH
                 ;------------------------------------------------------------
                 DEC OI_TEC      ;��������� ����� �������� � ������ BUFER_OPEN
                 LEA SI,BUFER_OPEN
                 MOV AX,OI_TEC
                 ADD SI,AX
                 MOV AH,0
                 MOV [SI],AH        ;���������� �� ����� ����������� ������� 0
                 ;--------------���� ������ 0 ��������, �� �����--------------
                 CMP OI_TEC,0
                 JNE NET_NET_EXIT_OPEN
                 JMP NEAR:EXIT_OPEN
                 NET_NET_EXIT_OPEN:
                 ;----------------���������� ������ �� �����------------------
                 LEA SI,BUFER_OPEN
                 MOV CX,OI_TEC
                 MOV DI,1322                           ;�������� � �����������
                 CIKL_OPEN_BS:
                          MOV AL,[SI]
                          MOV AH,120
                          MOV ES:[DI],AX
                          ADD DI,2
                          INC SI
                 LOOP CIKL_OPEN_BS
                 JMP EXIT_OPEN        ;������� ����� ������ ���������� �������
                 ;------------------------------------------------------------
                 ;-------���� �� ������� BS, ���������� ����------------------
                 ;------------------------------------------------------------
                 NET_BS_OPEN:
                 CMP OI_TEC,KOL_SIMBOL_MENU
                 JL NET_NET_EXIT_OPEN@;���� ������� ������ ������, �� �������
                 JMP NEAR:EXIT_OPEN
                 NET_NET_EXIT_OPEN@:
                 ;------------------------------------------------------------
                 LEA SI,BUFER_OPEN
                 MOV AX,OI_TEC
                 ADD SI,AX
                 MOV AH,TEC_AL
                 MOV [SI],AH        ;���������� ������ � ����� ����� ��� �����
                 INC OI_TEC
                 ;----------------���������� ������ �� �����------------------
                 LEA SI,BUFER_OPEN
                 MOV CX,OI_TEC
                 MOV DI,1322
                 CIKL_OPEN:
                          MOV AL,[SI]
                          MOV AH,120
                          MOV ES:[DI],AX
                          ADD DI,2
                          INC SI
                 LOOP CIKL_OPEN
                 JMP EXIT_OPEN                  ;�������, �� ������� ���� ����
                 ;------------------------------------------------------------
                 ;------------------------------------------------------------
                 ;------------------���� ����� ENTER--------------------------
                 ;------------------------------------------------------------
                 ;------------------------------------------------------------
                 ES_OPEN_ENTER:
                 ;------------------����� �� ����-----------------------------
                 MOV FLAG_OPEN_OK,0
                 MOV OI_TEC,0
                 ;------------------------------------------------------------
                 ;-------------------���������� ENTER-------------------------
                 ;------------------------------------------------------------
                 ;------------------------------------------------------------
                 ;--------��������� ����� ���� � ����, ���� ���� ����������,--
                 ;--------����� ������ ��������� ����� ������ ����------------
                 ;------------------------------------------------------------
                 MOV AH,3DH
                 MOV AL,10B
                 LEA DX,BUFER_OPEN
                 MOV CX,1
                 INT 21H
                 MOV AXT,AX
                 PUSH AX                                  ;������������� �����
                 ;------------------------------------------------------------
                 JB ERROR
                 ;---------------���� ������ ���------------------------------
                 ;------------������ �� ����� � BUFER_OPEN_FILE---------------
                 POP AX
                 MOV BX,AX
                 MOV AX,3F00H
                 MOV CX,CHISLO_BYTE
                 LEA DX,BUFER_OPEN_FILE
                 INT 21H
                 ;------------------��������� ����----------------------------
                 MOV BX,AXT
                 MOV AX,3E00H
                 INT 21H
                 ;------------------------------------------------------------
                 CALL RISOBANIE_NEW_WINDOW
                 ;------------------------------------------------------------
                 CALL PROCEDURE_MAS
                 LEA SI,BUFER
                 ADD SI,[DI+16]                             ;[DI+16]=���������
                 MOV CX,CHISLO_BYTE
                 LEA DI,BUFER_OPEN_FILE
                 CIKL_BUFER_OPEN_FILE:
                                      MOV AH,BYTE PTR DS:[DI]
                                      MOV [SI],AH
                                      INC SI
                                      INC DI
                 LOOP CIKL_BUFER_OPEN_FILE
                 JMP ALL
                 ;------------���� ��������� ������---------------------------
                 ERROR:
                 POP AX
                 CALL RISOBANIE_NEW_WINDOW
                 ;----------------������� BUFER_OPEN--------------------------
                 ALL:
                 MOV CX,KOL_SIMBOL_MENU
                 LEA SI,BUFER_OPEN
                 CIKL_DELETE_BUFER_OPEN:
                                        MOV AX,0
                                        MOV DS:[SI],AX
                                        INC SI
                 LOOP CIKL_DELETE_BUFER_OPEN
                 ;------------------------------------------------------------
                 ;----------------������� �� ���� OPEN------------------------
                 ;------------------------------------------------------------
                 EXIT_OPEN@:
                 ;----------------������� BUFER_OPEN--------------------------
                 MOV CX,KOL_SIMBOL_MENU
                 LEA SI,BUFER_OPEN
                 CIKL_DELETE_BUFER_OPEN_ESC:
                                        MOV AX,0
                                        MOV DS:[SI],AX
                                        INC SI
                 LOOP CIKL_DELETE_BUFER_OPEN_ESC
                 ;------------------����� �� ���� � �������-------------------
                 MOV OI_TEC,0
                 MOV FLAG_OPEN_ESC,0
                 ;------------------------------------------------------------
                 MOV PAR1,3
                 MOV PAR2,25
                 MOV PAR3,1
                 MOV PAR4,80
                 MOV PAR5,0
                 CALL WINDOW_ZAGOLOBOK
                 MOV RAM1,160
                 MOV RAM2,78
                 MOV RAM3,22     
                 CALL RAMA
                 ;------------------------------------------------------------
                 CMP CD,1
                 JL NET_USER
                 CALL USER
                 NET_USER:
                 ;------------------------------------------------------------
                 MOV FLAG_OPEN,0                   ;������� �������� ���� OPEN
                 ;------------------------------------------------------------
                 ;------------����� �� ��������� OPEN-------------------------
                 ;------------------------------------------------------------
                 EXIT_OPEN:RET
BBOD_WINDOW_OPEN ENDP
;-----------------------------------------------------------------------------
END
