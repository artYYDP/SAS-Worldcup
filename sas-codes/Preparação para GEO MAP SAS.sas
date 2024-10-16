proc sql;
	create table WC_MATCHES_TRAT2 as
	select
		put(iso3, z3.) as iso3,
		*
	from PUBLIC.WC_MATCHES_TRAT;
quit;

/* Defina as variáveis da macro */
%let data = WC_MATCHES_TRAT2; /* Nome da tabela SAS que será carregada no servidor CAS */
%let outcaslib = PUBLIC; /* Biblioteca CAS onde a tabela será armazenada após ser carregada */
%let casout = WC_MATCHES_TRAT; /* Nome da tabela no servidor CAS após ter sido carregada */

/* Macro para Carregar Dados no CAS e Promover a Tabela */
%macro sas_load_data_cas(data=,outcaslib=, casout=);

/* Deleta a tabela da memória */
proc casutil;
  droptable incaslib = "&outcaslib." casdata = "&casout." quiet;
run;

/* Carrega tabela no CAS*/
proc casutil;
  load data=&data. casout="&casout." outcaslib=&outcaslib. replace;
quit;

/* Promove a tabela (disponível para todos os usuário acesso ao servidor) */
proc casutil;
  promote incaslib = "&outcaslib." casdata = "&casout."
  outcaslib = "&outcaslib." casout = "&casout.";
quit;
%mend sas_load_data_cas;

/* Chamar a macro com as variáveis definidas */
%sas_load_data_cas(data=&data, outcaslib=&outcaslib, casout=&casout)