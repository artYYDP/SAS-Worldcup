/* Tabela de WC Matches com status de vencedor */
proc sql;
	create table WC_MATCHES_1 as
	select
		input(wcm.Date, yymmdd10.) as date format=ddmmyy10.,
		wcm.Year,
		wcm.home_team,
		wcm.Score,
		wcm.away_team,
		wcm.home_score,
		wcm.home_penalty,
		wcm.away_penalty,
		wcm.away_score,
		wcm.Round,
		st.New_name as Venue,
		wcm.Host,
		wcm.home_manager,
		wcm.home_captain,
		wcm.away_manager,
		wcm.away_captain,
		wc.Champion,
		wc.TopScorrer,
		/* Lógica para definir o status do time da casa (home_status) */
		case 
			when wcm.home_score > wcm.away_score then 'Winner'
			when wcm.home_score < wcm.away_score then 'Loser'
			else 'Draw'
		end as home_status,
		/* Lógica para definir o status do time visitante (away_status) */
		case 
			when wcm.away_score > wcm.home_score then 'Winner'
			when wcm.away_score < wcm.home_score then 'Loser'
			else 'Draw'
		end as away_status,
		st.Latitude,
		st.Longitude,
		st.ISO2,
		st.ISO3
	from PUBLIC.WC_MATCHES wcm
	left join PUBLIC.WC wc on (wc.Year = wcm.Year)
	left join CASUSER.STADIUMS st on (st.Venue = wcm.Venue)
	order by wcm.Date asc;
quit;

/* Defina as variáveis da macro */
%let data = WC_MATCHES_1; /* Nome da tabela SAS que será carregada no servidor CAS */
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