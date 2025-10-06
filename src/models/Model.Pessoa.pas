unit Model.Pessoa;

interface

uses
  GBSwagger.Model.Attributes;

type
  TTotalResponse = class
  private
    Ftotal: Integer;
  public
    [SwagProp('total', 'Número total de registros cadastrados')]
    property total: Integer read Ftotal write Ftotal;
end;

type
  TPessoa_Body = class
  private
    pNome: string;
    pRg: string;
    pCpf: string;
    pSexo: string;
    pData_nasc: TDate;
    pFoto: string;

  public
    [SwagProp(true)]
    [SwagString(50)]
    property nome: string read pNome write pNome;

    [SwagProp(true)]
    [SwagString(9)]
    property rg: string read pRg write pRg;

    [SwagProp(true)]
    [SwagString(11)]
    property cpf: string read pCpf write pCpf;

    [SwagProp(true)]
    [SwagString(1)]
    property sexo: string read pSexo write pSexo;

    [SwagProp(true)]
    [SwagFormat(TFormat.TDate)]
    property data_nascimento: TDate read pData_nasc write pData_nasc;

    [SwagProp(true)]
    [SwagString()]
    // dado binario base64
    property foto: string read pNome write pNome;

  end;

  TPessoa_Response = class
  private
    pSeq: Integer;
    pNome: string;
    pRg: string;
    pCpf: string;
    pSexo: string;
    pData_nasc: TDate;
    pFoto: string;
  public
    [SwagProp(true)]
    property seq: Integer read pSeq write pSeq;

    [SwagProp(true)]
    [SwagString(50)]
    property nome: string read pNome write pNome;

    [SwagProp(true)]
    [SwagString(14)]
    property rg: string read pRg write pRg;

    [SwagProp(true)]
    [SwagString(14)]
    property cpf: string read pCpf write pCpf;

    [SwagProp(true)]
    [SwagString(1)]
    property sexo: string read pSexo write pSexo;

    [SwagProp(true)]
    [SwagFormat(TFormat.Date)]
    property data_nascimento: TDate read pData_nasc write pData_nasc;

    [SwagProp(true)]
    [SwagFormat(TFormat.binary)]
    property foto: string read pFoto write pFoto;

  end;

implementation

end.
