unit Controller.Pessoa;

interface

uses Horse,
  Horse.GBSwagger.Registry,
  Service.Pessoa,
  Model.Pessoa,
  DataSet.Serialize,
  System.JSON,
  Data.DB, sysutils,
  REST.Types,
  FireDAC.Comp.Client,
  GBSwagger.Path.Attributes,
  GBSwagger.Validator.Interfaces;

type

  [SwagPath('pessoas', 'Path de Pessoas')]
  TPessoa = class
  private
    FRequest: THorseRequest;
    FResponse: THorseResponse;

  public
    [SwagGET('/total', 'Retorna o total de registros')]
    [SwagResponse(200, 'Retorna um JSON com o número total de registros', False)] // <-- ADICIONE ESTA LINHA
    procedure GetTotal;

    [SwagGET('{id}', 'Buscar Pessoa')]
    [SwagParamPath('id', 'sequencia', True)]
    [SwagResponse(200, TPessoa_Response, 'Registro')]
    [SwagResponse(404, TPessoa_Response)]
    procedure DoGet;

    [SwagGET('Listar Pessoas com paginação')]
    [SwagParamQuery('pagina', 'Pagina')]
    [SwagParamQuery('max', 'Quantidade de Registro por Pagina')]
    [SwagParamQuery('id', 'Busca por id')]
    [SwagParamQuery('nome', 'Busca por nome')]
    [SwagResponse(200, TPessoa_Response, 'Users data', True)]
    procedure DoList;

    [SwagPOST('Inserir novo registro')]
    [SwagParamBody('body', TPessoa_Body)]
    [SwagResponse(201, TPessoa_Response)]
    [SwagResponse(400, TPessoa_Response)]
    [SwagResponse(500, TPessoa_Response)]
    procedure DoPost;

    [SwagPUT('{id}', 'Atualizar Pessoa')]
    [SwagParamPath('id', 'Sequencia', True)]
    [SwagParamBody('LData', TPessoa_Body)]
    [SwagResponse(204, TPessoa_Response)]
    [SwagResponse(400, TPessoa_Response)]
    [SwagResponse(404, TPessoa_Response)]
    procedure DoPut;

    [SwagDELETE('{id}', 'Deletar Pessoa')]
    [SwagParamPath('id', 'sequencia', True)]
    [SwagResponse(204, TPessoa_Response)]
    [SwagResponse(400, TPessoa_Response)]
    [SwagResponse(404, TPessoa_Response)]
    procedure DoDelete;

    constructor Create(Req: THorseRequest; Res: THorseResponse);

  end;

procedure RegistroPessoa;

implementation

constructor TPessoa.Create(Req: THorseRequest; Res: THorseResponse);
begin
  Self.FRequest := Req;
  Self.FResponse := Res;
end;

procedure TPessoa.GetTotal;
var
  LService: TServicePessoa;
  LTotal: Integer;
  LJson: TJSONObject;
begin
  LService := TServicePessoa.Create(nil);
  try
    // 1. Busca o número total de registos
    LTotal := LService.Count;

    // 2. Cria um objeto JSON manualmente
    LJson := TJSONObject.Create;

    // 3. Adiciona a chave "total" com o seu valor
    LJson.AddPair('total', TJSONNumber.Create(LTotal));

    // 4. Envia o objeto JSON. O Horse encarregar-se-á de o libertar.
    FResponse.Send<TJSONObject>(LJson);
  finally
    LService.Free;
  end;
end;

procedure TPessoa.DoList; // Listar Pessoas
var
  Servico: TServicePessoa;
  LPag, LMax: Integer;
begin
  Servico := TServicePessoa.Create(nil);
  try
    LPag := StrToIntDef(FRequest.Query.Items['pagina'], 1);
    LMax := StrToIntDef(FRequest.Query.Items['max'], 15);

    if LPag < 1 then
      LPag := 1;
    if LMax < 1 then
      LMax := 10;

    // RecsSkip = quantidade a pular; página 1 não pula nada
    Servico.qryPesquisa.FetchOptions.RecsSkip := (LPag - 1) * LMax;
    Servico.qryPesquisa.FetchOptions.RecsMax := LMax;

    FResponse.Send(Servico.ListAll(FRequest.Query).ToJSONArray);
  finally
    Servico.Free;
  end;
end;

procedure TPessoa.DoGet; // Buscar Pessoa {:id}
var
  LId: string;
  LService: TServicePessoa;
  qGet: TFDQuery;
begin
  LService := TServicePessoa.Create(nil);
  try
    LId := FRequest.Params.Items['id'];

    qGet := LService.GetById(LId);

    if qGet.IsEmpty then
      raise EHorseException.Create.Status(THTTPStatus.NotFound)
        .Error('Erro NotFound');
    FResponse.Send(qGet.ToJSONObject());
    Write(qGet.Text);
  finally
    LService.Free;
    qGet.Close;
    qGet.Free;
  end;
end;

procedure RegistroPessoa;
begin
  THorseGBSwaggerRegistry.RegisterPath(TPessoa)
end;

procedure TPessoa.DoPost; // Cadastrar pessoa
var
  LService: TServicePessoa; // conexão banco de dados
  res: TFDQuery;
begin
  LService := TServicePessoa.Create(nil);
  try
    if LService.Append(FRequest.Body<TJSONObject>) then
      begin
      res := LService.RespInsert;
      FResponse.Send(res.ToJSONObject()).Status(THTTPStatus.Created)
      // FResponse.Send(Servico.ListAll(FRequest.Query).ToJSONArray);
      end
    else
      FResponse.Status(THTTPStatus.InternalServerError);
  finally
    LService.Free;
  end;
end;

procedure TPessoa.DoPut;
var
  LId, vExist: string;
  LService: TServicePessoa;
  LData: TJSONObject;
begin
  LService := TServicePessoa.Create(nil);
  try
    LId := FRequest.Params.Items['id'];

    if LService.GetById(LId).IsEmpty then
      raise EHorseException.Create.Status(THTTPStatus.NotFound)
        .Error('Erro: ID NotFound');

    LData := FRequest.body<TJSONObject>;

    if LService.Update(LId, LData) then
      FResponse.Status(THTTPStatus.NoContent);
  finally
    LService.Free;
  end;
end;

procedure TPessoa.DoDelete;
var
  LId: string;
  LService: TServicePessoa;
begin
  LService := TServicePessoa.Create(nil);
  try
    LId := FRequest.Params.Items['id'];
    if LService.GetById(LId).IsEmpty then
      raise EHorseException.Create.Status(THTTPStatus.NotFound)
        .Error('Erro NotFound');
    if LService.Delete(LId) then
      FResponse.Status(THTTPStatus.NoContent);
  finally
    Write('Deletado o ID: ' + LId);
    Writeln('');
    LService.Free;
  end;
end;

end.
