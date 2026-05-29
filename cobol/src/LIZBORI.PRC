      **************************************************
      * lizbori.prc (listanje)
      **************************************************
	spczbori. 
		display line lin col 10 si040b.
	lis-abc-zbori. 
		move space to zbori-naziv 
			w-zbori-naziv si040b.
                move zero to zbori-ownkey w-zbori-ownkey.
	lis-abc-zbori0. 
		perform spczbori
			varying lin from 7 by 1 until lin > 19.
		display g-okvlis40
		display line 6 col 11 li-zbori.
	lis-abc-zbori1. 
		if w-zbori-naziv not = space 
			move w-zbori-naziv to zbori-naziv
			move space to naziv. 
                start zbori key not < zbori-naziv invalid key
			perform lis-abc-zbori go lis-abc-zbori3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-abc-zbori2. 
		perform next-zbori
		if endp go lis-abc-zbori4.
                move space to si040b move 1 to pt
		move zbori-ownkey to z2v0
                string
      *			" " z2v0
			" " zbori-naziv
			delimited by size into si040b with pointer pt.
                display line lin col 10 si040b
                add 1 to lin 
		move zbori-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-abc-zbori2.
		perform postavi-kurzorcek.
	lis-abc-zbori3.  
		display l-naziv
		accept l-naziv
                move naziv to w-zbori-naziv.
		if tp-esc or tp-nazaj go lis-abc-zbori.
                if tp-enter go lis-sex-zbori.
                if tp-lissif move zero to zbori-ownkey
					go lis-sif-zbori.
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
			GO LIS-ABC-zbori3.
                go lis-abc-zbori1.
	lis-abc-zbori4. 
		move space to si040b 
                perform spczbori
			varying lin from lin by 1 until lin > 19.
                perform lis-abc-zbori
		perform postavi-kurzorcek
		go lis-abc-zbori3.
	lis-sif-zbori. 
                move zero to zbori-ownkey w-zbori-ownkey.
		move space to zbori-naziv si040b.
	lis-sif-zbori0. 
                perform lis-abc-zbori0.
	lis-sif-zbori1. 
		if w-zbori-ownkey > 0 
			move w-zbori-ownkey to zbori-ownkey
			move 0 to kljuc.
                start zbori key not < zbori-ownkey invalid key
			perform lis-sif-zbori go lis-sif-zbori3.
                move 8 to lin.
		perform iniciraj-tabelo.
	lis-sif-zbori2. 
		perform next-zbori
		if endp go lis-sif-zbori4.
	        move space to si040b move 1 to pt
		move zbori-ownkey to z2v0
                string " " z2v0 " " zbori-naziv
			delimited by size into si040b with pointer pt.
                display line lin col 10 si040b
                add 1 to lin
		move zbori-area to dis-buff(dis-i)
		add 1 to dis-i
                if lin > 19 next sentence else go lis-sif-zbori2.
		perform postavi-kurzorcek.
	lis-sif-zbori3.
		display l-kljuc.
		accept l-kljuc
                move kljuc to w-zbori-ownkey.
		if tp-esc or tp-nazaj go lis-sif-zbori.
                if tp-enter go lis-sex-zbori.
                if tp-lisabc move space to zbori-naziv
						go lis-abc-zbori.
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
			GO LIS-SIF-zbori3.
                go lis-sif-zbori1.
	lis-sif-zbori4.
		move space to si040b 
                perform spczbori
			varying lin from lin by 1 until lin > 19.
                perform lis-sif-zbori 
		perform postavi-kurzorcek
		go lis-sif-zbori3.
	lis-sex-zbori. 
		exit.
