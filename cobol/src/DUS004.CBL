	identification division.
      *
      * prg-nasl:   Sifrant zbirk.
      *
	program-id.    dus004.
	author.        fintta.
	environment division.
	configuration section.
	special-names.
      		printer is konzola
  		decimal-point is comma.
	input-output section.
	file-control.
		copy avtor.sel.
		copy zbirka.sel.
		copy printp.sel.
	data division.
	file section.
		copy avtor.lib.
		copy zbirka.lib.
		copy printp.lib.
	working-storage section.
      ****************************************************************
      * individualna pomozna polja
      ****************************************************************
	01	prg-naz	pic x(6)  value "dus004".

	01	w-zbirka-naziv	pic x(25).
	01	w-zbirka-ownkey	pic 9(2).

                copy dusan.hlp.
                copy dusan.lib.
      		copy dus004.ss.
      		copy dusan.prc.
      *--------------------------------------------------
	open-files.
		perform open-zbirka.
	individualno-delo section.
	iniciraj.
		move zero to	skok
				zbirka-ownkey
                move space to	zbirka-naziv
		display line 25 col 1 erase.
	priprava-sli.
		if ek-dn = 1 perform screen-headd.
		display g-dus004. 
      	priprava-pol.	
		display a-zbirka-ownkey.
		display a-zbirka-naziv.
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
			move 0 to w-zbirka-ownkey
			perform lis-sif-zbirka thru lis-sex-zbirka 
			move dis-buff(dis-i) to zbirka-area
			perform priprava-sli thru priprava-pol
			go akcepti.
		if tp-lisabc 
                        move space to w-zbirka-naziv
			perform lis-abc-zbirka thru lis-sex-zbirka 
			move dis-buff(dis-i) to zbirka-area
			perform priprava-sli thru priprava-pol
			go akcepti.
		if tp-izpsif or tp-izpabc
      			perform przbirka
			go iniciraj.
		if tp-brisi if mrnf go iniciraj.
      *		if tp-brisi if zbirka-ownkey = 0 go iniciraj.
		if tp-brisi if stars go zbrisi.
		if tp-rezer  subtract 1 from ek-dn
			perform priprava-sli thru priprava-pol.
	akcepti. 
		perform pomoc-polje
		go	acc-ownkey acc-naziv
			acc-potrdi depending skok.
	acc-ownkey.
		accept a-zbirka-ownkey
		if tp-potrditev
			move zero to zbirka-ownkey
			perform najdi-zaporedno
			move space to zbirka-naziv
			perform priprava-pol
			go acc-ownkey.

		if not ( tp-enter or tp-dol ) go krmili.
      * zbirka 0 = zbirka za izpis v glavi
		if zbirka-ownkey = zero go acc-ownkey.
		perform read-zbirka
		if not stars move space to zbirka-naziv.
		perform priprava-pol.
		go krmili.
	acc-naziv.
		accept a-zbirka-naziv  
		if not ( tp-enter or tp-dol ) go krmili.
		if zbirka-naziv = space go acc-naziv.
		go krmili.
	
	copy konec.prc.

      **************************************************************        
        ostalo section. 
	close-files.
		perform close-zbirka.
	upd-file.
		perform upd-zbirka.
	delete-file.
		perform delete-zbirka.
        ostali-copyi.
		copy lizbirka.prc.
		copy przbirka.prc.
		copy iozbirka.prc.
		copy ioavtor.prc.
      **************************************************************        
	help-polje section.
	pomoc-polje.
		if skok = 1 move h-zbirka-ownkey to ws-puterr.
		if skok = 2 move h-zbirka-naziv to ws-puterr.
		perform puterr.
	konec-pomoc-polje.
      **************************************************************        
	najdi-zaporedno section.
	zacetek-najdi.
	zanka-citaj.
		add 1 to zbirka-ownkey
		perform read-zbirka
		if mrnf
			go konec-najdi.
		go zanka-citaj.
	konec-najdi.
		exit.
      **************************************************************        
      * konec dus004
      **************************************************************        
