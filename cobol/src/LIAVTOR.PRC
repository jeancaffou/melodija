      **************************************************
      * liavtor.prc (listanje)
      **************************************************
	spcavtor. 
		display line lin col 10 si040b.
	lis-abc-avtor. 
		move space to avtor-naziv 
			w-avtor-naziv si040b.
                move zero to avtor-ownkey w-avtor-ownkey.
	lis-abc-avtor0. 
		perform spcavtor
			varying lin from 7 by 1 until lin > 19.
		display g-okvlis40
		display line 6 col 11 li-avtor.
	lis-abc-avtor1. 
		if w-avtor-naziv not = space 
			move w-avtor-naziv to avtor-naziv
			move space to naziv. 
                start avtor key not < avtor-naziv invalid key
			perform lis-abc-avtor go lis-abc-avtor3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-abc-avtor2. 
		perform next-avtor
		if endp go lis-abc-avtor4.
                move space to si040b move 1 to pt
		move avtor-ownkey to z6v0
                string 
      *			" " z6v0
			" " avtor-naziv
			delimited by size into si040b with pointer pt.
                display line lin col 10 si040b
                add 1 to lin 
		move avtor-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-abc-avtor2.
		perform postavi-kurzorcek.
	lis-abc-avtor3.  
		display l-naziv
		accept l-naziv
                move naziv to w-avtor-naziv.
		if tp-esc or tp-nazaj go lis-abc-avtor.
                if tp-enter go lis-sex-avtor.
                if tp-lissif move zero to avtor-ownkey
					go lis-sif-avtor.
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
			GO LIS-ABC-avtor3.
                go lis-abc-avtor1.
	lis-abc-avtor4. 
		move space to si040b 
                perform spcavtor
			varying lin from lin by 1 until lin > 19.
                perform lis-abc-avtor
		perform postavi-kurzorcek
		go lis-abc-avtor3.
	lis-sif-avtor. 
                move zero to avtor-ownkey w-avtor-ownkey.
		move space to avtor-naziv si040b.
	lis-sif-avtor0. 
                perform lis-abc-avtor0.
	lis-sif-avtor1. 
		if w-avtor-ownkey > 0 
			move w-avtor-ownkey to avtor-ownkey
			move 0 to kljuc.
                start avtor key > avtor-ownkey invalid key
			perform lis-sif-avtor go lis-sif-avtor3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-sif-avtor2. 
		perform next-avtor
		if endp go lis-sif-avtor4.
	        move space to si040b move 1 to pt
		move avtor-ownkey to z6v0
                string " " z6v0 " " avtor-naziv
			delimited by size into si040b with pointer pt.
                display line lin col 10 si040b
                add 1 to lin
		move avtor-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-sif-avtor2.
		perform postavi-kurzorcek.
	lis-sif-avtor3.
		display l-kljuc.
		accept l-kljuc
                move kljuc to w-avtor-ownkey.
		if tp-esc or tp-nazaj go lis-sif-avtor.
                if tp-enter go lis-sex-avtor.
                if tp-lisabc move space to avtor-naziv
						go lis-abc-avtor.
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
			GO LIS-SIF-avtor3.
                go lis-sif-avtor1.
	lis-sif-avtor4.
		move space to si040b 
                perform spcavtor
			varying lin from lin by 1 until lin > 19.
                perform lis-sif-avtor 
		perform postavi-kurzorcek
		go lis-sif-avtor3.
	lis-sex-avtor. 
		exit.
