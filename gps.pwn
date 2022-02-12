#define	FILTERSCRIPT

#include	<a_samp>
#include	<zcmd>

#define D_GPS	(100)
#define D_GPS2	(101)

new DB:handle, DBResult:cache;
public OnFilterScriptInit()
{
	handle = db_open("server.db");
	db_free_result(db_query(handle, "CREATE TABLE IF NOT EXISTS Localizacao (Local, PosX, PosY, PRIMARY KEY(Local));"));
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new query[144];
	if(dialogid == D_GPS && response)
	{
		if(listitem == 0)
		{
			RemovePlayerMapIcon(playerid, 99);
			SendClientMessage(playerid, -1, "Info: o seu gps foi desativado!");
		}
		else
		{
			format(query, sizeof query, "SELECT * FROM Localizacao WHERE Local='%s';", inputtext);
			cache = db_query(handle, query);
			new
				Float:x = db_get_field_assoc_float(cache, "PosX"),
				Float:y = db_get_field_assoc_float(cache, "PosY");
			
			db_free_result(cache);
			SetPlayerMapIcon(playerid, 99, x, y, 0.0, 56, 0, MAPICON_GLOBAL);
			SendClientMessage(playerid, -1, "Info: localizacao marcada no seu GPS");
		}
		return 0;
	}

	if(dialogid == D_GPS2 && response)
	{
		format(query, sizeof query, "SELECT * FROM Localizacao WHERE Local='%s';", inputtext);
		cache = db_query(handle, query);
		if(db_num_rows(cache))
		{
			SendClientMessage(playerid, -1, "Info: o local foi deletado, utilize /gps");
			format(query, sizeof query, "DELETE FROM Localizacao WHERE Local='%s';", inputtext);
			cache = db_query(handle, query);
		}
		else cmd_deletarlocal(playerid);
		db_free_result(cache);
		return 0;
	}
	return 1;
}

CMD:criarlocal(playerid, params[])
{
	//if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "Erro: voce nao esta logado no rcon");
	
	if(strlen(params) < 3) SendClientMessage(playerid, -1, "Utilize: /criarlocal [titulo]");
	else
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		
		new query[255];
		format(query, sizeof query, "INSERT OR REPLACE INTO Localizacao VALUES ('%s', %f, %f);", params, x, y);
		db_free_result(db_query(handle, query));

		SendClientMessage(playerid, -1, "Info: o local foi adicionado, utilize /gps");
	}
	return 1;
}

CMD:deletarlocal(playerid)
{
	//if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "Erro: voce nao esta logado no rcon");

	new string[4096];
	cache = db_query(handle, "SELECT * FROM Localizacao;");
	if(!db_num_rows(cache)) SendClientMessage(playerid, -1, "Info: nao tem nenhuma localizacao");
	else
	{
		do
		{
	        new value[144], strtmp[144];
	        db_get_field_assoc(cache, "Local", value, sizeof value);
			format(strtmp, sizeof strtmp, "\n%s", value);
			strcat(string, strtmp);
		}
		while(db_next_row(cache));
		ShowPlayerDialog(playerid, D_GPS2, DIALOG_STYLE_INPUT, "{00AAFF}Digite o titulo:", string, "Deletar", "Cancelar");
	}
	db_free_result(cache);
	return 1;
}

CMD:gps(playerid)
{
	new string[4096];
	strcat(string, "{FF0000}Desativar o GPS{FFFFFF}");
	cache = db_query(handle, "SELECT * FROM Localizacao;");
	if(!db_num_rows(cache)) SendClientMessage(playerid, -1, "Info: nao tem nenhuma localizacao");
	else
	{
		do
		{
	        new value[144], strtmp[144];
	        db_get_field_assoc(cache, "Local", value, sizeof value);
			format(strtmp, sizeof strtmp, "\n%s", value);
			strcat(string, strtmp);
		}
		while(db_next_row(cache));
		ShowPlayerDialog(playerid, D_GPS, DIALOG_STYLE_LIST, "{00AAFF}Selecione uma opcao:", string, "Localizar", "Cancelar");
	}
	RemovePlayerMapIcon(playerid, 99);
	db_free_result(cache);
	return 1;
}

