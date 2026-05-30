      **************************************************
      * lipesver.prc (listanje)
      **************************************************
	spcpesver. 
		display line lin col 10 si060b.
	lis-abc-pesver. 

      *		move w-pesmi-zbori to pesmi-zbori
      *		move w-pesmi-prired to pesmi-prired

		move space to pesmi-verz
			w-pesmi-verz si060b.
	lis-abc-pesver0. 
		perform spcpesver
			varying lin from 7 by 1 until lin > 19.
		display g-okvlis60

      *		move space to avtor-naziv
      *		move w-pesmi-prired to avtor-ownkey
      *		perform read-avtor

		move " Skladbe po za~etnem verzu " to li-pesver
		display line 6 col 11 li-pesver.
	lis-abc-pesver1. 
		if w-pesmi-verz not = space 
			move w-pesmi-verz to pesmi-verz
			move space to naziv. 
                start pesmi key not < pesmi-verz
			invalid key
			perform lis-abc-pesver go lis-abc-pesver3.
		if pesmi-verz = space
	                start pesmi key > pesmi-verz
			invalid key
			perform lis-abc-pesver go lis-abc-pesver3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-abc-pesver2. 
		perform next-pesmi
		if endp go lis-abc-pesver4.

      *		if pesmi-prired not = w-pesmi-prired
      *			go lis-abc-pesver4.
      *		if w-pesmi-zbori not = 0
      *			if pesmi-zbori not = w-pesmi-zbori
      *				go lis-abc-pesver2.

		if pesmi-verz = space go lis-abc-pesver2.

		move pesmi-zbori to zbori-ownkey
		perform read-zbori.

                move space to si060b move 1 to pt
		move pesmi-stevilka to z6v0
                string
			" " pesmi-verz
			" " pesmi-naziv(1:30)
			" " zbori-krnaz
			delimited by size into si060b with pointer pt.
                display line lin col 10 si060b
                add 1 to lin 
		move pesmi-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-abc-pesver2.
		perform postavi-kurzorcek.
	lis-abc-pesver3.  
		display l-naziv
		accept l-naziv
		move pesmi-verz to w-pesmi-verz
		if naziv not = space
	                move naziv to w-pesmi-verz.
      *		if tp-levo or tp-esc or tp-nazaj go lis-abc-pesver.
		if tp-esc or tp-nazaj go lis-abc-pesver.
                if tp-enter go lis-sex-pesver.
                if tp-lissif move zero to pesmi-ownkey
					go lis-abc-pesver.
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
			GO LIS-ABC-pesver3.
                go lis-abc-pesver1.
	lis-abc-pesver4. 
		move space to si060b 
                perform spcpesver
			varying lin from lin by 1 until lin > 19.
                perform lis-abc-pesver
		perform postavi-kurzorcek
		go lis-abc-pesver3.
	lis-sex-pesver. 
		exit.
