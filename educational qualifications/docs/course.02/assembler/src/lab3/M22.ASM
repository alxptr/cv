;-----------------------------------------------------------------------------
;-----------------��������� ����� � ���� SAVE---------------------------------
;-----------------------------------------------------------------------------
.MODEL SMALL
.STACK 100H
.DATA
 GLOBAL CHISLO_BYTE:WORD
 KOL_SIMBOL_MENU EQU 43
 GLOBAL BUFER:BYTE
 GLOBAL BUFER_SIMBOL_SAVE:BYTE
 GLOBAL BUFER_SAVE:BYTE
 ;----------------------------------------------------------------------------
 GLOBAL CD:WORD
 GLOBAL RAM1:WORD
 GLOBAL RAM2:WORD
 GLOBAL RAM3:WORD
 ;----------------------------------------------------------------------------
 GLOBAL SI_TEC:WORD
 GLOBAL PAR1:WORD
 GLOBAL PAR2:WORD
 GLOBAL PAR3:WORD
 GLOBAL PAR4:WORD
 GLOBAL PAR5:BYTE
 ;----------------------------------------------------------------------------
 GLOBAL FLAG_SAVE:BYTE
 GLOBAL TEC_AL:BYTE
 GLOBAL TEC_AH:BYTE
 GLOBAL FLAG_SAVE_ESC:BYTE
 GLOBAL FLAG_SAVE_OK:BYTE
 GLOBAL BBOD_WINDOW_SAVE:PROC
 C DW 0
 FLAG DB 0
.CODE
 EXTRN PROCEDURE_MAS:NEAR
 EXTRN WINDOW_ZAGOLOBOK:NEAR
 EXTRN RAMA:NEAR
 EXTRN USER:NEAR
;-----------------------------------------------------------------------------
BBOD_WINDOW_SAVE PROC
                 ;---------------������� �� ������� �� OK---------------------
                 CMP FLAG_SAVE_OK,1
                 JNE NET_ES_SAVE_ENTER
                 JMP NEAR:ES_SAVE_ENTER
                 NET_ES_SAVE_ENTER:
                 ;---------------������� �� ������� �� ESC--------------------
                 CMP FLAG_SAVE_ESC,1
                 JE NET_NET_ESC_MOUSE
                 JMP NEAR:NET_ESC_MOUSE
                 NET_NET_ESC_MOUSE:
                 ;---------------��, ���� ����� ESC �����---------------------
                 JMP NEAR:EXIT_SAVE@                           ;������ �������
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
                 MOV FLAG_SAVE,0
                 JMP NEAR:EXIT_SAVE@                           ;������ �������
                 ;-----------------�������� �� ENTER--------------------------
                 NET_ESC:
                 CMP TEC_AL,13
                 JNE NET_NET_ES_SAVE_ENTER
                 JMP NEAR:ES_SAVE_ENTER
                 NET_NET_ES_SAVE_ENTER:
                 ;------------------------------------------------------------
                 ;-----------------���, ���� �� ������� ENTER-----------------
                 ;-----------------�������� �� BS-----------------------------
                 ;------------------------------------------------------------
                 CMP TEC_AL,8
                 JNE NET_BS_SAVE
                 ;----------------��, ���� ����� BS---------------------------
                 CMP SI_TEC,0
                 JNE NET_EXIT_SAVE              ;���� ������� ������, �� �����
                 JMP NEAR:EXIT_SAVE
                 NET_EXIT_SAVE:
                 ;------------------------------------------------------------
                 ;----------------���������� ��������-------------------------
                 ;----------------�������� ���� �������-----------------------
                 ;------------------------------------------------------------
                 MOV CX,SI_TEC
                 MOV DI,1322
                 CIKL_SAVE_TOCH:
                          MOV AL,46
                          MOV AH,120
                          MOV ES:[DI],AX
                          ADD DI,2
                          INC SI
                 LOOP CIKL_SAVE_TOCH
                 ;------------------------------------------------------------
                 DEC SI_TEC      ;��������� ����� �������� � ������ BUFER_SAVE
                 LEA SI,BUFER_SAVE
                 MOV AX,SI_TEC
                 ADD SI,AX
                 MOV AH,0
                 MOV [SI],AH        ;���������� �� ����� ����������� ������� 0
                 ;--------------���� ������ 0 ��������, �� �����--------------
                 CMP SI_TEC,0
                 JNE NET_NET_EXIT_SAVE
                 JMP NEAR:EXIT_SAVE
                 NET_NET_EXIT_SAVE:
                 ;----------------���������� ������ �� �����------------------
                 LEA SI,BUFER_SAVE
                 MOV CX,SI_TEC
                 MOV DI,1322                           ;�������� � �����������
                 CIKL_SAVE_BS:
                          MOV AL,[SI]
                          MOV AH,120
                          MOV ES:[DI],AX
                          ADD DI,2
                          INC SI
                 LOOP CIKL_SAVE_BS
                 JMP EXIT_SAVE        ;������� ����� ������ ���������� �������
                 ;------------------------------------------------------------
                 ;-------���� �� ������� BS, ���������� ����------------------
                 ;------------------------------------------------------------
                 NET_BS_SAVE:
                 CMP SI_TEC,KOL_SIMBOL_MENU
                 JL  NET_NET_EXIT_SAVE@;���� ������� ������ ������, �� �������
                 JMP NEAR:EXIT_SAVE
                 NET_NET_EXIT_SAVE@:
                 ;------------------------------------------------------------
                 LEA SI,BUFER_SAVE
                 MOV AX,SI_TEC
                 ADD SI,AX
                 MOV AH,TEC_AL
                 MOV [SI],AH        ;���������� ������ � ����� ����� ��� �����
                 INC SI_TEC
                 ;----------------���������� ������ �� �����------------------
                 LEA SI,BUFER_SAVE
                 MOV CX,SI_TEC
                 MOV DI,1322
                 CIKL_SAVE:
                          MOV AL,[SI]
                          MOV AH,120
                          MOV ES:[DI],AX
                          ADD DI,2
                          INC SI
                 LOOP CIKL_SAVE
                 JMP EXIT_SAVE                  ;�������, �� ������� ���� ����
                 ;------------------------------------------------------------
                 ;------------------------------------------------------------
                 ;------------------���� ����� ENTER--------------------------
                 ;------------------------------------------------------------
                 ;------------------------------------------------------------
                 ES_SAVE_ENTER:
                 ;------------------����� �� ����-----------------------------
                 MOV FLAG_SAVE_OK,0
                 MOV SI_TEC,0
                 ;--------------������� ���� � ��������� ���------------------
                 MOV AX,5B00H
                 MOV CX,0
                 LEA DX,BUFER_SAVE
                 INT 21H
                 PUSH AX                        ;��������� ������������� �����
                �;------------------------------------------------------------
                 ;--���������� ����� ���� �������, ����� � ���������� � ����--
                 ;------------------------------------------------------------
                 CALL PROCEDURE_MAS
                 LEA SI,BUFER
                 ADD SI,[DI+16]                             ;[DI+16]=���������
                 ;------------------------------------------------------------
                 MOV CX,CHISLO_BYTE
                 LEA DI,BUFER_SIMBOL_SAVE
                 CIKL_WRITE_DISK:
                             MOV AH,BYTE PTR [SI]
                             MOV BYTE PTR [DI],AH
                             INC SI
                             INC DI
                 LOOP CIKL_WRITE_DISK
                 ;----------����������, ������� ���������� � ���� ����--------
                 ;----������� � ����� ������� - �� ������� ������������-------
                 ;---------------����� ���������� � ����----------------------
                 CALL PROCEDURE_MAS
                 LEA SI,BUFER
                 ADD SI,[DI+16]                             ;[DI+16]=���������
                 MOV AH,BYTE PTR [SI]
                 CMP AH,20H
                 MOV FLAG,0
                 JNE NETP
                 MOV FLAG,1
                 NETP:
                 ADD SI,CHISLO_BYTE
                 DEC SI
                 MOV CX,CHISLO_BYTE
                 MOV C,CX
                 CIKL_PROBEL:
                           MOV AH,BYTE PTR [SI]
                           CMP AH,20H
                           JNE NET_SUB_CX
                           DEC SI
                           DEC C
                 LOOP CIKL_PROBEL
                 NET_SUB_CX:
                 MOV CX,C
                 CMP CX,0
                 JNE OK
                 ;------------------------------------------------------------
                 CMP FLAG,1
                 JNE OK
                 ;------------------------------------------------------------
                 ;-----------------��������� ����-----------------------------
                 POP AX
                 MOV BX,AX
                 MOV AX,3E00H
                 INT 21H
                 ;---------------------������� ����---------------------------
                 MOV AX,4100H
                 LEA DX,BUFER_SAVE
                 INT 21H
                 JMP EXIT_SAVE@
                 ;------------------------------------------------------------
                 OK:
                 POP AX                                   ;������������� �����
                 PUSH AX
                 MOV BX,AX
                 MOV AX,4000H                       
                 LEA DX,BUFER_SIMBOL_SAVE
                 INT 21H                                    ;���������� � ����
                 ;-----------------��������� ����-----------------------------
                 POP AX                                   ;������������� �����
                 MOV BX,AX
                 MOV AX,3E00H
                 INT 21H
                 ;----------------������� BUFER_SAVE--------------------------
                 MOV CX,KOL_SIMBOL_MENU
                 LEA SI,BUFER_SAVE
                 CIKL_DELETE_BUFER_SAVE:
                                        MOV AX,0
                                        MOV DS:[SI],AX
                                        INC SI
                 LOOP CIKL_DELETE_BUFER_SAVE
                 ;------------------------------------------------------------
                 ;----------------������� �� ���� SAVE------------------------
                 ;------------------------------------------------------------
                 EXIT_SAVE@:
                 ;----------------������� BUFER_SAVE--------------------------
                 MOV CX,KOL_SIMBOL_MENU
                 LEA SI,BUFER_SAVE
                 CIKL_DELETE_BUFER_SAVE_ESC:
                                        MOV AX,0
                                        MOV DS:[SI],AX
                                        INC SI
                 LOOP CIKL_DELETE_BUFER_SAVE_ESC
                 ;------------------����� �� ���� � �������-------------------
                 MOV SI_TEC,0
                 MOV FLAG_SAVE_ESC,0
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
                 ;--------
                 CMP CD,1
                 JL NET_USER
                 CALL USER
                 NET_USER:
                 MOV FLAG_SAVE,0                   ;������� �������� ���� SAVE
                 ;------------------------------------------------------------
                 ;------------����� �� ��������� SAVE-------------------------
                 ;------------------------------------------------------------
                 EXIT_SAVE:RET
BBOD_WINDOW_SAVE ENDP
;-----------------------------------------------------------------------------
END
