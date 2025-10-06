program backend;
{$APPTYPE CONSOLE}
{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  Horse.CORS,
  Horse.HandleException,
  Horse.GBSwagger,
  Horse.BasicAuthentication,
  System.JSON,
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  Web.HTTPApp,
  Service.Pessoa in 'src\services\Service.Pessoa.pas' {ServicePessoa: TDataModule},
  Controller.Pessoa in 'src\controllers\Controller.Pessoa.pas',
  Model.Pessoa in 'src\models\Model.Pessoa.pas',
  Controller.Usuario in 'src\controllers\Controller.Usuario.pas',
  Controller.Auth in 'src\controllers\Controller.Auth.pas';

procedure InitSwagger;
begin
  Swagger.AddProtocol(TGBSwaggerProtocol.gbHttp).Info.Title('Api Horse Proansi')
    .Description('Treinamento Diego').Version('1.0.0')
    .Contact.Name('Diego Garcia').Email('diego.garcia@proansi.com.br')
    .URL('www.diego.com.br').&End.&End.AddBasicSecurity.AddCallback
    (HorseBasicAuthentication(
    function(const FUsername, FPassword: string): Boolean
    begin
      Result := FUsername.Equals('diego') and FPassword.Equals('123');
    end)).&End;
end;

begin
  InitSwagger;
  THorse.Use(Jhonson).Use(CORS).Use(HandleException).Use(HorseSwagger);
  Controller.Pessoa.RegistroPessoa;
  Controller.Usuario.RegistrarRotas;

  THorse.Listen(9000,
    procedure
    begin
      Writeln(Format('Server executando na porta: %d', [THorse.Port]));
      // http://localhost:9000/swagger/doc/html#/
    end);

end.
