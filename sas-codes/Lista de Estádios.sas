/* Tabela dos Estádios */
proc sql;
	create table STADIUMS as
	select distinct
		Host,
		Year,
		Venue
	from PUBLIC.WC_MATCHES
	order by Year, Venue;
quit;
