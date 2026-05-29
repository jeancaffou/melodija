      ************************************************
      * IOAVTOR.PRC
      * Procedura za vse I-O operacije datoteke AVTOR
      ************************************************
        IOAVTOR SECTION.
      ************************************************
      *-----------------------------------------------
        NEXT-AVTOR.
      *-----------------------------------------------
                READ AVTOR NEXT RECORD
                MOVE S-AVTOR TO DB-STAT.
                MOVE "AVTOR" TO FAT-FILE
                MOVE "R-NEXT" TO FAT-FUN
                MOVE AVTOR-OWNKEY TO FAT-KEY
                MOVE AVTOR-AREA TO FAT-AREA
                IF HELD GO NEXT-AVTOR.
                IF ENDP NEXT SENTENCE   ELSE
                IF NOT STARS
                        GO TO FATERR.
      *-----------------------------------------------
        DELETE-AVTOR.
      *-----------------------------------------------
                DELETE AVTOR
                MOVE S-AVTOR TO DB-STAT.
                MOVE AVTOR-OWNKEY TO FAT-KEY
                MOVE AVTOR-AREA TO FAT-AREA
                MOVE "AVTOR" TO FAT-FILE REC-FILE
                MOVE "DELETE" TO FAT-FUN  REC-FUN
                MOVE AVTOR-AREA TO REC-ZAPIS
                IF HELD GO TO DELETE-AVTOR.
                IF NOT STARS GO TO FATERR.
		PERFORM CLOSE-AVTOR.
		PERFORM OPEN-AVTOR.
      *-----------------------------------------------
        READ-AVTOR.
      *-----------------------------------------------
                READ AVTOR
                MOVE "AVTOR" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE AVTOR-OWNKEY TO FAT-KEY
                MOVE AVTOR-AREA TO FAT-AREA
                MOVE S-AVTOR TO DB-STAT
                IF HELD GO TO READ-AVTOR.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        READ-AVTOR-NAZIV.
      *-----------------------------------------------
                READ AVTOR KEY IS AVTOR-NAZIV
                MOVE "AVTOR" TO FAT-FILE
                MOVE "READ-D" TO FAT-FUN
                MOVE AVTOR-OWNKEY TO FAT-KEY
                MOVE AVTOR-AREA TO FAT-AREA
                MOVE S-AVTOR TO DB-STAT
                IF HELD GO TO READ-AVTOR-NAZIV.
                IF MRNF NEXT SENTENCE ELSE
                IF NOT STARS GO FATERR.
      *-----------------------------------------------
        UPD-AVTOR.
      *-----------------------------------------------
                WRITE AVTOR-AREA
                MOVE S-AVTOR TO DB-STAT
                IF HELD GO TO UPD-AVTOR.
                IF DUPM REWRITE AVTOR-AREA
                        MOVE S-AVTOR TO DB-STAT.
                MOVE "AVTOR" TO FAT-FILE REC-FILE
                MOVE "UPDATE" TO FAT-FUN  REC-FUN
                MOVE AVTOR-AREA TO REC-ZAPIS
                MOVE AVTOR-OWNKEY TO FAT-KEY
                MOVE AVTOR-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
		PERFORM CLOSE-AVTOR.
		PERFORM OPEN-AVTOR.
      *-----------------------------------------------
        OPEN-AVTOR.
      *-----------------------------------------------
                OPEN I-O AVTOR
                MOVE S-AVTOR TO DB-STAT
                MOVE "AVTOR" TO FAT-FILE
                MOVE "OPEN  " TO FAT-FUN
                MOVE AVTOR-OWNKEY TO FAT-KEY
                MOVE AVTOR-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
                MOVE "23" TO DB-STAT S-AVTOR.
      *-----------------------------------------------
        CLOSE-AVTOR.
      *-----------------------------------------------
                CLOSE AVTOR
                MOVE S-AVTOR TO DB-STAT
                MOVE "AVTOR" TO FAT-FILE
                MOVE "CLOSE " TO FAT-FUN
                MOVE AVTOR-OWNKEY TO FAT-KEY
                MOVE AVTOR-AREA TO FAT-AREA
                IF NOT STARS GO TO FATERR.
      *-----------------------------------------------
      ************************************************
      * KONEC PROCEDURE    IOAVTOR.PRC
      ************************************************
        IOAVTOR-EXIT.
                EXIT.
      ************************************************
