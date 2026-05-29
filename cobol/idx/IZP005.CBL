        identification division.
      *
      * naslov:    izpis avtor-zbor-pesmi
      *
        program-id.    izp005.
        environment division.
        configuration section.
        special-names.
                printer is konzola
                decimal-point is comma.
       input-output section.
       file-control.
                copy printp.sel.
                copy avtor.sel.
                copy pesmi.sel.
                copy zbori.sel.
        data division.
        file section.
                copy printp.lib.
                copy avtor.lib.
                copy pesmi.lib.
                copy zbori.lib.
        working-storage section.
      ****************************************************************
      * individualna pomozna polja
      ****************************************************************
	COPY ESCSEQ.LIB.
        01      prg-naz pic x(6)  value "izp005".

		copy glava80.lib.

        01      w-datum pic 9(6).
        01      i-stevec   pic 9(6).
                88      prvi-citan      value 1.

        01      i-pesmi		pic 9(6).
      *--------------------------------------------------
        01      w-zbori-ownkey	pic 9(2).
	01	w-zbori-naziv	pic x(20).
	01	w-avtor-ownkey	pic 9(6).
	01	w-avtor-naziv	pic x(30).
        01      pesmi-zbori-old	pic 9(2).
	01	pesmi-prired-old pic 9(6).
      *--------------------------------------------------
		copy dusan.hlp.
		copy dusan.lib.
		copy izp005.ss.
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
		display g-izp005.
        priprava-pol.
		display a-zbori-ownkey.
		display a-zbori-naziv.
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
				go akcepti
			else if skok = 2
				perform lis-sif-avtor thru lis-sex-avtor
				move dis-buff(dis-i) to avtor-area
				move avtor-ownkey to pesmi-prired
				perform priprava-sli thru priprava-pol
				go akcepti.
                if tp-lisabc
			if skok = 1
				go akcepti
			else if skok = 2
				perform lis-abc-avtor thru lis-sex-avtor
				move dis-buff(dis-i) to avtor-area
				move avtor-ownkey to pesmi-prired
				perform priprava-sli thru priprava-pol
                                go akcepti.
                if tp-izpsif or tp-izpabc go akcepti.
		if tp-brisi go akcepti.
                if tp-rezer go akcepti.

        akcepti.
                perform pomoc-polje
                go      
			acc-zbori
			acc-avtor
                        acc-potrdi depending skok.

	acc-zbori.
		accept a-zbori-ownkey
			on escape move 0 to skok go konec.
		if not ( tp-enter or tp-dol ) go krmili.
		move zbori-ownkey to w-zbori-ownkey
		move "VSI" to zbori-naziv
		if not zbori-ownkey = zero
			perform read-zbori
			if not stars
				go acc-zbori.
		display a-zbori-naziv
		go krmili.

	acc-avtor.
		accept a-avtor-ownkey
			on escape move 0 to skok go krmili.
		if not ( tp-enter or tp-dol ) go krmili.
		move avtor-ownkey to w-avtor-ownkey
		move "VSI" to avtor-naziv
		if avtor-ownkey not = zero
			perform read-avtor
			if not stars
				go acc-avtor.
		display a-avtor-naziv.
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
                open output printp.

                move zero to
                        i-pesmi
                        stran

		perform pisi-glavo.

		move space to avtor-naziv
		start avtor key not < avtor-naziv
			invalid key perform konec.
		if w-avtor-ownkey not = zero
			start avtor key = avtor-ownkey
				invalid key perform konec.

        beri-avtor.
                perform next-avtor
                if endp
                        go test-pesmi.

		if w-avtor-ownkey not = zero
			if w-avtor-ownkey not = avtor-ownkey
				go test-pesmi.

		move 0 to i-pesmi pesmi-zbori-old
                move avtor-ownkey to pesmi-prired
		move space to pesmi-naziv
		move 0 to pesmi-zbori
                start pesmi key > pesmi-prired-zbori-naziv
                        invalid key go beri-avtor.
        beri-pesmi.
                perform next-pesmi.
                if endp
                        go beri-avtor.

		if not w-zbori-ownkey = zero
			if not w-zbori-ownkey = pesmi-zbori
				go beri-pesmi.

		if not avtor-ownkey = pesmi-prired
			go beri-avtor.

		add 1 to i-pesmi
		if not pesmi-prired = pesmi-prired-old
			perform pisi-avtor
			move pesmi-prired to pesmi-prired-old
			move pesmi-zbori to pesmi-zbori-old
		else
			if not pesmi-zbori = pesmi-zbori-old
				perform pisi-zbori
				move pesmi-zbori to pesmi-zbori-old.

		perform pisi-pesmi.
		go beri-pesmi.

        test-pesmi.
		write vrsta from glava-crte
		move i-stevec to vseh-skupaj
		write vrsta from glava-skupaj.
                close printp
                go konec-izpis.

        pisi-avtor.
		move space to zbori-naziv
		if w-zbori-ownkey = 0
			move pesmi-zbori to zbori-ownkey
			perform read-zbori.
		move space to vrsta
		write vrsta from g-bold
		add 1 to vrstic
		perform test-stevec
		move space to vrsta
		move avtor-ownkey to z6v0
		string z6v0 " " avtor-naziv
			" " zbori-naziv
			delimited by size into vrsta
		write vrsta
		write vrsta from g-draft
		add 2 to vrstic
		perform test-stevec.
	pisi-zbori.
		move pesmi-zbori to zbori-ownkey
		perform read-zbori
		move space to vrsta
		write vrsta from g-bold
		string bl(1:28) zbori-naziv
			delimited by size into vrsta
		write vrsta
		write vrsta from g-draft
		add 3 to vrstic
		perform test-stevec.
	pisi-pesmi.
		move space to vrsta
		move pesmi-stevilka to z5v0
		string  
			" " z5v0 
			" " pesmi-naziv
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
		if stran = 0
	                accept datum from date
	                move dd to yu-datum-dan
	                move dm to yu-datum-mes
	                move dl to yu-datum-let
	                move yu-datum-r to datum-g2
	                accept cas from time
	                move cas to l-cas
	                move uramin to ura-g4.
                add 1 to stran
                move stran to stran-g3
                if stran > 1
                        write vrsta from glava-g1.
		move skladba-naziv to naziv-g2
                write vrsta from glava-g2
                write vrsta from glava-g3

		move "Skladbe po AVTORJIH-ZBORIH" to naslov-g4 
                write vrsta from glava-g4

		move "VSI ZBORI" to opis-g5
		if not w-zbori-ownkey = 0
			perform read-zbori
			move zbori-naziv to opis-g5.
		write vrsta from glava-g5

                write vrsta from glava-crte
		string
			"     Avtor / Zbor / Skladba             "
			"      Opomba                          "  
				delimited by size into opis-g6
                write vrsta from glava-g6
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
		if skok = 2 move h-avtor-ownkey to ws-puterr.
		perform puterr.
        konec-pomoc-polje.
      *--------------------------------------------------
      * konec programa  izp005
      *--------------------------------------------------
