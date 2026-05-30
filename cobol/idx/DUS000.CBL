	identification division.
      *
      * prg-nasl:   Vnos avtorja - vnasalca
      *
	program-id.    dus000.
	author.        fintta.
	environment division.
	configuration section.
	special-names.
      		printer is konzola
  		decimal-point is comma.
	input-output section.
	file-control.
		copy avtor.sel.
	data division.
	file section.
		copy avtor.lib.
	working-storage section.
      ****************************************************************
      * individualna pomozna polja
      ****************************************************************
	01	prg-naz	pic x(6)  value "dus000".
	01	vrsta-naziv	pic x(15).

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
				avtor-ownkey
                move space to	avtor-naziv
		display line 25 col 1 erase.
	priprava-sli.
		if ek-dn = 1 perform screen-headd.
		display g-dus001. 
      	priprava-pol.	
		display a-avtor-ownkey.
		display a-avtor-naziv.
		display a-avtor-koliko.
	krmili.
		if skok = 0 move 1 to skok go akcepti.
		if tp-esc if skok = 1 go konec 
			  else move 1 to skok go akcepti.
		if ( tp-enter or tp-dol ) add 1 to skok go akcepti.
		if tp-help perform pomoc-polje .
                if ( tp-nazaj or tp-gor ) subtract 1 from skok
                      if skok = 0 go krmili else go akcepti.
	akcepti. 
		perform pomoc-polje
		go
			acc-naziv
			acc-koliko
			acc-potrdi depending skok.
	acc-naziv.
		perform read-avtor
		perform priprava-pol
		accept a-avtor-naziv  
		if tp-enter if avtor-naziv = space go acc-naziv.
		go krmili.
	acc-koliko.
		accept a-avtor-koliko
		if not (tp-enter or tp-dol) go acc-koliko.
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
		copy ioavtor.prc.
      **************************************************************        
	help-polje section.
	pomoc-polje.
		if skok = 1 move h-avtor-naziv to ws-puterr.
		perform puterr.
	konec-pomoc-polje.
      **************************************************************        
      * konec dus001
      **************************************************************        
