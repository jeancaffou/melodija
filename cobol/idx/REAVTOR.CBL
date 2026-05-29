        identification division.
      * rebuild zadeva
        program-id.    reavtor.
        author.        cene.
        environment division.
        configuration section.
        special-names.
                printer is konzola
                decimal-point is comma.
       input-output section.
       file-control.
                select ravtor assign to disk
			organization sequential
			access sequential.
	        copy avtor.sel.
        data division.
        file section.
	fd ravtor label record standard
		recording mode is variable
		value of file-id "\dusan\reb\avtor.seq".
	01 ravtor-area pic x(64).
		copy avtor.lib.
        working-storage section.
	01	prg-nasl	pic x(40) value 
		"R E B U I L D   컴컴컴컴컴컴컴컴컴컴컴컴".
	01	oddelek pic x(8) value "SKLAD".
	01	prg-naz	pic x(6) value "avtor".
	copy dusan.lib.
        procedure division.
        odpri.
		move 23 to vrstica move 0 to kolona
		call x"E6" using stat vrstica-kolona
		move "copy \dusan\idx\avtor.ind \dusan\reb\*.seq"
			to par1
		display par1 upon command-line
		call x"91" using Stat Funk Param.

		move "avtor" to ws-datoteka
		display g-rebild
		display a-datoteka
		open input ravtor
                open output avtor.
		move 0 to ws-citanih.
        prenesi.
                read ravtor at end go zapri.
		add 1 to ws-citanih
		display a-citanih
		move ravtor-area to avtor-area
                write avtor-area
                        invalid key display "napaka-write" go zapri.
		go prenesi.
        zapri.
                close ravtor
                close avtor
                goback.
