      **************************************************
      * lipesmi.prc (listanje)
      **************************************************
	spcpesmi. 
		display line lin col 10 si060b.
	lis-abc-pesmi. 
		move space to pesmi-naziv 
			w-pesmi-naziv si060b.
      *                move zero to pesmi-ownkey w-pesmi-ownkey.
	lis-abc-pesmi0. 
		perform spcpesmi
			varying lin from 7 by 1 until lin > 19.
		display g-okvlis60
		move " Skladba - zbor : VSI" to li-pesmi
		if not w-pesmi-zbori = zero
			move pesmi-zbori to zbori-ownkey
			perform read-zbori
			string " Skladba - zbor : " ZBORI-NAZIV
				delimited by size into li-pesmi.
		display line 6 col 11 li-pesmi.
	lis-abc-pesmi1. 
		if w-pesmi-naziv not = space 
			move w-pesmi-naziv to pesmi-naziv
			move space to naziv. 
                start pesmi key not < pesmi-naziv invalid key
			perform lis-abc-pesmi go lis-abc-pesmi3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-abc-pesmi2. 
		perform next-pesmi
		if endp go lis-abc-pesmi4.
		if not w-pesmi-zbori = zero
			if pesmi-zbori not = w-pesmi-zbori
				go lis-abc-pesmi2.
		move pesmi-prired to avtor-ownkey
		perform read-avtor
		move avtor-naziv to prired-naziv
                move space to si060b move 1 to pt
		move pesmi-stevilka to z6v0
                string	" " pesmi-naziv(1:35)
      *			" " z6v0
      *			" " pesmi-zbori
			" " prired-naziv
			delimited by size into si060b with pointer pt.
                display line lin col 10 si060b
                add 1 to lin 
		move pesmi-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-abc-pesmi2.
		perform postavi-kurzorcek.
	lis-abc-pesmi3.  
		display l-naziv
		accept l-naziv
		move pesmi-naziv to w-pesmi-naziv
		if naziv not = space
	                move naziv to w-pesmi-naziv.
      *		if tp-levo or tp-esc or tp-nazaj go lis-abc-pesmi.
		if tp-esc or tp-nazaj go lis-abc-pesmi.
                if tp-enter go lis-sex-pesmi.
                if tp-lissif move zero to pesmi-ownkey
					go lis-sif-pesmi.
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
			GO LIS-ABC-pesmi3.
                go lis-abc-pesmi1.
	lis-abc-pesmi4. 
		move space to si060b 
                perform spcpesmi
			varying lin from lin by 1 until lin > 19.
                perform lis-abc-pesmi
		perform postavi-kurzorcek
		go lis-abc-pesmi3.
	lis-sif-pesmi. 
                move zero to pesmi-ownkey
      * w-pesmi-ownkey.
		move w-pesmi-zbori to pesmi-zbori.
		move space to pesmi-naziv si060b.
	lis-sif-pesmi0. 
                perform lis-abc-pesmi0.
	lis-sif-pesmi1. 
		if w-pesmi-ownkey > 0 
			move w-pesmi-ownkey to pesmi-ownkey
			move 0 to kljuc.
                start pesmi key not < pesmi-ownkey invalid key
			perform lis-sif-pesmi go lis-sif-pesmi3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-sif-pesmi2. 
		perform next-pesmi
		if endp go lis-sif-pesmi4.
		if not w-pesmi-zbori = zero
			if pesmi-zbori not = w-pesmi-zbori
				go lis-sif-pesmi2.
		move pesmi-prired to avtor-ownkey
		perform read-avtor
		move avtor-naziv to prired-naziv
	        move space to si060b move 1 to pt
		move pesmi-zbori to z2v0
		move pesmi-stevilka to z5v0
                string
			" " z2v0
			" " z5v0
			" " pesmi-naziv(1:30)
      *			" " pesmi-zbori
			" " prired-naziv
			delimited by size into si060b with pointer pt.
                display line lin col 10 si060b
                add 1 to lin
		move pesmi-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-sif-pesmi2.
		perform postavi-kurzorcek.
	lis-sif-pesmi3.
		display l-kljuc.
		accept l-kljuc
		move pesmi-ownkey to w-pesmi-ownkey
		if kljuc not = zero
	                move kljuc to w-pesmi-ownkey.
      *		if tp-levo or tp-esc or tp-nazaj go lis-sif-pesmi.
		if tp-esc or tp-nazaj go lis-abc-pesmi.
                if tp-enter go lis-sex-pesmi.
                if tp-lisabc move space to pesmi-naziv
						go lis-abc-pesmi.
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
			GO LIS-SIF-pesmi3.
                go lis-sif-pesmi1.
	lis-sif-pesmi4.
		move space to si060b 
                perform spcpesmi
			varying lin from lin by 1 until lin > 19.
                perform lis-sif-pesmi 
		perform postavi-kurzorcek
		go lis-sif-pesmi3.
	lis-sex-pesmi. 
		exit.
