/* Criação de tabela única para Estatística */
proc sql;
    create table WC_MATCHES_1 as
    select
        date,
        Year,
				put(Year, best12.) as Year2,
        home_team,
        away_team,
        home_score,
        home_penalty,
        away_penalty,
        away_score,
				Score,
        Round,
        Venue,
        Host,
        home_manager,
        home_captain,
        away_manager,
        away_captain,
        Champion,
        TopScorrer,
        case 
            when home_score > away_score then 'Winner'
            when home_score < away_score then 'Loser'
            else 'Draw'
        end as home_status,
        case 
            when away_score > home_score then 'Winner'
            when away_score < home_score then 'Loser'
            else 'Draw'
        end as away_status,
				ISO2,
				iso3
    from PUBLIC.WC_MATCHES_TRAT
    order by date asc;
quit;

/* Data step para criação da sequência do jogo */
data WC_MATCHES_1_;
	set WC_MATCHES_1;
	game + 1;
run;

/* Tabela com o número do jogo */
proc sql;
    create table WC_MATCHES_1_F as
    select
        date,
        Year,
				Year2,
        home_team,
        away_team,
        home_score,
        home_penalty,
        away_penalty,
        away_score,
				Score,
        Round,
        Venue,
        Host,
        home_manager,
        home_captain,
        away_manager,
        away_captain,
        Champion,
        TopScorrer,
				home_status,
				away_status,
				ISO2,
				iso3,
				game
    from WC_MATCHES_1_
    order by date asc;
quit;

proc sql;
    /* Cria a tabela alternada com os valores trocados */
    create table WC_MATCHES_2 as
    select
        date,
        Year,
				put(Year, best12.) as Year2,
        away_team as home_team,
        home_team as away_team,
        away_score as home_score,
        away_penalty as home_penalty,
        home_penalty as away_penalty,
        home_score as away_score,
				Score,
        Round,
        Venue,
        Host,
        away_manager as home_manager,
        away_captain as home_captain,
        home_manager as away_manager,
        home_captain as away_captain,
        Champion,
        TopScorrer,
        case 
            when away_score > home_score then 'Winner'
            when away_score < home_score then 'Loser'
            else 'Draw'
        end as home_status,
        case 
            when home_score > away_score then 'Winner'
            when home_score < away_score then 'Loser'
            else 'Draw'
        end as away_status,
				ISO2,
				iso3
    from PUBLIC.WC_MATCHES_TRAT
		order by date asc;
quit;

/* Data step para criação da sequência do jogo */
data WC_MATCHES_2_;
	set WC_MATCHES_2;
	game + 1;
run;

/* Tabela com o número do jogo */
proc sql;
    create table WC_MATCHES_2_F as
    select
        date,
        Year,
				Year2,
        home_team,
        away_team,
        home_score,
        home_penalty,
        away_penalty,
        away_score,
				Score,
        Round,
        Venue,
        Host,
        home_manager,
        home_captain,
        away_manager,
        away_captain,
        Champion,
        TopScorrer,
				home_status,
				away_status,
				ISO2,
				iso3,
				game
    from WC_MATCHES_2_
    order by date asc;
quit;

/* Junta as duas tabelas em uma só */
proc sql;
    create table WC_MATCHES_FINAL as
    select * from WC_MATCHES_1_F
    union all
    select * from WC_MATCHES_2_F;
quit;

/* Junta as duas tabelas em uma só */
proc sql;
    create table WC_MATCHES_FINAL_F as
    select
			put(game, best12.) as game2,
			*
		from WC_MATCHES_FINAL;
quit;

/* Defina as variáveis da macro */
%let data = WC_MATCHES_FINAL_F; /* Nome da tabela SAS que será carregada no servidor CAS */
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