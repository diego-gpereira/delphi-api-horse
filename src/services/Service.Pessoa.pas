unit Service.Pessoa;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.ConsoleUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, System.JSON,
  DataSet.Serialize, System.Generics.Collections,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait, Horse.Core.Param, System.NetEncoding;

type
  TServicePessoa = class(TDataModule)
    Connection: TFDConnection;
    qryCadastro: TFDQuery;
    qryPesquisa: TFDQuery;
    qryCadastroSEQUENCIA: TIntegerField;
    qryCadastroNOME: TStringField;
    qryCadastroRG: TStringField;
    qryCadastroCPF: TStringField;
    qryCadastroSEXO: TStringField;
    qryCadastroDATA_NASCIMENTO: TSQLTimeStampField;
    qryCadastroFOTO: TBlobField;
    qryPesquisaSEQUENCIA: TIntegerField;
    qryPesquisaNOME: TStringField;
    qryPesquisaRG: TStringField;
    qryPesquisaCPF: TStringField;
    qryPesquisaSEXO: TStringField;
    qryPesquisaDATA_NASCIMENTO: TSQLTimeStampField;
    qryPesquisaFOTO: TBlobField;

  public
    RespInsert: TFDQuery;
    function Count: Integer;
    function ListAll(const query: THorseCoreParam): TFDQuery;
    function Append(const AJson: TJSONObject): Boolean;
    function GetById(const AId: string): TFDQuery;
    function Update(const AId: string; const AJson: TJSONObject): Boolean;
    function Delete(const AId: string): Boolean;
    function Login(login, senha: string): TJsonObject;

  end;

implementation

{$R *.dfm}

// LOGIN
function TServicePessoa.Login(login, senha: string): TJsonObject;
begin

end;

// ADD PESSOA
function TServicePessoa.Append(const AJson: TJSONObject): Boolean;
var
  // antes do qryCadastro.Clear eu armazendo meu sql nessa variavel (linha.67)
  sqlOriginal: string;

  // criei essas variaveis para tratamento de dados
  rg, cpf, sexo, dataNasc, foto: string;
  seqPessoa: Integer;

begin
  try
    qryCadastro.Close;
    sqlOriginal := qryCadastro.SQL.Text;
    qryCadastro.SQL.Clear;
    qryCadastro.SQL.add
      ('insert into pessoas (NOME, RG, CPF, SEXO, DATA_NASCIMENTO, FOTO) ' +
      'values (:NOME, :RG, :CPF, :SEXO, :DATA_NASCIMENTO, :FOTO)');
    qryCadastro.SQL.add('returning SEQUENCIA {into :SEQUENCIA}');

    // NOME = NOTNULL
    qryCadastro.ParamByName('NOME').AsString :=
      AJson.GetValue<string>('nome').ToUpper;

    // RG
    if AJson.TryGetValue('rg', rg) and (Trim(rg) <> '') then
      qryCadastro.ParamByName('rg').AsString := Trim(rg)
    else
      qryCadastro.ParamByName('rg').Clear;

    // CPF
    if AJson.TryGetValue<string>('cpf', cpf) and (Trim(cpf) <> '') then
      qryCadastro.ParamByName('cpf').AsString := Trim(cpf)
    else
      qryCadastro.ParamByName('cpf').Clear;

    // SEXO
    if AJson.TryGetValue<string>('sexo', sexo) then
    begin
      sexo := Trim(LowerCase(sexo));
      if (sexo = 'f') or (sexo = 'm') then
        qryCadastro.ParamByName('sexo').AsString := UpperCase(sexo)
      else
        raise Exception.Create
          ('Parâmetro "sexo" inválido. Use apenas "f" ou "m".');
    end
    else
      qryCadastro.ParamByName('sexo').Clear;

    // DATA NASCIMENTO
    if AJson.TryGetValue<string>('data_nascimento', dataNasc) then
    begin
      if Trim(dataNasc) <> '' then
      begin
        try
          qryCadastro.ParamByName('data_nascimento').AsDateTime := // DATA_NASC
            EncodeDate(StrToInt(Copy(dataNasc, 7, 4)),
            StrToInt(Copy(dataNasc, 4, 2)), StrToInt(Copy(dataNasc, 1, 2)));
        except
          raise Exception.Create
            ('Formato de data inválido. Use o formato DD/MM/YYYY.');
        end;
      end
      else
        qryCadastro.ParamByName('data_nascimento').Clear; // DATA_NASC
    end;

    // FOTO
    if AJson.TryGetValue<string>('foto', foto) and (Trim(foto) <> '') then
    begin
      // 1. Descodifica a string Base64 para um array de bytes
      var LBytes := TNetEncoding.Base64.DecodeStringToBytes(foto);
      // 2. Cria um stream de memória a partir dos bytes
      var LStream := TBytesStream.Create(LBytes);
      try
        // 3. Carrega o stream diretamente no parâmetro do tipo BLOB
        // Esta é a forma correta de passar dados binários para um INSERT
        qryCadastro.ParamByName('foto').LoadFromStream(LStream, ftBlob);
      finally
        LStream.Free;
      end;
    end
    else
      qryCadastro.ParamByName('foto').Clear;

    qryCadastro.ExecSQL;

    // Pega o ID da sequência retornada
    seqPessoa := qryCadastro.ParamByName('SEQUENCIA').AsInteger;

    // Verifica o cadastro
    qryCadastro.Close;
    qryCadastro.SQL.Clear;
    qryCadastro.SQL.add('select * from pessoas p where p.sequencia = :SEQ');
    qryCadastro.ParamByName('SEQ').AsInteger := seqPessoa;
    qryCadastro.Open;

    Result := qryCadastro.ApplyUpdates(0) = 0;
    RespInsert := qryCadastro;
  finally
    // qryCadastro.SQL.Text := sqlOriginal; // devolvida o sql original
    // qryCadastro.Close;
  end;
end;

function TServicePessoa.Count: Integer;
var
  qAux: TFDQuery;
begin
  qAux := TFDQuery.Create(nil);
  try
    qAux.Connection := Connection;
    qAux.SQL.Text := 'SELECT COUNT(SEQUENCIA) AS TOTAL FROM PESSOAS';
    qAux.Open;
    Result := qAux.FieldByName('TOTAL').AsInteger;
  finally
    qAux.Free;
  end;
end;

// DELETE
function TServicePessoa.Delete(const AId: string): Boolean;
var
  sqlOriginal: string;
begin
  Result := False;

  try
    sqlOriginal := qryCadastro.SQL.Text;
    qryCadastro.Close;
    qryCadastro.SQL.Clear;
    qryCadastro.SQL.add('delete from Pessoas where sequencia = :id');
    qryCadastro.ParamByName('id').AsInteger := AId.ToInteger;
    qryCadastro.ExecSQL;
    Result := True;
  finally
    qryCadastro.SQL.Text := sqlOriginal;
    qryCadastro.Close;
  end;
end;

// GET :ID
function TServicePessoa.GetById(const AId: string): TFDQuery;
var
  qAux: TFDQuery;
  sqlOriginal: string;
begin
  try
    qAux := TFDQuery.Create(nil);
    qAux.Connection := qryCadastro.Connection;

    qAux.Close;
    qAux.SQL.Clear;
    qAux.SQL.add('select * from Pessoas p where p.sequencia = :id');
    qAux.ParamByName('id').AsInteger := AId.ToInteger;
    qAux.Open();
    Result := qAux;
  finally
  end;
end;

// GET :ID ou :NOME com Paginação
function TServicePessoa.ListAll(const query: THorseCoreParam): TFDQuery;
var
  LWhereClause: string;
  sqlOriginal: string;
begin
  try
    sqlOriginal := qryPesquisa.SQL.Text;
    qryPesquisa.Close;
    qryPesquisa.SQL.Clear;
    qryPesquisa.SQL.add('select * from Pessoas p');
    qryPesquisa.SQL.add('where 1 = 1');

    if query.ContainsKey('id') then
    begin
      qryPesquisa.SQL.add('and p.sequencia = :id');
      qryPesquisa.ParamByName('id').AsInteger := query.Items['id'].ToInteger;
    end;

    if query.ContainsKey('nome') then
    begin
      LWhereClause := LWhereClause + ' and';
      LWhereClause := LWhereClause + ' lower(p.nome) like :nome';
      qryPesquisa.SQL.add(LWhereClause);
      qryPesquisa.ParamByName('nome').AsString := '%' + query.Items['nome']
        .ToLower + '%';
    end;

    if LWhereClause <> '' then
      qryPesquisa.SQL.add(LWhereClause);

    qryPesquisa.SQL.add('order by p.sequencia asc');
    qryPesquisa.Open();
    Result := qryPesquisa;
  finally
  end;
end;

// PUT
function TServicePessoa.Update(const AId: string;
  const AJson: TJSONObject): Boolean;
var
  LJson: TJSONObject;
  sqlOriginal: string;
  teste, nome, dataNasc, rg, cpf, sexo, foto: string;
begin
  Result := False;
  AJson.TryGetValue<string>('data_nascimento', dataNasc);
  // atribui antes de qualquer manipulação JSON
  
  try
    sqlOriginal := qryCadastro.SQL.Text;
    qryCadastro.Close;
    qryCadastro.SQL.Clear;
    LJson := AJson.Clone as TJSONObject;
    LJson.RemovePair('data_nascimento');
    // Remova a data do JSON para evitar conflito no Merge com AJson

    if qryCadastro.Active then
      qryCadastro.Close;

    // Define as opções de atualização
    qryCadastro.UpdateOptions.UpdateTableName := 'PESSOAS';
    qryCadastro.UpdateOptions.KeyFields := 'SEQUENCIA';

    qryCadastro.SQL.add('select * from Pessoas where sequencia = :id');
    qryCadastro.ParamByName('id').AsInteger := AId.ToInteger;
    qryCadastro.Open;

    if (LJson.TryGetValue('nome', nome) and (Trim(nome) <> '')) then
    begin
      qryCadastro.Edit;
      qryCadastro.FieldByName('nome').AsString := UpperCase(nome)
    end
    else
      qryCadastro.ParamByName('nome').Clear;

    // verificar RG
    if not(LJson.TryGetValue('rg', rg) and (Trim(rg) <> '')) then
    begin
      raise Exception.Create('Parâmetro RG: vazio');
    end;
    qryCadastro.Edit;
    qryCadastro.FieldByName('rg').AsString := Trim(rg);

    // verficar CPF
    if not(LJson.TryGetValue('cpf', cpf) and (Trim(cpf) <> '')) then
    begin
      raise Exception.Create('Parâmetro CPF: vazio');
    end;
    qryCadastro.Edit;
    qryCadastro.FieldByName('cpf').AsString := Trim(cpf);

    // verficar SEXO
    if (LJson.TryGetValue('sexo', sexo) and (Trim(sexo) <> '')) then
    begin
      sexo := Trim(LowerCase(sexo));
      if (Trim(sexo) = 'f') or (Trim(sexo) = 'm') then
      begin
        qryCadastro.Edit;
        qryCadastro.FieldByName('sexo').AsString := UpperCase(sexo);
      end
      else
        raise Exception.Create
          ('Parâmetro SEXO vazio ou inválido (F: feminino ou M: masculino)');
    end;

    // Trata a data de nascimento manualmente APÓS o Merge
    if Trim(dataNasc) <> '' then
    begin
      try
        qryCadastro.Edit;
        qryCadastro.FieldByName('data_nascimento').AsDateTime := // DATA_NASC
          EncodeDate(StrToInt(Copy(dataNasc, 7, 4)),
          StrToInt(Copy(dataNasc, 4, 2)), StrToInt(Copy(dataNasc, 1, 2)));
      except
        raise Exception.Create
          ('Formato de DATA inválido. Use o formato DD/MM/YYYY.');
      end;
    end
    else
      qryCadastro.FieldByName('data_nascimento').Clear;
      // Se a dataNasc estiver vazia ou nula, defina o campo no banco de dados como nulo

    // verificar FOTO
    if (LJson.TryGetValue('foto', foto) and (Trim(foto) <> '')) then
    begin
      qryCadastro.Edit;

      // Cria um stream de BLOB para o campo da foto
      // O TDataSet fará a gestão da memória deste stream
      var LStream := qryCadastro.CreateBlobStream(qryCadastro.FieldByName('foto'), bmWrite);
      try
        // Decodifica a string Base64 de volta para bytes
        var LBytes := TNetEncoding.Base64.DecodeStringToBytes(foto);

        // Escreve os bytes diretamente no stream do banco de dados
        LStream.WriteBuffer(LBytes, Length(LBytes));
      finally
        LStream.Free;
      end;
    end;

    qryCadastro.Post;
    Result := qryCadastro.ApplyUpdates(0) = 0;
  finally
    // LJson.Free;
    // qryCadastro.SQL.Text := sqlOriginal;
    // qryCadastro.Close;
  end;
end;

end.
