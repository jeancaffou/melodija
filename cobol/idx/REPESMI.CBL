
        identification division.
      * rebuild zadeva
        program-id.    repesmi.
        author.        cene.
        environment division.
        configuration section.
        special-names.
                printer is konzola
                decimal-point is comma.
       input-output section.
       file-control.
                select rpesmi assign to disk
			organization sequential
			access sequential.
	        copy pesmi.sel.
        data division.
        file section.
	fd rpesmi label record standard
		recording mode is variable
		value of file-id "\dusan\reb\pesmi.seq".
	01 rpesmi-area pic x(128).
		copy pesmi.lib.
        working-storage section.
	01	prg-nasl	pic x(40) value 
		"R E B U I L D   컴컴컴컴컴컴컴컴컴컴컴컴".
	01	oddelek pic x(8) value "SKLAD".
	01	prg-naz	pic x(6) value "pesmi".
	copy dusan.lib.
        procedure division.
        odpri.
		move 23 to vrstica move 0 to kolona
		call x"E6" using stat vrstica-kolona
		move "copy \dusan\idx\pesmi.ind \dusan\reb\*.seq"
			to par1
		display par1 upon command-line
		call x"91" using Stat Funk Param.

		move "pesmi" to ws-datoteka
		display g-rebild
		display a-datoteka
		open input rpesmi
                open output pesmi.
		move 0 to ws-citanih.
        prenesi.
                read rpesmi at end go zapri.
		add 1 to ws-citanih
		display a-citanih
		move rpesmi-area to pesmi-area
                write pesmi-area
                        invalid key display "napaka-write" go zapri.
		go prenesi.
        zapri.
                close rpesmi
                close pesmi
                goback.
