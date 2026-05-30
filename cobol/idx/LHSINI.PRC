      *--------------------------------------------------
      *  STANDARDNA STARTNA PROCEDURA      LHSINI.PRC
      *--------------------------------------------------
        PROCEDURE DIVISION.
        ZACETNA-SECTION.
        ZACNI.
                call keyboard-function using set-key-table-func
                           function-key-table.
                ACCEPT CAS FROM TIME
                MOVE CAS TO L-CAS.
                ACCEPT DATUM FROM DATE
                MOVE DATUM TO L-DATUM REC-DATUM obrnjen-datum
                string let "/" mes "/" dan
				delimited by size into l1-datum
                MOVE SPACES TO LLOGIN.
                MOVE PROGRM TO REC-PROGRM.
                PERFORM ODPRI-FILES
                DISPLAY GLAVA-SCREEN.
                IF E-D-N = 1
                        PERFORM PRAZNI
                        PERFORM HELPSCR
                ELSE
                        PERFORM EKRAN
                        PERFORM PRAZNI
                        PERFORM PISI.
                GO TO INDIVIDUALNO-DELO.
        FATERB.
                ACCEPT FAT-DATE FROM DATE
                ACCEPT FAT-TIME FROM TIME
                MOVE DB-STAT TO FAT-DB-STAT
                MOVE PROGRM TO FAT-PROGRM
                DISPLAY FATERB-VRSTA-1 LINE 23 COL 1
                DISPLAY FATERB-VRSTA-2 LINE 24 COL 1
                stop run.
        HELPSCR.
                MOVE 0604103822 TO OKVEMP-LCSV
                PERFORM OKVEMP
                MOVE 0604115036 TO OKVIR-LCVD
                CALL "OKVIR" USING OKVIR-LCVD
                DISPLAY HELP-SCREEN
                DISPLAY L-KARKOLI
                ACCEPT L-KARKOLI
                MOVE SPACE TO ICH WS-PUTERR
                DISPLAY L-PUTERR
                PERFORM EKRAN
                PERFORM PISI.
        HELPSCR-0.
                MOVE 0604103822 TO OKVEMP-LCSV
                PERFORM OKVEMP
                MOVE 0604115036 TO OKVIR-LCVD
                CALL "OKVIR" USING OKVIR-LCVD
                DISPLAY HELP-SCREEN
                DISPLAY L-KARKOLI
                ACCEPT L-KARKOLI
                MOVE SPACE TO ICH WS-PUTERR
                DISPLAY L-PUTERR.
        PUTERR.
           DISPLAY L-PUTERR
           DISPLAY DICH
           ACCEPT DICH
           IF RV-ESC MOVE "N" TO ICH.
      *           IF RV-HELP
      *                CHAIN KOMANDA USING POGLAVJE
      *                STOP RUN.
           IF RV-POTRDITEV MOVE "D" TO ICH.
           IF ICH = "D" OR "d" MOVE 1 TO TERMINATOR.
           IF ICH = "N" OR "n" MOVE 4 TO TERMINATOR.
           MOVE SPACE TO ICH WS-PUTERR WS-POTRDI
           DISPLAY L-PUTERR.
        POTRDI.
           DISPLAY L-POTRDI
           DISPLAY DICH
           ACCEPT DICH
           IF RV-ESC MOVE "N" TO ICH.
           IF RV-POTRDITEV MOVE "D" TO ICH.
           IF ICH = "D" OR "d" MOVE 1 TO TERMINATOR.
           IF ICH = "N" OR "n" MOVE 4 TO TERMINATOR.
           MOVE SPACE TO ICH WS-PUTERR WS-POTRDI
           DISPLAY L-PUTERR.
        POTRDI-BRIS.
           DISPLAY L-BRISI
           DISPLAY DICH
           ACCEPT DICH
           IF RV-ESC MOVE "N" TO ICH.
           IF RV-POTRDITEV MOVE "D" TO ICH.
           IF ICH = "D" OR "d" MOVE 1 TO TERMINATOR.
           IF ICH = "N" OR "n" MOVE 4 TO TERMINATOR.
           MOVE SPACE TO ICH WS-PUTERR WS-POTRDI
           DISPLAY L-PUTERR.
      *--------------------------------------------------
