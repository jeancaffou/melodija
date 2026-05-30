        identification division.
      * menu - postavke, racuni
        program-id.    men001.
        author.        fintta.
        environment division.
        configuration section.
        special-names.
                printer is konzola
                decimal-point is comma.
       input-output section.
       file-control.
                copy avtor.sel.
                copy printp.sel.
        data division.
        file section.
                copy avtor.lib.
                copy printp.lib.
        working-storage section.
      ****************************************************************
      * individualna pomozna polja
      ****************************************************************
	01	prg-nasl	pic x(40) value 
      *                 1234567890123456789012345678901234567890
                       "P R O D A J A   컴컴컴컴컴컴컴컴컴컴컴컴".
	01	oddelek pic x(8) value "sklad".
	01	prg-naz	pic x(6) value "men001".
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

		display g-men001.

		move 28 to dis-col.
		move 3 to st-izbir.
		move 7 to line-izbir
		move 1 to dis-i.
		add 2 line-izbir giving dis-line.
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
		if TP-esc 
				goback.

		if i-izbira = "z" or i-izbira = "Z" go z1.
		if i-izbira = "t" or i-izbira = "T" go t1.

		MOVE DIS-I TO I-IZBIRA-R

		go p1 p2 p3 depending on i-izbira-r.
		go izbiraa.

	p1.	call "dus002" cancel "dus002" perform ekran go izbiraa.
	p2.	call "dus001" cancel "dus001" perform ekran go izbiraa.
	p3.	call "dus003" cancel "dus003" perform ekran go izbiraa.

	z1.	move "list \dusan\prt\dusan.lis" to par1 go p0.
	t1.	move "print \dusan\prt\dusan.lis" to par1 go p0.

	p0.	display par1 upon command-line
		call x"91" using stat funk param.
		display prazen-screen
		display g-glava
		display g-men000.
		display g-men001.
		go izbiraa.

	ekran.
		perform screen-headd
		display g-men001.
	pomoc-polje.
        individualno-delo-exit.
                        exit.
      *--------------------------------------------------
      * konec programa men001
      *--------------------------------------------------
