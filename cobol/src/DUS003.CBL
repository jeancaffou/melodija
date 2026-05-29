	identification division.
      *
      * prg-nasl:   Sifrant zborov.
      *
	program-id.    dus003.
	author.        fintta.
	environment division.
	configuration section.
	special-names.
      		printer is konzola
  		decimal-point is comma.
	input-output section.
	file-control.
		copy avtor.sel.
		copy zbori.sel.
		copy printp.sel.
	data division.
	file section.
		copy avtor.lib.
		copy zbori.lib.
		copy printp.lib.
	working-storage section.
      ****************************************************************
      * individualna pomozna polja
      ****************************************************************
	01	prg-naz	pic x(6)  value "dus003".

	01	w-zbori-naziv	pic x(20).
	01	w-zbori-ownkey	pic 9(6).

                copy dusan.hlp.
                copy dusan.lib.
      		copy dus003.ss.
      		copy dusan.prc.
      *--------------------------------------------------
	open-files.
		perform open-zbori.
	individualno-delo section.
	iniciraj.
		move zero to	skok
				zbori-ownkey
                move space to	zbori-naziv
				zbori-krnaz
		display line 25 col 1 erase.
	priprava-sli.
		if ek-dn = 1 perform screen-headd.
		display g-dus003. 
      	priprava-pol.	
		display a-zbori-ownkey.
		display a-zbori-naziv.
		display a-zbori-krnaz.
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
			move 0 to w-zbori-ownkey
			perform lis-sif-zbori thru lis-sex-zbori 
			move dis-buff(dis-i) to zbori-area
			perform priprava-sli thru priprava-pol
			go akcepti.
		if tp-lisabc 
                        move space to w-zbori-naziv
			perform lis-abc-zbori thru lis-sex-zbori 
			move dis-buff(dis-i) to zbori-area
			perform priprava-sli thru priprava-pol
			go akcepti.
		if tp-izpsif or tp-izpabc
      			perform przbori
			go iniciraj.
		if tp-brisi if mrnf go iniciraj.
      *		if tp-brisi if zbori-ownkey = 0 go iniciraj.
		if tp-brisi if stars go zbrisi.
		if tp-rezer  subtract 1 from ek-dn
			perform priprava-sli thru priprava-pol.
	akcepti. 
		perform pomoc-polje
		go	acc-ownkey acc-naziv acc-krnaz
			acc-potrdi depending skok.
	acc-ownkey.
		accept a-zbori-ownkey
		if tp-potrditev
			move zero to zbori-ownkey
			perform najdi-zaporedno
			move space to zbori-naziv
			perform priprava-pol
			go acc-ownkey.

		if not ( tp-enter or tp-dol ) go krmili.
      * zbori 0 = zbori za izpis v glavi
		if zbori-ownkey = zero go acc-ownkey.
		perform read-zbori
		if not stars move space to zbori-naziv.
		perform priprava-pol.
		go krmili.
	acc-naziv.
		accept a-zbori-naziv  
		if tp-enter if zbori-naziv = space go acc-naziv.
		go krmili.
	acc-krnaz.
		accept a-zbori-krnaz
		if tp-enter if zbori-krnaz = space go acc-krnaz.
		go krmili.
	
	copy konec.prc.

      **************************************************************        
        ostalo section. 
	close-files.
		perform close-zbori.
	upd-file.
		perform upd-zbori.
	delete-file.
		perform delete-zbori.
        ostali-copyi.
		copy lizbori.prc.
		copy przbori.prc.
		copy iozbori.prc.
		copy ioavtor.prc.
      **************************************************************        
	help-polje section.
	pomoc-polje.
		if skok = 1 move h-zbori-ownkey to ws-puterr.
		if skok = 2 move h-zbori-naziv to ws-puterr.
		if skok = 3 move h-zbori-krnaz to ws-puterr.
		perform puterr.
	konec-pomoc-polje.
      **************************************************************        
      *	najdi-zaporedno section.
      *	zacetek-najdi.
      *		start zbori key not < zbori-ownkey
      *			invalid key go konec-najdi.
      *	zanka-citaj.
      *		perform next-zbori
      *		if endp
      *			add 1 to zbori-ownkey
      *			go konec-najdi.
      *		go zanka-citaj.
      *	konec-najdi.
      *		exit.

	najdi-zaporedno section.
	zacetek-najdi.
	zanka-citaj.
		add 1 to zbori-ownkey
		perform read-zbori
		if mrnf
			go konec-najdi.
		go zanka-citaj.
	konec-najdi.
		exit.
      **************************************************************        
      * konec dus003
      **************************************************************        
