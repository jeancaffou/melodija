      *------------------------------------------------------
      * Procedura za brisanje okvirja
      *------------------------------------------------------
       OKVEMP SECTION.
       ZACNIEMP.
                MOVE OKVEMP-LIN TO LIN.
                PERFORM BRISI VARYING OKVEMP-LIN FROM LIN
                              BY 1 UNTIL OKVEMP-LIN > OKVEMP-VIS.
                GO TO OKVEMP-EXIT.
       BRISI.
                DISPLAY L-WS-OKVEMP.
       OKVEMP-EXIT.
                 EXIT.
