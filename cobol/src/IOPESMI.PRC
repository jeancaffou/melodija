      ************************************************
      * IOPESMI.PRC
      * Procedura za vse I-O operacije datoteke PESMI
      ************************************************
        IOPESMI SECTION.
      ************************************************
      *-----------------------------------------------
        NEXT-PESMI.
      *-----------------------------------------------
                READ PESMI NEXT RECORD
                MOVE S-PESMI TO DB-STAT.
                MOVE "PESMI" TO FAT-FILE
                MOVE "R-NEXT" TO FAT-FUN
                MOVE PESMI-OWNKEY TO FAT-KEY
                MOVE PESMI-AREA TO FAT-AREA
                IF HELD GO NEXT-PESMI.
                IF ENDP NEXT SENTENCE   ELSE
                IF NOT STARS
                        GO TO FATERR.
      *-----------------------------------------------
        DELETE-PESMI.
      *-----------------------------------------------
                DELETE PESMI
                MOVE S-PESMI TO DB-STAT.
                MOVE PESMI-OWNKEY TO FAT-KEY
                MOVE PESMI-AREA TO FAT-AREA
                MOVE "PESMI" TO FAT-FILE REC-FILE
                MOVE "DELETE" TO FAT-FUN  REC-FUN
                MOVE PESMI-AREA TO REC-ZAPIS
                IF HELD GO TO DELETE-PESMI.
                IF NOT STARS GO TO FATERR.
                PERFORM CLOSE-PESMI.
                PERFORM OPEN-PESMI.
      *-----------------------------------------------
        READ-PESMI.
      *-----------------------------------------------
                READ PESMI
                MOVE "PESMI" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE PESMI-OWNKEY TO FAT-KEY
                MOVE PESMI-AREA TO FAT-AREA
                MOVE S-PESMI TO DB-STAT
                IF HELD GO TO READ-PESMI.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        READ-PESMI-NAZIV.
      *-----------------------------------------------
                READ PESMI KEY IS PESMI-NAZIV
                MOVE "PESMI" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE PESMI-OWNKEY TO FAT-KEY
                MOVE PESMI-AREA TO FAT-AREA
                MOVE S-PESMI TO DB-STAT
                IF HELD GO TO READ-PESMI-NAZIV.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        READ-PESMI-ZBOR-NAZIV.
      *-----------------------------------------------
                READ PESMI KEY IS PESMI-ZBOR-NAZIV
                MOVE "PESMI" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE PESMI-OWNKEY TO FAT-KEY
                MOVE PESMI-AREA TO FAT-AREA
                MOVE S-PESMI TO DB-STAT
                IF HELD GO TO READ-PESMI-NAZIV.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        READ-PESMI-PRIRED-NAZIV.
      *-----------------------------------------------
                READ PESMI KEY IS PESMI-PRIRED-NAZIV
                MOVE "PESMI" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE PESMI-OWNKEY TO FAT-KEY
                MOVE PESMI-AREA TO FAT-AREA
                MOVE S-PESMI TO DB-STAT
                IF HELD GO TO READ-PESMI-PRIRED-NAZIV.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        UPD-PESMI.
      *-----------------------------------------------
                WRITE PESMI-AREA
                MOVE S-PESMI TO DB-STAT
                IF HELD GO TO UPD-PESMI.
                IF DUPM REWRITE PESMI-AREA
                        MOVE S-PESMI TO DB-STAT.
                MOVE "PESMI" TO FAT-FILE REC-FILE
                MOVE "UPDATE" TO FAT-FUN  REC-FUN
                MOVE PESMI-AREA TO REC-ZAPIS
                MOVE PESMI-OWNKEY TO FAT-KEY
                MOVE PESMI-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
                PERFORM CLOSE-PESMI.
                PERFORM OPEN-PESMI.
      *-----------------------------------------------
        OPEN-PESMI.
      *-----------------------------------------------
                OPEN I-O PESMI
                MOVE S-PESMI TO DB-STAT
                MOVE "PESMI" TO FAT-FILE
                MOVE "OPEN  " TO FAT-FUN
                MOVE PESMI-OWNKEY TO FAT-KEY
                MOVE PESMI-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
                MOVE "23" TO DB-STAT S-PESMI.
      *-----------------------------------------------
        CLOSE-PESMI.
      *-----------------------------------------------
                CLOSE PESMI
                MOVE S-PESMI TO DB-STAT
                MOVE "PESMI" TO FAT-FILE
                MOVE "CLOSE " TO FAT-FUN
                MOVE PESMI-OWNKEY TO FAT-KEY
                MOVE PESMI-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
      *-----------------------------------------------
      ************************************************
      * KONEC PROCEDURE    IOPESMI.PRC
      ************************************************
        IOPESMI-EXIT.
                EXIT.
      ************************************************
