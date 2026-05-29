      *--------------------------------------------------
	procedure division.
	vedno-isto section.
	zres-zacni.

                call keyboard-function using set-key-table-func
                           function-key-table.

      *-------- avtor 0 = uporabnik

		perform open-avtor
		move zero to avtor-ownkey
		perform read-avtor
		if not avtor-koliko = 999999
			add 1 to avtor-koliko
			perform upd-avtor
			if avtor-koliko > 600
				perform close-avtor
				display prazen-screen
				display g-glava
				display g-vinko
				accept i-izbira
				display prazen-screen
				stop run.
		move avtor-naziv to skladba-naziv
		perform close-avtor

      *-------- konec uporabnika

		accept datum from date 
		move datum to l-datum rec-datum.
		string datum(5:2) "/" datum(3:2) "/" datum(1:2)
			delimited by size into l1-datum.
		go individualno-delo.
	screen-headd.
		if not prg-naz = "men000"
			display prazen-screen
			display g-glava
			display g-men000.
	go-ind-delo.
		go individualno-delo.
	malaj-tipk.
                display pomoc-screen.
		accept dznk.
		display line 24 col 1 blank-vrsta
		display line 25 col 1 blank-vrsta.
	malaji-help.
        	move help1 to wfl
		perform p-err.
	faterr.
		accept fat-date from date
		accept fat-time from time
		move db-stat to fat-db-stat
		move prg-naz to fat-prg-naz
		display line 23 col 1 faterr-vrsta-1
		display line 24 col 1 faterr-vrsta-2
		go konec.
       p-err. 
		display line 23 col 1 erase
		display filer accept dznk on escape move 1 to skok.
		if tp-help perform pomoc-polje.
		if znk = "D" or "d" move 2 to terminator.
		if znk = "N" or "n" move 5 to terminator.
		move space to wfl znk display filer dznk.
	puterr.
		display puterr-scr.
	izvedi-proceduro.
		display par1 upon command-line
		call x"91" using stat funk param.

      *---------- lisini.prc
	postavi-kurzorcek.
		move 1 to dis-i.
		add dis-i 7 giving dis-line.
		display line dis-line col 10 dis-znak.
	iniciraj-tabelo.
		move 1 to dis-i.
		add dis-i 7 giving dis-line
		move space to dis-tabela.
      *--------------------------------------------------
	copy ioavtor.prc.
      *--------------------------------------------------
