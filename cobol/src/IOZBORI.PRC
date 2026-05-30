      ************************************************
      * IOZBORI.PRC
      * Procedura za vse I-O operacije datoteke ZBORI
      ************************************************
        IOZBORI SECTION.
      ************************************************
      *-----------------------------------------------
        NEXT-ZBORI.
      *-----------------------------------------------
                READ ZBORI NEXT RECORD
                MOVE S-ZBORI TO DB-STAT.
                MOVE "ZBORI" TO FAT-FILE
                MOVE "R-NEXT" TO FAT-FUN
                MOVE ZBORI-OWNKEY TO FAT-KEY
                MOVE ZBORI-AREA TO FAT-AREA
                IF HELD GO NEXT-ZBORI.
                IF ENDP NEXT SENTENCE   ELSE
                IF NOT STARS
                        GO TO FATERR.
      *-----------------------------------------------
        DELETE-ZBORI.
      *-----------------------------------------------
                DELETE ZBORI
                MOVE S-ZBORI TO DB-STAT.
                MOVE ZBORI-OWNKEY TO FAT-KEY
                MOVE ZBORI-AREA TO FAT-AREA
                MOVE "ZBORI" TO FAT-FILE REC-FILE
                MOVE "DELETE" TO FAT-FUN  REC-FUN
                MOVE ZBORI-AREA TO REC-ZAPIS
                IF HELD GO TO DELETE-ZBORI.
                IF NOT STARS GO TO FATERR.
		PERFORM CLOSE-ZBORI.
		PERFORM OPEN-ZBORI.
      *-----------------------------------------------
        READ-ZBORI.
      *-----------------------------------------------
                READ ZBORI
                MOVE "ZBORI" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE ZBORI-OWNKEY TO FAT-KEY
                MOVE ZBORI-AREA TO FAT-AREA
                MOVE S-ZBORI TO DB-STAT
                IF HELD GO TO READ-ZBORI.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        READ-ZBORI-NAZIV.
      *-----------------------------------------------
                READ ZBORI KEY IS ZBORI-NAZIV
                MOVE "ZBORI" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE ZBORI-OWNKEY TO FAT-KEY
                MOVE ZBORI-AREA TO FAT-AREA
                MOVE S-ZBORI TO DB-STAT
                IF HELD GO TO READ-ZBORI-NAZIV.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        UPD-ZBORI.
      *-----------------------------------------------
                WRITE ZBORI-AREA
                MOVE S-ZBORI TO DB-STAT
                IF HELD GO TO UPD-ZBORI.
                IF DUPM REWRITE ZBORI-AREA
                        MOVE S-ZBORI TO DB-STAT.
                MOVE "ZBORI" TO FAT-FILE REC-FILE
                MOVE "UPDATE" TO FAT-FUN  REC-FUN
                MOVE ZBORI-AREA TO REC-ZAPIS
                MOVE ZBORI-OWNKEY TO FAT-KEY
                MOVE ZBORI-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
		PERFORM CLOSE-ZBORI.
		PERFORM OPEN-ZBORI.
      *-----------------------------------------------
        OPEN-ZBORI.
      *-----------------------------------------------
                OPEN I-O ZBORI
                MOVE S-ZBORI TO DB-STAT
                MOVE "ZBORI" TO FAT-FILE
                MOVE "OPEN  " TO FAT-FUN
                MOVE ZBORI-OWNKEY TO FAT-KEY
                MOVE ZBORI-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
                MOVE "23" TO DB-STAT S-ZBORI.
      *-----------------------------------------------
        CLOSE-ZBORI.
      *-----------------------------------------------
                CLOSE ZBORI
                MOVE S-ZBORI TO DB-STAT
                MOVE "ZBORI" TO FAT-FILE
                MOVE "CLOSE " TO FAT-FUN
                MOVE ZBORI-OWNKEY TO FAT-KEY
                MOVE ZBORI-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
      *-----------------------------------------------
      ************************************************
      * KONEC PROCEDURE    IOZBORI.PRC
      ************************************************
        IOZBORI-EXIT.
                EXIT.
      ************************************************
