/* Tabela de Teste da WC */
proc sql;
	create table teste as
	select
		year,
		host,
		teams
	from PUBLIC.WC
	order by year asc;
quit;

/* Tabela de Teste da WC MAtches */
proc sql;
	create table teste_resultados as
	select *
	from PUBLIC.WC_MATCHES
	order by year asc;
quit;