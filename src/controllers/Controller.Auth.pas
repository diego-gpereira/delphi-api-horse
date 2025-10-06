unit Controller.Auth;

interface

uses Horse,
     Horse.JWT,
     JOSE.Core.JWT,
     JOSE.Core.Builder,
     JOSE.Types.JSON,
     System.JSON,
     System.SysUtils;
//     Horse.Jhonson,
//     Horse.Cors;

const
  SECRET = 'PASS@123';

type
  TMyClaims = class(TJWTClaims)
  private
    function GetCodeUsuario: integer;
    procedure SetCodeUsuario(const Value: integer);
  public
    property COD_USUARIO: integer read GetCodeUsuario write SetCodeUsuario;
  end;

  function CriarToken(cod_usuario: integer): string;
  function Get_Usuario_Request(Req: THorseRequest): integer;

implementation

function CriarToken(cod_usuario: integer): string;
var
  jwt : TJWT;
  claims : TMyClaims;
begin
  try
    jwt := TJWT.Create;

    try
      jwt.Claims.SetClaim('cod_usuario', cod_usuario);

      result := TJOSE.SHA256CompactToken(SECRET, jwt);
    except
      result := '';
    end;

  finally
    FreeAndNil(jwt);
  end;
end;

function Get_Usuario_Request(Req: THorseRequest): integer;
var
  claims : TMyClaims;

begin
  claims := Req.Session<TMyClaims>;
  result := claims.COD_USUARIO;
end;


function TMyClaims.GetCodeUsuario: integer;
begin
  result := FJSON.GetValue<integer>('id', 0);
end;

procedure TMyClaims.SetCodeUsuario(const Value: integer);
begin
  TJSONUtils.SetJSONValueFrom<integer>('id', Value, FJSON);
end;

end.
