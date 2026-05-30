        identification division.
      *
      * naslov:    izpis avtorjev
      *
        program-id.    izp002.
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
	COPY ESCSEQ.LIB.
        01      prg-naz	pic x(6)  value "izp002".
	01	valuta-dni	pic 9(3) value 8.
	COPY GLAVA80.LIB.

	01 p-vrsta.
		03 fill pic x(2) value space.
		03 p-datum	pic zz/zz/zz.
		03 fill	pic x(1) value space.
		03 p-strank11	pic z(6).
		03 fill	pic x(1) value space.
		03 p-naziv11	pic x(20).
		03 fill	pic x(1) value space.
		03 p-stezad	pic z(4).
		03 p-slas	pic x(1) value "/".
		03 p-leto	pic 9(2).
		03 fill	pic x(1) value space.
		03 p-opis	pic x(33).

	01	i-stevec	pic 9(6).
	01	w-vrsta		pic 9(1).
	88	ok-w-vrsta value 1 2.
	88	abeceda	value 1.
	88	sifra	value 2.
	01	tab-vrsta value "ABECEDNI  PO [IFRAH ".
		03	clen-vrsta	pic x(10) occurs 2.
	01	vrsta-naziv	pic x(10).

      *	01	katero-leto	pic 9(6).
      *		88	prestopno-leto value 88 92 96 00 04 08 12 16.

	01	tab-avtor.
		03	vrstica	occurs 521.
			05	avtor-1	pic 9(6) occurs 3.
	01	x	pic 9(6).
	88	x-stran	value 53 105 157 209 261 313 365 417 469 521.
	01	pom-x	pic 9(6).
	01	y	pic 9(6).
      *--------------------------------------------------
		copy dusan.hlp.
		copy dusan.lib.
		copy izp002.ss.
                copy dusan.prc.
      *--------------------------------------------------
        open-files.
                perform open-avtor.
	close-files.
                perform close-avtor.
        konec.
		perform close-files
                goback.
      *--------------------------------------------------
      * %% tu vstavljamo LI , PR  in IO procedure npr:

                copy ioavtor.prc.
      *--------------------------------------------------
        individualno-delo section.
      *--------------------------------------------------
	iniciraj.
		move zero to w-vrsta
		move space to vrsta-naziv
		display line 25 col 1 erase.
	priprava-sli.
		if ek-dn = 1 perform screen-headd.
		display g-izp002.
	priprava-pol.
		display a-w-vrsta.
		display a-vrsta-naziv.
	acc-vrsta.
		move h-vrsta-izpisa to ws-puterr.
		perform puterr.
		accept a-w-vrsta
		if tp-esc go konec.
		if not ( tp-enter or tp-dol ) go acc-vrsta.
		if not ok-w-vrsta go acc-vrsta.
		move clen-vrsta(w-vrsta) to vrsta-naziv
		perform priprava-pol.

	acc-potrdi.
		move pomoc-potrdi to wfl
		perform p-err
		if tp-potrditev 
			display g-lista
		  	perform prepis
		  	perform izpis
			display line 24 col 1 blank-vrsta
			display line 25 col 1 blank-vrsta
			go iniciraj.
		if tp-nazaj or tp-esc or tp-gor go iniciraj.
		go acc-potrdi.
      *--------------------------------------------------
        konec-individualno.
                exit.
      *--------------------------------------------------
	prepis section.
      *--------------------------------------------------
	zacetek-prepis.
		move zero to i-stevec
		move 0 to x
		move 1 to y
		move zero to avtor-ownkey
		move space to avtor-naziv
		start avtor key not < avtor-ownkey
			invalid key perform konec.
		if abeceda
			start avtor key not < avtor-naziv
				invalid key perform konec.
	beri-avtor.
		perform next-avtor
		if avtor-ownkey = 0 go beri-avtor.
		if endp
			go konec-prepis.
		add 1 to x
		add 1 to i-stevec
		if x-stran
			add 1 to y
			if y > 3
				move 1 to y
			else
				subtract 52 from x.
		move avtor-ownkey to avtor-1(x y).
		if x > pom-x
			move x to pom-x.
		go beri-avtor.
	konec-prepis.
		exit.
      *--------------------------------------------------
	izpis section.
      *--------------------------------------------------
	zacetek-izpis.
		open output printp.

		accept datum from date
                move dd to yu-datum-dan
                move dm to yu-datum-mes
                move dl to yu-datum-let
                move yu-datum-r to datum-g2

                accept cas from time
                move cas to l-cas.
		move uramin to ura-g4

		perform pisi-glavo.

		perform pisi-avtor varying x from 1 by 1
				until x > pom-x.
		
		write vrsta from glava-crte
		move i-stevec to vseh-skupaj
		write vrsta from glava-skupaj.

	test-avtor.
		close printp
		go konec-izpis.

	pisi-avtor.
		move space to p-vrsta
		move 1 to pt
      *		if avtor-1(x 1) not = zero
			move avtor-1(x 1) to avtor-ownkey
			perform read-avtor
			move avtor-ownkey to z5v0
			string	z5v0 " " avtor-naziv " "
				delimited by size into p-vrsta
				with pointer pt.
		if avtor-1(x 2) not = zero
			move avtor-1(x 2) to avtor-ownkey
			perform read-avtor
			move avtor-ownkey to z5v0
			string	z5v0 " " avtor-naziv
				delimited by size into p-vrsta
				with pointer pt.
		if avtor-1(x 3) not = zero
			move avtor-1(x 3) to avtor-ownkey
			perform read-avtor
			move avtor-ownkey to z5v0
			string	z5v0 " " avtor-naziv
				delimited by size into p-vrsta
				with pointer pt.

		add 1 to vrstic
		perform test-stevec
		write vrsta from p-vrsta.

	test-stevec.
		if ( stran = 1 and vrstic > 60 ) or
			( stran > 1 and vrstic > 59 )
			perform pisi-glavo.
	pisi-glavo.
		add 1 to stran
		move stran to stran-g3
		if stran > 1
			write vrsta from glava-g1.
		move skladba-naziv to naziv-g2
		write vrsta from glava-g2
		write vrsta from glava-g3
		move "Seznam AVTORJEV" to naslov-g4.
		write vrsta from glava-g4
      *		write vrsta from glava-g5
		write vrsta from glava-crte
		string	"    avtor                      avtor    "
			"                 avtor               "
			delimited by size into opis-g6.
		write vrsta from glava-g6
      *		write vrsta from glava-g7
		write vrsta from glava-crte
		move 8 to vrstic.
	konec-izpis.
		exit.
      *--------------------------------------------------
	ostalo section.
	zbrisi.
      *--------------------------------------------------
	help-polje section.
	pomoc-polje.
	konec-pomoc-polje.
      *--------------------------------------------------
      * konec programa	izp002
      *--------------------------------------------------
