unit Controller.Usuario;

interface

uses Horse,
     Horse.Jhonson,
     Horse.Cors,
     System.SysUtils,
     Service.Pessoa,
     System.JSON,
     Controller.Auth;

procedure RegistrarRotas;
procedure InserirUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
  THorse.Post('/usuarios', InserirUsuario);
  THorse.Post('/usuarios/login', Login);
end;

procedure InserirUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send('{"mensagem": "Usuário cadastrado..."}');
end;

procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  ServicePessoa : TServicePessoa;
  login, senha : string;
  cod_usuario : integer;
  body, json_ret: TJSONObject;
begin
  try
    ServicePessoa := TServicePessoa.Create(nil);

    body := Req.Body<TJSONObject>;
    login := body.GetValue<string>('ADMIN', '');
    senha := body.GetValue<string>('123', '');

    json_ret := ServicePessoa.Login(login, senha);

    if json_ret.Size = 0 then
      Res.Send('{"erro": "E-mail ou senha inválida..."}').Status(THTTPStatus.Unauthorized)
    else
    begin
      cod_usuario := json_ret.GetValue<integer>('cod_usuario', 1);

      // Gerar o token contendo o cod_usuario
      json_ret.AddPair('token', CriarToken(cod_usuario));

      Res.Send<TJSONObject>(json_ret).Status(THTTPStatus.OK);
    end;
  finally

  end;
end;


end.
