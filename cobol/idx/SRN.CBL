        identification division.
      * prepis .srn v .txt
        program-id.    ekrancek.
        author.        cene.
        environment division.
        configuration section.
        special-names.
                printer is konzola
                decimal-point is comma.
       input-output section.
       file-control.
                select ime-srn assign to disk
                        organization line sequential
                        access sequential.
                select ime-txt assign to disk
                        organization line sequential
                        access sequential.
        data division.
        file section.
        fd ime-srn label record standard
                recording mode is variable
                value of file-id a-srn.
        01 srn-area pic x(512).
        fd ime-txt label record standard
                recording mode is variable
                value of file-id a-txt.
        01 txt-area pic x(80).
        working-storage section.
        01 a-srn.
                03      a1-srn  pic x(6).
                03      fill    pic x(4) value ".srn".
        01 a-txt.
                03      fill    pic x(7) value "..\txt\".
                03      a1-txt  pic x(6).
                03      fill    pic x(4) value ".txt".
        01      stevc   pic 9(6).
        01      progrm  pic x(30).
        procedure division.
        odpri.
                display "ime slike : "
                accept  a1-srn
                if a1-srn = space go konec-programa.
                move a1-srn to a1-txt
                open input ime-srn
                open output ime-txt
                move zero to stevc.

        zanka.
                read ime-srn at end
                        close ime-srn ime-txt
                        go odpri.

                if not srn-area = space
                        if stevc = zero
                                go zanka.
                add 1 to stevc
                move srn-area to txt-area
                inspect txt-area replacing all "^" by "_"
                write txt-area
                go zanka.
        konec-programa.
                goback.
