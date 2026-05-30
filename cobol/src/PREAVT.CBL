	identification division.
      * prepis avtorjev
        program-id.    preavt.
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

		if pesmi-stevilka = zero
			delete pesmi invalid key
				display "napaka-delete".

		if PESMI-PRIRED = 999999
				move 329 to PESMI-PRIRED
				display "999999"
		else 
			if PESMI-PRIRED = 99998
				move 328 to PESMI-PRIRED
				display "99998"
			else
				go prenesi.

      *		add 1 to citanih
      *		display "citanih " citanih
      *		move pesmi-opomba to opomba

		REWRITE PESMI-AREA INVALID KEY
				DISPLAY "NAPAKA REWRITE"
				GO ZAPRI.
		go prenesi.
        zapri.
                close pesmi
                stop run.

