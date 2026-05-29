	identification division.
      *
      * prg-nasl:   Sifrant avtorjev
      *
	program-id.    dus001.
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
	01	prg-naz	pic x(6)  value "dus001".

	01	tab-vrsta value "AVTOR GLASBE   AVTOR BESEDILA ".
		03	clen-vrsta	pic x(15) occurs 2.
	01	vrsta-naziv	pic x(15).

	01	w-avtor-naziv	pic x(20).
	01	w-avtor-ownkey	pic 9(6).

                copy dusan.hlp.
                copy dusan.lib.
      		copy dus001.ss.
      		copy dusan.prc.
      *--------------------------------------------------
	open-files.
		perform open-avtor.
	individualno-delo section.
	iniciraj.
		move zero to	skok
				avtor-vrsta
				avtor-ownkey
                move space to	avtor-naziv
				vrsta-naziv
		display line 25 col 1 erase.
	priprava-sli.
		if ek-dn = 1 perform screen-headd.
		display g-dus001. 
      	priprava-pol.	
		display a-avtor-ownkey.
		display a-avtor-naziv.
		display a-avtor-vrsta.
		move space to vrsta-naziv
		if not avtor-vrsta = 0
			move clen-vrsta(avtor-vrsta) to vrsta-naziv.
		display a-vrsta-naziv.
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
			move 0 to w-avtor-ownkey
			perform lis-sif-avtor thru lis-sex-avtor 
			move dis-buff(dis-i) to avtor-area
			perform priprava-sli thru priprava-pol
			go akcepti.
		if tp-lisabc 
                        move space to w-avtor-naziv
			perform lis-abc-avtor thru lis-sex-avtor 
			move dis-buff(dis-i) to avtor-area
			perform priprava-sli thru priprava-pol
			go akcepti.
		if tp-izpsif or tp-izpabc
      			perform pravtor
			go iniciraj.
		if tp-brisi if mrnf go iniciraj.
      *		if tp-brisi if avtor-ownkey = 0 go iniciraj.
		if tp-brisi if stars go zbrisi.
		if tp-rezer  subtract 1 from ek-dn
			perform priprava-sli thru priprava-pol.
	akcepti. 
		perform pomoc-polje
		go	acc-ownkey acc-naziv
			acc-vrsta
			acc-potrdi depending skok.
	acc-ownkey.
		accept a-avtor-ownkey
			
		if tp-potrditev
			move zero to avtor-ownkey
			perform najdi-zaporedno
			move space to avtor-naziv
			perform priprava-pol
			go acc-ownkey.

		if not ( tp-enter or tp-dol ) go krmili.
      * avtor 0 = avtor za izpis v glavi
		if avtor-ownkey = zero go acc-ownkey.
		perform read-avtor
		if not stars move space to avtor-naziv.
		perform priprava-pol.
		go krmili.
	acc-naziv.
		accept a-avtor-naziv  
		if not ( tp-enter or tp-dol ) go krmili.
		if avtor-naziv = space go acc-naziv.
		go krmili.
	acc-vrsta.
		accept a-avtor-vrsta
		if not ( tp-enter or tp-dol ) go krmili.
		if not ok-vrsta go acc-vrsta.
		perform priprava-pol
		go krmili.
	
	copy konec.prc.

      **************************************************************        
        ostalo section. 
	close-files.
		perform close-avtor.
	upd-file.
		perform upd-avtor.
	delete-file.
		perform delete-avtor.
        ostali-copyi.
		copy liavtor.prc.
		copy ioavtor.prc.
		copy pravtor.prc.
      **************************************************************        
	help-polje section.
	pomoc-polje.
		if skok = 1 move h-avtor-ownkey to ws-puterr.
		if skok = 2 move h-avtor-naziv to ws-puterr.
		if skok = 3 move h-avtor-vrsta to ws-puterr.
		perform puterr.
	konec-pomoc-polje.
      **************************************************************        
	najdi-zaporedno section.
	zacetek-najdi.
	zanka-citaj.
		add 1 to avtor-ownkey
		perform read-avtor
		if mrnf
			go konec-najdi.
		go zanka-citaj.
	konec-najdi.
		exit.
      **************************************************************        
      * konec dus001
      **************************************************************        
