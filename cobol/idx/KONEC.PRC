      *--------------------
      * konec.prc
      *--------------------
	acc-potrdi.
		move pomoc-potrdi to wfl
		perform p-err
		if tp-potrditev 
		  	perform upd-file
			perform iniciraj go priprava-pol.
		if tp-nazaj or tp-esc or tp-gor go krmili.
		go acc-potrdi.
	konec.
       		perform close-files
		goback.
	zbrisi.
		move pomoc-brisi to wfl
		perform p-err
		if tp-potrditev perform delete-file
			perform iniciraj go priprava-pol.
		if tp-nazaj or tp-esc or tp-gor go krmili.
		go zbrisi.
      *--------------------
