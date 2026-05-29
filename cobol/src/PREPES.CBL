	identification division.
      * rebuild pesmi
        program-id.    prepes.
        author.        cene.
        environment division.
        configuration section.
        special-names.
                printer is konzola
                decimal-point is comma.
	input-output section.
	file-control.
		copy pesmi.sel.
        data division.
        file section.
		copy pesmi.lib.
        working-storage section.
	01 progrm	pic x(30).
	01 nasl		pic x(30).
	01	citanih	pic 9(6).
	01	opomba pic x(30).
	01	opomba-r1 redefines opomba.
		03 opomba-7	pic x(7).
		03 ostanek-1	pic x(23).
	01	opomba-r2 redefines opomba.
		03 opomba-4	pic x(4).
		03 ostanek-2	pic x(26).
	01	opomba-r3 redefines opomba.
		03 opomba-6	pic x(6).
		03 ostanek-3	pic x(24).
	01	opomba-r4 redefines opomba.
		03 opomba-9.
			05	opomba1	pic x(1).
			05	opomba2 pic x(8).
		03 ostanek-4	pic x(21).
	01	opomba-r5 redefines opomba.
		03 opomba-otr	pic x(6).
		03 ostanek-otr	pic x(24).
	copy lhspom.lib.
	copy lhsekr.scr.
        procedure division.
        odpri.
                open i-o pesmi.
		move zero to pesmi-ownkey
		start pesmi key not < pesmi-ownkey invalid key
			display "napaka-start"
			go zapri.
        prenesi.
                READ PESMI NEXT RECORD
			AT END GO ZAPRI.

      *		if pesmi-zbori = 4 go prenesi.

		add 1 to citanih
		display "citanih " citanih
		move pesmi-opomba to opomba

      *		if opomba-7 = "ZA MLPZ"
      *			delete pesmi
      *			move 4 to pesmi-zbori
      *			move ostanek-1 to pesmi-opomba
      *			WRITE PESMI-AREA
      *			go prenesi.

      *		if opomba-4 = "MLPZ"
      *			delete pesmi
      *			move 4 to pesmi-zbori
      *			move ostanek-2 to pesmi-opomba
      *			WRITE PESMI-AREA
      *			go prenesi.

      *		if opomba-6 = "GRLICA"
      *			delete pesmi
      *			move 4 to pesmi-zbori
      *			WRITE PESMI-AREA
      *			go prenesi.

      *		if 	opomba-9 = "MLADINSKI" or
      *			opomba-9 = "LEPO JE V"
      *				delete pesmi
      *				move 4 to pesmi-zbori
      *				WRITE PESMI-AREA
      *				go prenesi.

      *		if	opomba-9 = "0tro{ki i"
      *				delete pesmi
      *				move 4 to pesmi-zbori
      *				move "O" to opomba1
      *				move opomba-r4 to pesmi-opomba
      *				WRITE PESMI-AREA
      *				go prenesi.

      *		if	opomba-9 = "Pesmi za "
      *				delete pesmi
      *				move 4 to pesmi-zbori
      *				WRITE PESMI-AREA
      *				go prenesi.

		if	opomba-otr = "ZA OPZ"
				delete pesmi
				move 5 to pesmi-zbori
				WRITE PESMI-AREA
				go prenesi.

		go prenesi.
        zapri.
                close pesmi
                stop run.

