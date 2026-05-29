      **************************************************
      * lipesosn.prc (listanje)
      **************************************************
	spcpesosn. 
		display line lin col 10 si060b.
	lis-abc-pesosn. 
		move w-pesmi-zbori to pesmi-zbori
		move w-pesmi-osnova to pesmi-osnova
		move space to pesmi-naziv 
			w-pesmi-naziv si060b.
	lis-abc-pesosn0. 
		perform spcpesosn
			varying lin from 7 by 1 until lin > 19.
		display g-okvlis60
		move space to avtor-naziv
		move w-pesmi-osnova to avtor-ownkey
		perform read-avtor
		move space to li-pesosn
		string "Avtor skladbe ( pesmi )  " avtor-naziv
			delimited by size into li-pesosn
		display line 6 col 11 li-pesosn.
	lis-abc-pesosn1. 
		if w-pesmi-naziv not = space 
			move w-pesmi-naziv to pesmi-naziv
			move space to naziv. 
                start pesmi key not < pesmi-osnova-zbori-naziv
			invalid key
			perform lis-abc-pesosn go lis-abc-pesosn3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-abc-pesosn2. 
		perform next-pesmi
		if endp go lis-abc-pesosn4.
		if pesmi-osnova not = w-pesmi-osnova
			go lis-abc-pesosn4.
		if w-pesmi-zbori not = 0
			if pesmi-zbori not = w-pesmi-zbori
				go lis-abc-pesosn2.

		move pesmi-zbori to zbori-ownkey
		perform read-zbori.

                move space to si060b move 1 to pt
		move pesmi-stevilka to z6v0
                string	" " pesmi-naziv(1:35)
			" " zbori-krnaz
			delimited by size into si060b with pointer pt.
                display line lin col 10 si060b
                add 1 to lin 
		move pesmi-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-abc-pesosn2.
		perform postavi-kurzorcek.
	lis-abc-pesosn3.  
		display l-naziv
		accept l-naziv
		move pesmi-naziv to w-pesmi-naziv
		if naziv not = space
	                move naziv to w-pesmi-naziv.
      *		if tp-levo or tp-esc or tp-nazaj go lis-abc-pesosn.
		if tp-esc or tp-nazaj go lis-abc-pesosn.
                if tp-enter go lis-sex-pesosn.
                if tp-lissif move zero to pesmi-ownkey
					go lis-abc-pesosn.
		IF TP-GOR
			DISPLAY LINE DIS-LINE COL 10 DIS-SPACE
			SUBTRACT 1 FROM DIS-I
			IF DIS-I < 1
				MOVE 12 TO DIS-I.
		IF TP-DOL
			DISPLAY LINE DIS-LINE COL 10 DIS-SPACE
			ADD 1 TO DIS-I
			IF DIS-I > 12
				MOVE 1 TO DIS-I.
		IF TP-GOR OR TP-DOL
			COMPUTE DIS-LINE = DIS-I + 7
			DISPLAY LINE DIS-LINE COL 10 DIS-ZNAK
			GO LIS-ABC-pesosn3.
                go lis-abc-pesosn1.
	lis-abc-pesosn4. 
		move space to si060b 
                perform spcpesosn
			varying lin from lin by 1 until lin > 19.
                perform lis-abc-pesosn
		perform postavi-kurzorcek
		go lis-abc-pesosn3.
	lis-sex-pesosn. 
		exit.
