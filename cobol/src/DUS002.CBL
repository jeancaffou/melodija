	identification division.
      *
      * prg-nasl:   Sifrant pesmi
      *
	program-id.    dus002.
	author.        fintta.
	environment division.
	configuration section.
	special-names.
      		printer is konzola
  		decimal-point is comma.
	input-output section.
	file-control.
		copy avtor.sel.
		copy pesmi.sel.
		copy zbori.sel.
		copy printp.sel.
	data division.
	file section.
		copy avtor.lib.
		copy pesmi.lib.
		copy zbori.lib.
		copy printp.lib.
	working-storage section.
      ****************************************************************
      * individualna pomozna polja
      ****************************************************************
	01	prg-naz	pic x(6)  value "dus002".

	01	w-zbori-ownkey	pic 9(2).
	01	w-zbori-naziv	pic x(20).
	01	w-avtor-ownkey	pic 9(6).
	01	w-avtor-naziv	pic x(20).
	01	w-pesmi-ownkey	pic 9(6).
	01	w-pesmi-ownkey-r redefines w-pesmi-ownkey.
	        03      w-pesmi-zbori		pic 9(2).
		03	w-pesmi-stevilka	pic 9(5).
	01	w-pesmi-naziv	pic x(40).
	01	w-pesmi-verz	pic x(20).
	01	w-pesmi-prired	pic 9(6).
	01	w-pesmi-osnova	pic 9(6).
	01	w-pesmi-opomba	pic x(30).

	01	prired-naziv	pic x(20).
	01	osnova-naziv	pic x(20).

                copy dusan.hlp.
                copy dusan.lib.
      		copy dus002.ss.
      		copy dusan.prc.
      *--------------------------------------------------
	open-files.
		perform open-avtor.
		perform open-pesmi.
		perform open-zbori.
	individualno-delo section.
	iniciraj.
		move zero to	skok
				zbori-ownkey
				pesmi-stevilka
				pesmi-prired
				pesmi-osnova
                move space to	avtor-naziv
				zbori-naziv
				pesmi-naziv
				pesmi-verz
				osnova-naziv
				pesmi-opomba
		move w-pesmi-zbori to zbori-ownkey
		display line 25 col 1 erase.
	priprava-sli.
		if ek-dn = 1 perform screen-headd.
		display g-dus002. 
      	priprava-pol.	
		display a-zbori-ownkey.
		move space to zbori-naziv.
		if not zbori-ownkey = zero perform read-zbori.
		display a-zbori-naziv.
		display a-pesmi-stevilka.
		display a-pesmi-naziv.
		display a-pesmi-verz.
		display a-pesmi-prired.
		move space to prired-naziv
		if not pesmi-prired = zero
			move pesmi-prired to avtor-ownkey
			perform read-avtor
			move avtor-naziv to prired-naziv.
		display a-prired-naziv.
		display a-pesmi-osnova.
		move space to osnova-naziv
		if not pesmi-osnova = zero
			move pesmi-osnova to avtor-ownkey
			perform read-avtor
			move avtor-naziv to osnova-naziv.
		display a-osnova-naziv.
		display a-pesmi-opomba.
	krmili.
		if skok = 0 move 1 to skok go akcepti.
		if tp-esc if skok = 1 go konec 
			  else move 1 to skok go akcepti.
		if ( tp-enter or tp-dol ) add 1 to skok go akcepti.
		if tp-help perform pomoc-polje .
                if ( tp-nazaj or tp-gor ) subtract 1 from skok
                      if skok = 0 go krmili else go akcepti.
		if tp-slika 
			perform malaj-tipk 
		  	go akcepti.
		if tp-lissif  
			if skok = 1
				move 0 to w-zbori-ownkey
				perform lis-sif-zbori thru lis-sex-zbori
				move dis-buff(dis-i) to zbori-area
				perform priprava-sli thru priprava-pol
				go akcepti
			else
			if skok = 2 or skok = 3
      *				move 0 to w-pesmi-ownkey
				perform lis-sif-pesmi thru lis-sex-pesmi
				move dis-buff(dis-i) to pesmi-area
				move pesmi-zbori to zbori-ownkey
				perform priprava-sli thru priprava-pol
				go akcepti
			else
			if skok = 4
				move space to w-pesmi-verz
				perform lis-abc-pesver
						thru lis-sex-pesver
				move dis-buff(dis-i) to pesmi-area
				move pesmi-zbori to zbori-ownkey
				perform priprava-sli thru priprava-pol
				go akcepti
			else
			if skok = 5
				move 0 to w-avtor-ownkey
				perform lis-sif-avtor thru lis-sex-avtor 
				move dis-buff(dis-i) to avtor-area
				move avtor-ownkey to pesmi-osnova
				perform priprava-sli thru priprava-pol
				go akcepti
			else
			if skok = 6
				move 0 to w-avtor-ownkey
				perform lis-sif-avtor thru lis-sex-avtor 
				move dis-buff(dis-i) to avtor-area
				move avtor-ownkey to pesmi-prired
				perform priprava-sli thru priprava-pol
				go akcepti.
		if tp-lisabc 
			if skok = 1
				move space to w-zbori-naziv
				perform lis-abc-zbori thru lis-sex-zbori
				move dis-buff(dis-i) to zbori-area
				perform priprava-sli thru priprava-pol
				go akcepti
			else
			if skok = 2 or skok = 3
	                        move space to w-pesmi-naziv
				perform lis-abc-pesmi thru lis-sex-pesmi
				move dis-buff(dis-i) to pesmi-area
				move pesmi-zbori to zbori-ownkey
				perform priprava-sli thru priprava-pol
				go akcepti
			else
			if skok = 4
				move space to w-pesmi-verz
				perform lis-abc-pesver
						thru lis-sex-pesver
				move dis-buff(dis-i) to pesmi-area
				move pesmi-zbori to zbori-ownkey
				perform priprava-sli thru priprava-pol
				go akcepti
			else
			if skok = 5
	                        move space to w-avtor-naziv
				perform lis-abc-avtor thru lis-sex-avtor 
				move dis-buff(dis-i) to avtor-area
				move avtor-ownkey to pesmi-osnova
				perform priprava-sli thru priprava-pol
				go akcepti
			else
			if skok = 6
	                        move space to w-avtor-naziv
				perform lis-abc-avtor thru lis-sex-avtor 
				move dis-buff(dis-i) to avtor-area
				move avtor-ownkey to pesmi-prired
				perform priprava-sli thru priprava-pol
				go akcepti.
		if ( tp-izpsif or tp-izpabc)
			if skok = 2 or skok = 3
      *				move 0 to w-pesmi-ownkey
				perform lis-abc-pesmi thru lis-sex-pesmi
				move dis-buff(dis-i) to pesmi-area
				move pesmi-zbori to zbori-ownkey
				perform priprava-sli thru priprava-pol
				go akcepti
			else
			if skok = 4
				move space to w-pesmi-verz
				perform lis-abc-pesver
						thru lis-sex-pesver
				move dis-buff(dis-i) to pesmi-area
				move pesmi-zbori to zbori-ownkey
				perform priprava-sli thru priprava-pol
				go akcepti.
		if ( tp-izpsif or tp-izpabc)
			move pesmi-area to ws-area
			if skok = 6
				perform lis-abc-pespri
						thru lis-sex-pespri
				if not dis-buff(dis-i) = space
				move dis-buff(dis-i) to pesmi-area
				else move ws-area to pesmi-area.
		if ( tp-izpsif or tp-izpabc)
			if skok = 5
				perform lis-abc-pesosn
						thru lis-sex-pesosn
				if not dis-buff(dis-i) = space
				move dis-buff(dis-i) to pesmi-area
				else move ws-area to pesmi-area.
		if ( tp-izpsif or tp-izpabc)
			if skok = 6
				perform lis-abc-pespri
						thru lis-sex-pespri
				if not dis-buff(dis-i) = space
				move dis-buff(dis-i) to pesmi-area
				else move ws-area to pesmi-area.
      *		if ( tp-izpsif or tp-izpabc)
			if ( skok = 5 or skok = 6 )
				move pesmi-zbori to zbori-ownkey
				perform priprava-sli thru priprava-pol
				go akcepti.

		if tp-brisi if mrnf go iniciraj.
		if tp-brisi if stars go zbrisi.
		if tp-rezer  subtract 1 from ek-dn
			perform priprava-sli thru priprava-pol.
	akcepti. 
		perform pomoc-polje
		go	acc-zbori
			acc-stevilka
			acc-naziv
			acc-verz
			acc-osnova
			acc-prired
			acc-opomba
			acc-potrdi depending skok.
	acc-zbori.
		accept a-zbori-ownkey
		if tp-potrditev
			perform close-files
			call "dus003" cancel "dus003"
			perform open-files
			perform priprava-sli thru priprava-pol
			go acc-zbori.
		if not ( tp-enter or tp-dol ) go krmili.
		if not zbori-ownkey = zero
			perform read-zbori
			if not stars go acc-zbori.
		move zbori-ownkey to pesmi-zbori w-pesmi-zbori
		perform priprava-pol.
		go krmili.
	acc-stevilka.
		accept a-pesmi-stevilka
		if tp-potrditev
			move zero to	pesmi-stevilka
			perform najdi-zaporedno
			move zero to	pesmi-prired
					pesmi-osnova
			move space to	pesmi-naziv
					pesmi-verz
					prired-naziv
					osnova-naziv
					pesmi-opomba
			move w-pesmi-zbori to pesmi-zbori zbori-ownkey
			move w-pesmi-prired to pesmi-prired
			move w-pesmi-osnova to pesmi-osnova
			move w-pesmi-opomba to pesmi-opomba
			perform priprava-pol
			go acc-stevilka.

		if not ( tp-enter or tp-dol ) go krmili.
		if not pesmi-stevilka = zero
			perform read-pesmi
			if stars
				move pesmi-prired to avtor-ownkey
				perform read-avtor.
		move pesmi-stevilka to w-pesmi-stevilka
		perform priprava-pol.
		go krmili.
	acc-naziv.
		accept a-pesmi-naziv
		if not ( tp-enter or tp-dol ) go krmili.
      *		if pesmi-naziv = space go acc-naziv.
		perform priprava-pol.
		go krmili.
	acc-verz.
		if pesmi-verz = space
			if not pesmi-naziv = space
				move pesmi-naziv to pesmi-verz
			else move "ni verza" to pesmi-verz.
		display a-pesmi-verz.
		if tp-potrditev
			move space to pesmi-verz		
			display a-pesmi-verz.
		accept a-pesmi-verz
		if not ( tp-enter or tp-dol ) go krmili.
      *		if pesmi-verz = space go acc-verz.
		if pesmi-verz = space
			move "ni verza" to pesmi-verz.
		perform priprava-pol.
		go krmili.
	acc-osnova.
      *		if pesmi-osnova = 0
      *			if not pesmi-prired = 0
      *			move pesmi-prired to pesmi-osnova avtor-ownkey
      *			perform read-avtor
      *			move avtor-naziv to osnova-naziv
      *			display a-pesmi-osnova
      *			display a-osnova-naziv.
		accept a-pesmi-osnova
		if tp-potrditev
			perform close-files
			call "dus001" cancel "dus001"
			perform open-files
			perform priprava-sli thru priprava-pol
			go acc-osnova.
		if not ( tp-enter or tp-dol or tp-izpsif or tp-izpabc )
				go krmili.
      *		if pesmi-osnova = 0 go acc-osnova.
      *		if not pesmi-osnova = zero
      *			move pesmi-osnova to avtor-ownkey
      *			perform read-avtor
      *			if not stars go acc-osnova.
		move pesmi-osnova to w-pesmi-osnova
		perform priprava-pol.
		go krmili.
	acc-prired.
		accept a-pesmi-prired
		if tp-potrditev
			perform close-files
			call "dus001" cancel "dus001"
			perform open-files
			perform priprava-sli thru priprava-pol
			go acc-prired.
		if not ( tp-enter or tp-dol or tp-izpsif or tp-izpabc )
				go krmili.
		if not pesmi-prired = zero
			move pesmi-prired to avtor-ownkey
			perform read-avtor
			if not stars go acc-prired.
		move pesmi-prired to w-pesmi-prired
		perform priprava-pol.
		go krmili.
	acc-opomba.
		accept a-pesmi-opomba
		if not ( tp-enter or tp-dol ) go krmili.
		move pesmi-opomba to w-pesmi-opomba
		perform priprava-pol.
		go krmili.
	copy konec.prc.

      **************************************************************        
        ostalo section. 
	close-files.
		perform close-avtor.
		perform close-pesmi.
		perform close-zbori.
	upd-file.
		if not pesmi-zbori = 0
		if not pesmi-stevilka = 0
		if not pesmi-naziv = space
		if not pesmi-prired = 0
			perform upd-pesmi.
	delete-file.
		perform delete-pesmi.
        ostali-copyi.
		copy iopesmi.prc.
		copy ioavtor.prc.
		copy iozbori.prc.

		copy lipesmi.prc.
		copy liavtor.prc.
		copy lizbori.prc.
		copy lipesver.prc.
		copy lipespri.prc.
		copy lipesosn.prc.

      *		copy pravtor.prc.
      *		copy prpesmi.prc.
      *		copy przbori.prc.
      **************************************************************        
	help-polje section.
	pomoc-polje.
		if skok = 1 move h-zbori-ownkey   to ws-puterr.
		if skok = 2 move h-pesmi-stevilka to ws-puterr.
		if skok = 3 move h-pesmi-naziv  to ws-puterr.
		if skok = 4 move h-pesmi-verz to ws-puterr.
		if skok = 5 move h-pesmi-osnova to ws-puterr.
		if skok = 6 move h-pesmi-prired to ws-puterr.
		if skok = 7 move h-pesmi-opomba to ws-puterr.
		perform puterr.
	konec-pomoc-polje.
      **************************************************************        
	najdi-zaporedno section.
	zacetek-najdi.
	zanka-citaj.
		add 1 to pesmi-stevilka
		perform read-pesmi
		if mrnf
			go konec-najdi.
		go zanka-citaj.
	konec-najdi.
		exit.
      **************************************************************        
      * konec dus002
      **************************************************************        
