        identification division.
      * menu - osnovni
        program-id.    men000.
        author.        cene.
        environment division.
        configuration section.
        special-names.
                printer is konzola
                decimal-point is comma.
       input-output section.
       file-control.
                copy printp.sel.
		copy avtor.sel.
        data division.
        file section.
                copy printp.lib.
		copy avtor.lib.
        working-storage section.
      ****************************************************************
      * individualna pomozna polja
      ****************************************************************
	01	prg-nasl	pic x(40) value 
      *                 1234567890123456789012345678901234567890
                       "O D V E T N I K  컴컴컴컴컴컴컴컴컴컴컴�".
	01	oddelek pic x(8) value "sklad".
	01	prg-naz	pic x(6) value "men000".
      *--------------------------------------------------
                copy dusan.lib.
      *--------------------------------------------------
      *         %% tu vstavljaj ekranske opise
      *--------------------------------------------------
                copy dusan.scr.
                copy dusan0.prc.
      *--------------------------------------------------
        open-files.
	close-file.
	priprava-sli.
	priprava-pol.
        konec.
                goback.
      *--------------------------------------------------
        individualno-delo section.
      *--------------------------------------------------
        delo.
		display prazen-screen
		display g-melodija
		accept a-izbira
		display prazen-screen
		display g-glava
		display g-men000.

		move 9 to dis-col.
		move 5 to st-izbir.
		move 5 to line-izbir
		move 1 to dis-i.
		add dis-i dis-i line-izbir giving dis-line.
        izbiraa.
		display line dis-line col dis-col dis-znak-i.
		display g-ekrtis

		move space to i-izbira.
		display a-izbira.
		accept a-izbira

                IF TP-GOR
                        DISPLAY LINE DIS-LINE COL DIS-COL dis-space-i
                        SUBTRACT 1 FROM DIS-I
                        IF DIS-I < 1
                                MOVE ST-IZBIR TO DIS-I.
                IF TP-DOL
                        DISPLAY LINE DIS-LINE COL DIS-COL dis-space-i
                        ADD 1 TO DIS-I
                        IF DIS-I > ST-IZBIR
                                MOVE 1 TO DIS-I.
                IF TP-GOR OR TP-DOL
                        COMPUTE DIS-LINE = ( DIS-I * 2 ) + LINE-IZBIR
                        DISPLAY LINE DIS-LINE COL DIS-COL dis-znak-i
                        GO IZBIRAA.

      *		if TP-esc or TP-levo
      *		if TP-esc
      *			move pomoc-potrdi to wfl
      *			perform p-err
      *			if not tp-potrditev
      *				perform ekran go izbiraa
      *			else
      *				go konec.
		if TP-esc
			go izbiraa.

		if i-izbira = "z" or i-izbira = "Z" go z1.
		if i-izbira = "t" or i-izbira = "T" go t1.

		MOVE DIS-I TO I-IZBIRA-R

		go p1 p2 p3 p4 p5 depending on i-izbira-r.
		go izbiraa.

	p1.	call "men001" cancel "men001" perform ekran go izbiraa.
	p2.	call "men002" cancel "men002" perform ekran go izbiraa.
	p3.	call "men003" cancel "men003" perform ekran go izbiraa.
	p4.	move space to geslo
		accept a-geslo
		if not ok-geslo go izbiraa.
		call "men004" cancel "men004" perform ekran go izbiraa.

	p5.	move "park" to par1 go p0.

	z1.	move "list \dusan\prt\dusan.lis"  to par1 go p0.
	t1.	move "print \dusan\prt\dusan.lis" to par1 go p0.

	p0.	display par1 upon command-line
		call x"91" using stat funk param.
		display prazen-screen
		display g-glava
		display g-men000.
      *		display g-mir002.
		go izbiraa.
	ekran.
		perform screen-headd.
		display g-men000.
	pomoc-polje.
        individualno-delo-exit.
                        exit.
      *--------------------------------------------------
      * konec programa men000
      *--------------------------------------------------
