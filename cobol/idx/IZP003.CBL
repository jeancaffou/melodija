
        identification division.
      *
      * naslov:    izpis pesmi
      *
        program-id.    izp003.
        environment division.
        configuration section.
        special-names.
                printer is konzola
                decimal-point is comma.
       input-output section.
       file-control.
                copy print132.sel.
                copy avtor.sel.
                copy pesmi.sel.
                copy zbori.sel.
        data division.
        file section.
                copy print132.lib.
                copy avtor.lib.
                copy pesmi.lib.
                copy zbori.lib.
        working-storage section.
      ****************************************************************
      * individualna pomozna polja
      ****************************************************************
	COPY ESCSEQ.LIB.
        01      prg-naz pic x(6)  value "izp003".
        01      valuta-dni      pic 9(3) value 8.

	copy glava132.lib.

        01 p-vrsta.
                03 fill pic x(2) value space.
                03 p-sifsto     pic z(3).
                03 fill pic x(1) value space.
                03 p-nazsto     pic x(20).
                03 fill pic x(1) value space.
                03 p-opis       pic x(10).
                03 fill pic x(1) value space.
                03 p-datum      pic zz/zz/zz.
                03 fill pic x(1) value space.
                03 p-tocke      pic z(4).
                03 fill pic x(1) value space.
                03 p-znesek     pic ----.---.---,--.
                03 fill pic x(1) value space.
                03 p-racuni     pic x(9).

        01      w-datum pic 9(6).
        01      i-stevec   pic 9(6).
                88      prvi-citan      value 1.

        01      i-pesmi		pic 9(6).
        01      i-postav        pic 9(2).
        01      j-postav        pic 9(2).

      *--------------------------------------------------
	01	w-vrsta		pic 9(1).
	88	ok-w-vrsta value 1 2.
	88	abeceda	value 1.
	88	sifra	value 2.
	01	tab-vrsta value "ABECEDNI  PO [IFRAH ".
		03	clen-vrsta	pic x(10) occurs 2.
	01	vrsta-naziv	pic x(10).
        01      w-zbori-ownkey	pic 9(2).
        01      w-pesmi-zbori	pic 9(2).
	01	w-zbori-naziv	pic x(20).
	01	w-pesmi-ownkey	pic 9(6).
	01	w-pesmi-naziv	pic x(30).
	01	w-avtor-ownkey	pic 9(6).
	01	w-avtor-naziv	pic x(20).
	01	prired-naziv	pic x(20).
	01	w-prired-naziv	pic x(20).
	01	naziv-1		pic x(1).
	01	naziv-1-old	pic x(1).
	01	pesmi-zbori-old	pic 9(2).
      *--------------------------------------------------
		copy dusan.hlp.
		copy dusan.lib.
		copy izp003.ss.
                copy dusan.prc.
      *--------------------------------------------------
        open-files.
		perform open-avtor.
                perform open-pesmi.
                perform open-zbori.
        close-files.
                perform close-avtor.
                perform close-pesmi.
                perform close-zbori.
        konec.
                perform close-files
                goback.
      *--------------------------------------------------
      * %% tu vstavljamo LI , PR  in IO procedure npr:

		copy liavtor.prc.
		copy lipesmi.prc.
		copy lizbori.prc.

                copy ioavtor.prc.
                copy iopesmi.prc.
                copy iozbori.prc.
      *--------------------------------------------------
        individualno-delo section.
      *--------------------------------------------------
        iniciraj.
                move zero to    skok
				avtor-ownkey
				pesmi-ownkey
				zbori-ownkey
				i-stevec
                move space to   avtor-naziv
                                pesmi-naziv
				zbori-naziv.
                display line 25 col 1 erase.
        priprava-sli.
                if ek-dn = 1 perform screen-headd.
		display g-izp003.
        priprava-pol.
		display a-zbori-ownkey.
		display a-zbori-naziv.
		display a-w-vrsta.
		display a-vrsta-naziv.
        krmili.
                if skok = 0 move 1 to skok go akcepti.
                if tp-esc if skok = 1 go konec
                          else move 1 to skok go akcepti.
                if tp-enter add 1 to skok go akcepti.
                if tp-help perform pomoc-polje .
                if tp-nazaj subtract 1 from skok
                      if skok = 0 go krmili else go akcepti.
                if tp-slika
                        perform malaj-tipk
                        go akcepti.
                if tp-lissif
			if skok = 1
				perform lis-sif-pesmi thru lis-sex-pesmi
				move dis-buff(dis-i) to pesmi-area
				perform priprava-sli thru priprava-pol
				go akcepti.
                if tp-lisabc
			if skok = 1
				perform lis-abc-pesmi thru lis-sex-pesmi
				move dis-buff(dis-i) to pesmi-area
				perform priprava-sli thru priprava-pol
                                go akcepti.
                if tp-izpsif or tp-izpabc go akcepti.
		if tp-brisi go akcepti.
                if tp-rezer go akcepti.

        akcepti.
                perform pomoc-polje
                go      
			acc-zbori
			acc-vrsta
                        acc-potrdi depending skok.

	acc-zbori.
		accept a-zbori-ownkey
			on escape move 0 to skok go konec.
		if not ( tp-enter or tp-dol ) go krmili.
		move zbori-ownkey to w-zbori-ownkey PESMI-ZBORI
		move "VSI" to zbori-naziv
		if zbori-ownkey not = zero perform read-zbori.
		display a-zbori-naziv
		go krmili.
	acc-vrsta.
		accept a-w-vrsta
                if tp-nazaj or tp-esc or tp-gor go krmili.
		if not ( tp-enter or tp-dol ) go acc-vrsta.
		if not ok-w-vrsta go acc-vrsta.
		move clen-vrsta(w-vrsta) to vrsta-naziv
		perform priprava-pol.
		go krmili.

        acc-potrdi.
                move pomoc-potrdi to wfl
                perform p-err
                if tp-potrditev
                        display g-lista
                        perform izpis
                        display line 24 col 1 blank-vrsta
                        display line 25 col 1 blank-vrsta
                        perform iniciraj
                        go priprava-pol.
                if tp-nazaj or tp-esc or tp-gor go krmili.
                go acc-potrdi.
      *--------------------------------------------------
        konec-individualno.
                exit.
      *--------------------------------------------------
        izpis section.
      *--------------------------------------------------
        zacetek-izpis.
                open output print132.

                accept datum from date
                move dd to yu-datum-dan
                move dm to yu-datum-mes
                move dl to yu-datum-let
                move yu-datum-r to datum-g2

                accept cas from time
                move cas to l-cas.
                move uramin to ura-g4

                move zero to
                        i-pesmi
                        stran

		perform pisi-glavo.

		move zero to pesmi-stevilka
		move space to pesmi-naziv

		start pesmi key not < pesmi-ownkey
			invalid key perform konec.
		if abeceda
			start pesmi key not < pesmi-naziv
				invalid key perform konec.
		
        beri-pesmi.
                perform next-pesmi
                if endp
                        go test-pesmi.
		if pesmi-stevilka = 0
			go beri-pesmi.

		if not w-zbori-ownkey = zero
			if not w-zbori-ownkey = pesmi-zbori
				if sifra
					go test-pesmi
				else
					go beri-pesmi.
		if i-stevec = zero
			move pesmi-zbori to pesmi-zbori-old
			move naziv-1 to naziv-1-old.
		perform pisi-pesmi.
		go beri-pesmi.

        test-pesmi.
		write vrsta from glava-crte
		move i-stevec to vseh-skupaj
		write vrsta from glava-skupaj.
                close print132
                go konec-izpis.

	pisi-pesmi.
		move space to vrsta
		move pesmi-naziv to naziv-1
		if abeceda
			if not naziv-1 = naziv-1-old
				move naziv-1 to naziv-1-old
				add 1 to vrstic
				write vrsta.
		if sifra
			if not pesmi-zbori = pesmi-zbori-old
			move pesmi-zbori to pesmi-zbori-old
			perform pisi-glavo.

		move pesmi-prired to avtor-ownkey
		perform read-avtor
		move pesmi-prired to z6v0
		move pesmi-stevilka to z5v0
		move pesmi-zbori to zbori-ownkey
		perform read-zbori
		string  "  "
			zbori-krnaz
			" " z5v0 
			" " pesmi-naziv
			" " z6v0
			" " avtor-naziv
			" " pesmi-opomba
				delimited by size into vrsta
		write vrsta.
		add 1 to vrstic
		add 1 to i-stevec
		perform test-stevec.

        test-stevec.
                if vrstic > 60
                        perform pisi-glavo.
        pisi-glavo.
                add 1 to stran
                move stran to stran-g3
                write vrsta from g-COMPRESS
                if stran > 1
                        write vrsta from glava-g1.
		move skladba-naziv to naziv-g2
                write vrsta from glava-g2
                write vrsta from glava-g3
		move "Seznam PESMI" to naslov-g4.
                write vrsta from glava-g4
		if sifra
			perform read-zbori
			move zbori-naziv to zbor-g5.
		if abeceda
			move "VSI" to zbor-g5
			if not w-zbori-ownkey = 0
				perform read-zbori
				move zbori-naziv to zbor-g5.
                write vrsta from glava-g5
                write vrsta from glava-crte
		string	"Zbor         Skladba                    "
			"                     Avtor              "
			" Opomba                                 "
			delimited by size into opis-g6.
                write vrsta from glava-g6
      *                write vrsta from glava-g7
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
		if skok = 1 move h-zbori-ownkey to ws-puterr.
		if skok = 2 move h-vrsta-izpisa to ws-puterr.
		perform puterr.
        konec-pomoc-polje.
      *--------------------------------------------------
      * konec programa  izp003
      *--------------------------------------------------
