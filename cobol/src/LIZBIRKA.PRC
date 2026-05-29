      **************************************************
      * lizbirka.prc (listanje)
      **************************************************
	spczbirka. 
		display line lin col 10 si040b.
	lis-abc-zbirka. 
		move space to zbirka-naziv 
			w-zbirka-naziv si040b.
                move zero to zbirka-ownkey w-zbirka-ownkey.
	lis-abc-zbirka0. 
		perform spczbirka
			varying lin from 7 by 1 until lin > 19.
		display g-okvlis40
		display line 6 col 11 li-zbirka.
	lis-abc-zbirka1. 
		if w-zbirka-naziv not = space 
			move w-zbirka-naziv to zbirka-naziv
			move space to naziv. 
                start zbirka key not < zbirka-naziv invalid key
			perform lis-abc-zbirka go lis-abc-zbirka3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-abc-zbirka2. 
		perform next-zbirka
		if endp go lis-abc-zbirka4.
                move space to si040b move 1 to pt
		move zbirka-ownkey to z2v0
                string
      *			" " z2v0
			" " zbirka-naziv
			delimited by size into si040b with pointer pt.
                display line lin col 10 si040b
                add 1 to lin 
		move zbirka-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-abc-zbirka2.
		perform postavi-kurzorcek.
	lis-abc-zbirka3.  
		display l-naziv
		accept l-naziv
                move naziv to w-zbirka-naziv.
		if tp-esc or tp-nazaj go lis-abc-zbirka.
                if tp-enter go lis-sex-zbirka.
                if tp-lissif move zero to zbirka-ownkey
					go lis-sif-zbirka.
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
			GO LIS-ABC-zbirka3.
                go lis-abc-zbirka1.
	lis-abc-zbirka4. 
		move space to si040b 
                perform spczbirka
			varying lin from lin by 1 until lin > 19.
                perform lis-abc-zbirka
		perform postavi-kurzorcek
		go lis-abc-zbirka3.
	lis-sif-zbirka. 
                move zero to zbirka-ownkey w-zbirka-ownkey.
		move space to zbirka-naziv si040b.
	lis-sif-zbirka0. 
                perform lis-abc-zbirka0.
	lis-sif-zbirka1. 
		if w-zbirka-ownkey > 0 
			move w-zbirka-ownkey to zbirka-ownkey
			move 0 to kljuc.
                start zbirka key not < zbirka-ownkey invalid key
			perform lis-sif-zbirka go lis-sif-zbirka3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-sif-zbirka2. 
		perform next-zbirka
		if endp go lis-sif-zbirka4.
	        move space to si040b move 1 to pt
		move zbirka-ownkey to z2v0
                string " " z2v0 " " zbirka-naziv
			delimited by size into si040b with pointer pt.
                display line lin col 10 si040b
                add 1 to lin
		move zbirka-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-sif-zbirka2.
		perform postavi-kurzorcek.
	lis-sif-zbirka3.
		display l-kljuc.
		accept l-kljuc
                move kljuc to w-zbirka-ownkey.
		if tp-esc or tp-nazaj go lis-sif-zbirka.
                if tp-enter go lis-sex-zbirka.
                if tp-lisabc move space to zbirka-naziv
						go lis-abc-zbirka.
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
			GO LIS-SIF-zbirka3.
                go lis-sif-zbirka1.
	lis-sif-zbirka4.
		move space to si040b 
                perform spczbirka
			varying lin from lin by 1 until lin > 19.
                perform lis-sif-zbirka 
		perform postavi-kurzorcek
		go lis-sif-zbirka3.
	lis-sex-zbirka. 
		exit.
