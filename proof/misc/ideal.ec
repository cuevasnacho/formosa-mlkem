(**************************)
(**************************)
(**        Ideals        **)
(**************************)
(**************************)





(**************************)
(* Requirements           *)
(**************************)

<<<<<<< HEAD
(*There is already a clone import Ring.ComRing in BAdd, and they are conflicting*)

require import AllCore List Ring StdOrder Bigalg.
import StdOrder.IntOrder.
=======
require import AllCore List Ring StdRing Binomial.
require (*--*) Bigalg.
>>>>>>> 8f77b64b170334a2e52044b6d86c39f3efb2ae4e

clone include Ring.ComRing.

clone import Bigalg.BigComRing with
  type t <- t,
  pred CR.unit   <- Top.unit,
    op CR.zeror  <- Top.zeror,
    op CR.oner   <- Top.oner,
    op CR.( + )  <- Top.( + ),
    op CR.([-])  <- Top.([-]),
    op CR.( * )  <- Top.( * ),
    op CR.invr   <- Top.invr,
    op CR.intmul <- Top.intmul,
    op CR.ofint  <- Top.ofint,
    op CR.exp    <- Top.exp

    proof CR.*

    remove abbrev CR.(-)
    remove abbrev CR.(/).

realize CR.addrA      by apply Top.addrA    .
realize CR.addrC      by apply Top.addrC    .  
realize CR.add0r      by apply Top.add0r    . 
realize CR.addNr      by apply Top.addNr    . 
realize CR.oner_neq0  by apply Top.oner_neq0. 
realize CR.mulrA      by apply Top.mulrA    . 
realize CR.mulrC      by apply Top.mulrC    . 
realize CR.mul1r      by apply Top.mul1r    . 
realize CR.mulrDl     by apply Top.mulrDl   . 
realize CR.mulVr      by apply Top.mulVr    . 
realize CR.unitP      by apply Top.unitP    . 
realize CR.unitout    by apply Top.unitout  . 

instance ring with t
  op rzero = Top.zeror
  op rone  = Top.oner
  op add   = Top.( + )
  op opp   = Top.([-])
  op mul   = Top.( * )
  op expr  = Top.exp

  proof oner_neq0 by apply/oner_neq0
  proof addr0     by apply/addr0
  proof addrA     by apply/addrA
  proof addrC     by apply/addrC
  proof addrN     by apply/addrN
  proof mulr1     by apply/mulr1
  proof mulrA     by apply/mulrA
  proof mulrC     by apply/mulrC
  proof mulrDl    by apply/mulrDl
  proof expr0     by apply/expr0
  proof exprS     by apply/exprS.

(* -------------------------------------------------------------------- *)
lemma binomial (x y : t) n : 0 <= n => exp (x + y) n =
  BAdd.bigi predT (fun i => intmul (exp x i * exp y (n - i)) (bin n i)) 0 (n + 1).
proof.
elim: n => [|i ge0_i ih].
+ by rewrite BAdd.big_int1 /= !expr0 mul1r bin0 // mulr1z.
rewrite exprS // ih /= mulrDl 2!BAdd.mulr_sumr.
rewrite (BAdd.big_addn 1 _ (-1)) /= (BAdd.big_int_recr (i+1)) 1:/# /=.
pose s1 := BAdd.bigi _ _ _ _; rewrite binn // mulr1z.
rewrite !expr0 mulr1 -exprS // addrAC.
apply: eq_sym; rewrite (BAdd.big_int_recr (i+1)) 1:/# /=.
rewrite binn 1:/# mulr1z !expr0 mulr1; congr.
apply: eq_sym; rewrite (BAdd.big_int_recl _ 0) //=.
rewrite bin0 // mulr1z !expr0 mul1r -exprS // addrCA addrC; apply: eq_sym.
rewrite (BAdd.big_int_recl _ 0) //= bin0 1:/# mulr1z !expr0 mul1r addrC.
congr; apply: eq_sym; rewrite /s1 => {s1}.
rewrite !(BAdd.big_addn 1 _ (-1)) /= -BAdd.big_split /=.
rewrite !BAdd.big_seq &(BAdd.eq_bigr) => /= j /mem_range rg_j.
rewrite mulrnAr ?ge0_bin mulrA -exprS 1:/# /= addrC.
rewrite mulrnAr ?ge0_bin mulrCA -exprS 1:/#.
rewrite IntID.addrAC IntID.opprB IntID.addrA.
by rewrite -mulrDz; congr; rewrite (binSn i (j-1)) 1,2:/#.
qed.

(**************************)
(* Operators              *)
(**************************)

(*Ideal*)
op ideal (i : t -> bool) : bool =
   (exists x : t , i x)
/\ (forall x y : t , i x => i y => i (x+y))
/\ (forall x y : t , i x => i (x * y)).

lemma idealP (i : t -> bool) :
    (exists x, i x)
 => (forall x y, i x => i y => i (x+y))
 => (forall x y, i x => i (x * y))
 => ideal i.
proof. by move=> *; do! split. qed.

lemma idealW (P : (t -> bool) -> bool) :
  (forall i,
        (exists x, i x)
     => (forall (x y : t), i x => i y => i (x+y))
     => (forall x y, i x => i (x * y))
     => P i)
  => forall i, ideal i => P i.
proof. by move=> ih i [? [??]]; apply: ih. qed.

(*The zero ideal*)
op zeroId : t -> bool = pred1 zeror.

(*The whole ring ideal*)
op ringId : t -> bool = predT.

(*Intersection of two ideals*)
op interId ( i j : t -> bool ) : t -> bool =
  predI i j.

(*Sum of two ideals*)
op sumId ( i j : t -> bool ) : t -> bool =
  fun z => exists (x y : t), (z = x + y) /\ i x /\ j y.

(*Quotient of two ideals*)
op quoId ( i j : t -> bool ) : t -> bool =
  fun x => (forall y , j y => i (x * y)).

(*Ideal generated by a subset*)
op genId ( i : t -> bool ) : t -> bool =
  fun (x : t) =>
    exists l : (t * t) list ,
         ( x = BAdd.big predT (fun (z : t * t) => z.`1 * z.`2) l )
      /\ ( forall z , mem l z => i z.`1).

(*Product of two ideals*)
op prodId ( i j : t -> bool ) : t -> bool =
  genId (fun z => exists (x y : t), (z = x * y) /\ i x /\ j y).

(*Radical of two ideals*)
op radId ( i : t -> bool ) : t -> bool =
  fun x => exists n : int , 0 <= n /\ i (exp x n).

(*Principal ideal*)
op principal ( i : t -> bool ) : bool =
  exists x : t , i = genId (pred1 x).

(*Finitely generated ideal*)
op finitelyGenerated ( i : t -> bool ) : bool =
  exists lx : t list , i = genId (mem lx).



(**************************)
(* Lemmas                 *)
(**************************)

(*elim/idealW=> i [x ix] /(_ _ _ ix ix).*)

(*Ideals are not empty*)
lemma existsxInId : forall i , ideal i => exists x , i x by elim / idealW => i [x ix] _ _; exists x.

(*Ideals are stable by addition*)
lemma addStabId : forall i , ideal i => forall x y  , i x => i y => i (x+y) by elim / idealW.

(*Ideals are stable by multiplication by an element of the ring*)
lemma multStabId : forall i , ideal i => forall x y  , i x => i (x * y) by elim / idealW.

(*zeror is in any ideal*)
lemma zeroInId : forall i , ideal i => i zeror.
elim / idealW => i [x ix] _ mulStab.
rewrite - (mulr0 x).
by apply mulStab.
qed.

(*A sum of x_i*y_i where x_i is in the ideal is in the ideal*)
lemma bigSumStabId : forall i , ideal i => forall l , ( forall (z : t * t) , mem l z => i z.`1) => i (BAdd.big predT (fun (z : t * t) => z.`1 * z.`2) l).
move => i idi l leftlIni.
apply BAdd.big_rec.
+ by admit. (*by apply zeroInId.*)
+ move => z x _ ix.
  rewrite //=.
  by admit.
qed.

(*Ideals are stable by opposite*)
lemma oppStabId : forall i , ideal i => forall x , i x => i (-x).
proof.
elim / idealW => i _ _ mulStab x ix.
rewrite - (mulr1 x) - mulrN.
by apply mulStab.
qed.

(*The zero ideal is an ideal*)
lemma zeroIdIsId : ideal zeroId.
proof.
apply : idealP.
+ by exists zeror.
+ by move => x y @/zeroId -> -> ; rewrite addr0.
+ by move => x y @/zeroId -> ; rewrite mul0r.
qed.

(*The whole ring ideal is an ideal*)
lemma ringIdIsId : ideal ringId by done.

(*The intersection of two ideals is an ideal*)
lemma interIdIsId : forall i j , ideal i => ideal j => ideal (interId i j).
move => i j idi idj.
apply : idealP.
+ exists zeror.
  by split ; apply zeroInId.
+ move => x y [ix jx] [iy jy].
  by split ; apply addStabId.
+ move => x y [ix jx].
  by split ; apply multStabId.
qed.

(*The sum of two ideals is an ideal*)
lemma sumIsId : forall i j , ideal i => ideal j => ideal (sumId i j).
move => i j idi idj.
apply : idealP.
+ exists zeror zeror zeror.
  split.
  - by rewrite addr0.
  - by split ; rewrite zeroInId.
+ move => x y [xi xj [eqx [ixi jxj]]] [yi yj [eqy [iyi jyj]]].
  rewrite eqx eqy.
  exists (xi + yi) (xj + yj).
  split.
  - by ring.
  - by split ; apply addStabId.
+ move => x y [xi xj [eqx [ixi jxj]]].
  rewrite eqx mulrDl.
  exists (xi * y) (xj * y).
  by split => // ; split ; apply multStabId.
qed.

(*The quotient of two ideals is an ideal*)
lemma quoIdIsId : forall i j , ideal i => ideal j => ideal (quoId i j).
move => i j idi idj.
apply : idealP.
+ exists zeror.
  move => x jx.
  rewrite mul0r.
  by apply zeroInId.
+ move => x y quox quoy z jz.
  rewrite mulrDl.
  apply addStabId => //.
  - by apply quox.
  - by apply quoy.
+ move => x y quox z jz.
  rewrite - mulrA.
  apply quox.
  rewrite mulrC.
  by apply multStabId.
qed.

(*The ideal generated by a subset of a ring is an ideal*)
lemma genIsId : forall i , ideal (genId i).
move => i.
apply : idealP.
+ exists zeror [].
  split => //.
  rewrite BAdd.big_nil.
  (*Weird, might have something to do with the import stuff*)
  by admit.
+ move => x y [lx [xEqSumlx unzip1Inilx]] [ly [yEqSumly unzip1Inily]].
  rewrite xEqSumlx yEqSumly.
  (*The following should have done something*)
  (*rewrite - (BAdd.big_cat predT (fun (z : t * t) => z.`1 * z.`2) lx ly).*)
  by admit.
+ move => x y [lx [xEqSumlx unzip1Inilx]].
  rewrite xEqSumlx.
  (*Same issue here*)
  (*rewrite - (BAdd.mulr_suml predT (fun (z : t * t) => z.`1 * z.`2) lx y).*)
  by admit.
qed.

(*The ideal generated by a set contains this set*)
lemma genIdContainsSet : forall i , forall x , i x => genId i x.
move => i x ix.
exists [(x,oner)].
split => //.
rewrite BAdd.big_cons BAdd.big_nil => //=.
(*Again, same issue here*)
by admit.
qed.

(*The ideal generated by a set is the smallest ideal containing this set*)
lemma genIdSmallestIdContainingSet : forall i j , ideal j => (forall x , i x => j x) => (forall x , genId i x => j x).
move => i j idj iIncj x [lx [xEqSumlx unzip1Inilx]].
by admit.
qed.

(*The product of two ideals is an ideal*)
lemma prodIdIsId : forall i j , ideal i => ideal j => ideal (prodId i j).
move => i j idi idj.
(*It should work*)
(*by apply genIsId.*)
by admit.
qed.

lemma idealN : forall i , forall x , ideal i => i x => i (-x). admitted.

lemma exprM : forall x y n , 0 <= n => exp (x * y) n = (exp x n) * (exp y n). admitted.

(*The radical of an ideal is an ideal*)
(*
lemma radIdIsId : forall i , ideal i => ideal (radId i).
move => i idi.
have radIdN : forall x , (radId i x) => (radId i (-x)).
move => x [n [ge0n expIni]].
exists n.
split => //.
rewrite - mulrN1.
rewrite exprM //.
by rewrite multStabId.
apply : idealP.
+ case : (existsxInId i idi).
  move => x ix.
  exists x 1.
  split.
  - by trivial.
  - by rewrite expr1.
+ move => x y radx rady.
  case : radx.
  move => nx [posnx inx].
  case : rady.
  move => ny [posny iny].
  wlog : x y nx ny posnx inx posny iny / (nx <= ny).
  move => wl.
  case : (nx <= ny).
  by apply wl.
  rewrite lerNgt /=.
  move/ltrW.
  move => ineqn.
  apply radIdN.
  by apply (wl _ _ ny nx).
  move => ineqn.
  exists ny.
  split => //.
  by admit.
+ move => x y radx.
  case : radx.
  move => nx [posnx inx].
  exists nx.
  split.
  - by exact posnx.
  - (*I would like to use something like expfM, but it seems to be only defined for fields*)
    by admit.
qed.
*)

(*A principal ideal is an ideal*)
lemma principalIdIsId : forall i , principal i => ideal i.
move => i [x eqi].
rewrite eqi.
by apply genIsId.
qed.

(*A finitely generated ideal is an ideal*)
lemma finitelyGeneratedIdIsId : forall i , finitelyGenerated i => ideal i.
move => i [lx eqi].
rewrite eqi.
by apply genIsId.
qed.

(*A principal ideal is finitely generated*)
lemma principalIsFinitelyGenerated : forall i , principal i => finitelyGenerated i.
move => i [x eqi].
exists [x].
by rewrite eqi.
qed.
