      ************************************************
      * IOZBIRKA.PRC
      * Procedura za vse I-O operacije datoteke ZBIRKA
      ************************************************
        IOZBIRKA SECTION.
      ************************************************
      *-----------------------------------------------
        NEXT-ZBIRKA.
      *-----------------------------------------------
                READ ZBIRKA NEXT RECORD
                MOVE S-ZBIRKA TO DB-STAT.
                MOVE "ZBIRKA" TO FAT-FILE
                MOVE "R-NEXT" TO FAT-FUN
                MOVE ZBIRKA-OWNKEY TO FAT-KEY
                MOVE ZBIRKA-AREA TO FAT-AREA
                IF HELD GO NEXT-ZBIRKA.
                IF ENDP NEXT SENTENCE   ELSE
                IF NOT STARS
                        GO TO FATERR.
      *-----------------------------------------------
        DELETE-ZBIRKA.
      *-----------------------------------------------
                DELETE ZBIRKA
                MOVE S-ZBIRKA TO DB-STAT.
                MOVE ZBIRKA-OWNKEY TO FAT-KEY
                MOVE ZBIRKA-AREA TO FAT-AREA
                MOVE "ZBIRKA" TO FAT-FILE REC-FILE
                MOVE "DELETE" TO FAT-FUN  REC-FUN
                MOVE ZBIRKA-AREA TO REC-ZAPIS
                IF HELD GO TO DELETE-ZBIRKA.
                IF NOT STARS GO TO FATERR.
		PERFORM CLOSE-ZBIRKA.
		PERFORM OPEN-ZBIRKA.
      *-----------------------------------------------
        READ-ZBIRKA.
      *-----------------------------------------------
                READ ZBIRKA
                MOVE "ZBIRKA" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE ZBIRKA-OWNKEY TO FAT-KEY
                MOVE ZBIRKA-AREA TO FAT-AREA
                MOVE S-ZBIRKA TO DB-STAT
                IF HELD GO TO READ-ZBIRKA.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        READ-ZBIRKA-NAZIV.
      *-----------------------------------------------
                READ ZBIRKA KEY IS ZBIRKA-NAZIV
                MOVE "ZBIRKA" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE ZBIRKA-OWNKEY TO FAT-KEY
                MOVE ZBIRKA-AREA TO FAT-AREA
                MOVE S-ZBIRKA TO DB-STAT
                IF HELD GO TO READ-ZBIRKA-NAZIV.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        UPD-ZBIRKA.
      *-----------------------------------------------
                WRITE ZBIRKA-AREA
                MOVE S-ZBIRKA TO DB-STAT
                IF HELD GO TO UPD-ZBIRKA.
                IF DUPM REWRITE ZBIRKA-AREA
                        MOVE S-ZBIRKA TO DB-STAT.
                MOVE "ZBIRKA" TO FAT-FILE REC-FILE
                MOVE "UPDATE" TO FAT-FUN  REC-FUN
                MOVE ZBIRKA-AREA TO REC-ZAPIS
                MOVE ZBIRKA-OWNKEY TO FAT-KEY
                MOVE ZBIRKA-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
		PERFORM CLOSE-ZBIRKA.
		PERFORM OPEN-ZBIRKA.
      *-----------------------------------------------
        OPEN-ZBIRKA.
      *-----------------------------------------------
                OPEN I-O ZBIRKA
                MOVE S-ZBIRKA TO DB-STAT
                MOVE "ZBIRKA" TO FAT-FILE
                MOVE "OPEN  " TO FAT-FUN
                MOVE ZBIRKA-OWNKEY TO FAT-KEY
                MOVE ZBIRKA-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
                MOVE "23" TO DB-STAT S-ZBIRKA.
      *-----------------------------------------------
        CLOSE-ZBIRKA.
      *-----------------------------------------------
                CLOSE ZBIRKA
                MOVE S-ZBIRKA TO DB-STAT
                MOVE "ZBIRKA" TO FAT-FILE
                MOVE "CLOSE " TO FAT-FUN
                MOVE ZBIRKA-OWNKEY TO FAT-KEY
                MOVE ZBIRKA-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
      *-----------------------------------------------
      ************************************************
      * KONEC PROCEDURE    IOZBIRKA.PRC
      ************************************************
        IOZBIRKA-EXIT.
                EXIT.
      ************************************************
