(defun c:pt2block(;		replace points with blocks
  /;				no arguments
  attreq;			value to restore
  cmdecho;			value to restore
  bname;			block name to insert
  temp;				temp variable
  ent;				entity name
  elist;			entity list
  scf;				insertion scale factor
  rotang;			insertion rotation angle
  ss1;				selection set of points
  indx;				index through selection set
  sslen;			number of points selected
  inspt;			insertion point
 );				end of local variable list
 (if (and
   (setq
    bname (getstring "\nName of block to insert: ")
    temp (/= "" bname)
   )
   (progn
    (if (or
      (tblsearch "BLOCK" bname);	the block exists in the drawing
      (findfile (strcat bname ".dwg"));	the block can be pulled from disk
     );				end or
     T;				continue
     (progn
      (alert (strcat "Block " bname " not found."))
      nil
     );				end progn
    );				end if block found?
   );				end progn check for block
   (setq scf (getreal "\nInsertion scale factor: "))
   (setq rotang (getangle "\nInsertion rotation angle: "))
   (setq
    ss1 (ssget
     '((0 . "POINT");		get points
       (-4 . "<NOT");		not on 
        (8 . "DEFPOINTS");	layer DEFPOINTS
       (-4 . "NOT>");		end not
      );			end the quoted filter list
     );				end ssget
    temp (if (and ss1 (< 0 (sslength ss1)));	was anything selected
     T
     (setq 
      ss1 (ssget
       "X"
       '((0 . "POINT");		get points
        (-4 . "<NOT");		not on 
         (8 . "DEFPOINTS");	layer DEFPOINTS
        (-4 . "NOT>");		end not
       );			end the quoted filter list
      );			end ssget
     );				end setq (nested)
    );				end if?
   );				end setq (outer)
   (if (< 0 (sslength ss1))
    T
    (progn
     (alert "No points found.")
     nil
    );				end progn
   );				end if points found?
  );				end and
  (progn
   (setq
    attreq (getvar "attreq");	value to restore
    cmdecho (getvar "cmdecho");	value to restore
    indx -1;			a counter
    sslen (sslength ss1);	number of points selected
   )
   (setvar "attreq" 0)
   (setvar "cmdecho" 0)
   (while (> sslen (setq indx (1+ indx)))
    (setq
     ent (ssname ss1 indx);	entity name
     elist (entget ent);		entity list
     inspt (cdr (assoc 10 elist));location of the point
     inspt (trans inspt ent 1)
    );				end setq
    (entmake
     (list
      '(0 . "INSERT")
      (cons 2 bname)
      (assoc 8 elist)
      (cons 10 inspt)
      (cons 41 scf)
      (cons 42 scf)
      (cons 43 scf)
      (cons 50 (* rotang (/ pi 180)))
      (assoc 210 elist)
     );				end list
    );				end entmake
    (entdel ent);		get rid of the point
    (princ ".");			indicate progress
   );				end while
   (setvar "attreq" attreq)
   (princ (strcat "\t" (itoa sslen) " points replaced. "))
   (command "_.redraw")
   (setvar "cmdecho" cmdecho)
  );				end progn
 );				end if valid input?
 (princ)
);				end c:pt2block