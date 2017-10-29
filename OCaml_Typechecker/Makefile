#
# MASTER STL M2 - Cours TEP - 2004/2005
# 
# Makefile du typeur et de l'evaluateur d'un mini-ML
#

CAMLC=ocamlc
CAMLLINK=$(CAMLC) -o 
CAMLLEX=ocamllex
CAMLYACC=ocamlyacc
CAMLDEP=ocamldep
NAME=java

CIBLES=intertypeur 
#intereval ml2$(NAME)

SRCS =  util.ml types.ml  alex.ml asyn.ml  typeur.ml env_typeur.ml intertypeur.ml
#typeur.ml env_typeur.ml intertypeur.ml eval.ml env_eval.ml intereval.ml env_trans.ml lift.ml langinter.ml trans.ml prod.ml comp.ml 

IOBJS =  util.cmo types.cmo
SOBJS = alex.cmo  asyn.cmo  typeur.cmo env_typeur.cmo 

TOBJS = $(IOBJS) $(SOBJS)
EOBJS = $(TOBJS) eval.cmo env_eval.cmo 

COBJS = env_trans.cmo lift.cmo langinter.cmo trans.cmo prod.cmo comp.cmo 
#cible: $(CIBLES)

intertypeur: $(IOBJS) alex.ml asyn.ml  asyn.cmi $(TOBJS)
	$(CAMLLINK) $@ $(TOBJS) intertypeur.ml

#intereval: $(IOBJS) alex.ml asyn.ml alex.zi asyn.zi $(TOBJS) env_eval.zo
#	$(CAMLLINK) $@ $(EOBJS) intereval.ml
#
#ml2$(NAME): $(IOBJS) alex.ml asyn.ml alex.zi asyn.zi $(TOBJS) $(COBJS)
#	$(CAMLLINK) $@ $(EOBJS)  $(COBJS) maincomp.ml
#
#java: prodjava.ml
#	rm prod.ml
#	ln -s prodjava.ml prod.ml
#
distrib:
	tar -cvf distrib.tar $(SRCS) alex.mll  asyn.mly asyn.mli Makefile
#alex.mll alex.mli asyn.mly asyn.mli prodjava.ml maincomp.ml runtime.java Makefile


.SUFFIXES:

.SUFFIXES: .mll .mly .ml .mli .cmo .cmi 

.ml.cmo:
	$(CAMLC) -c $<

.mli.cmi:
	$(CAMLC) -c $<

.mly.ml:
	$(CAMLYACC) $<

.mll.ml:
	$(CAMLLEX) $<

clean:
	/bin/rm -f *~ *.cmi *.cmo alex.ml asyn.ml $(CIBLE)


depend:
	cp Makefile Makefile.bak
	(sed -e '/^#.*DEPEND.*automatic/,$$d' Makefile.bak; \
	echo '### DEPENDENCIES: automatically generated. Do not edit'; \
	$(CAMLDEP) $(SRCS)) > Makefile

### DEPENDENCIES: automatically generated. Do not edit
alex.cmo: asyn.cmi util.cmo 
alex.cmx: asyn.cmx util.cmx 
asyn.cmo: types.cmo util.cmo asyn.cmi 
asyn.cmx: types.cmx util.cmx asyn.cmi 
typeur.cmo: types.cmo util.cmo 
typeur.cmx: types.cmx util.cmx 
env_typeur.cmo: alex.cmo asyn.cmi types.cmo typeur.cmo util.cmo 
env_typeur.cmx: alex.cmx asyn.cmx types.cmx typeur.cmx util.cmx 
intertypeur.cmo: alex.cmo asyn.cmi types.cmo typeur.cmo util.cmo 
intertypeur.cmx: alex.cmx asyn.cmx types.cmx typeur.cmx util.cmx 
