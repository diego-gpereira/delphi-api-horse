object ServicePessoa: TServicePessoa
  Height = 406
  Width = 546
  object Connection: TFDConnection
    Params.Strings = (
      
        'Database=C:\Desenvolvimento\Treinamentos_Diego\Delphi\API Swagge' +
        'r + DBA\DBA\MeuBANCO.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'Server=localhost'
      'CharacterSet=WIN1252'
      'DriverID=FB')
    ConnectedStoredUsage = [auDesignTime]
    LoginPrompt = False
    Left = 216
    Top = 88
  end
  object qryCadastro: TFDQuery
    CachedUpdates = True
    Connection = Connection
    UpdateOptions.UpdateTableName = 'PESSOAS'
    UpdateOptions.KeyFields = 'SEQUENCIA'
    UpdateOptions.AutoIncFields = 'SEQUENCIA'
    SQL.Strings = (
      'select '
      '    p.sequencia,'
      '    p.nome,'
      '    p.rg,'
      '    p.cpf,'
      '    p.sexo,'
      '    p.DATA_NASCIMENTO,'
      '    p.foto'
      'from Pessoas p')
    Left = 216
    Top = 176
    object qryCadastroSEQUENCIA: TIntegerField
      AutoGenerateValue = arDefault
      FieldName = 'SEQUENCIA'
      Origin = 'SEQUENCIA'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object qryCadastroNOME: TStringField
      FieldName = 'NOME'
      Origin = 'NOME'
      Required = True
      Size = 50
    end
    object qryCadastroRG: TStringField
      FieldName = 'RG'
      Origin = 'RG'
      Size = 9
    end
    object qryCadastroCPF: TStringField
      FieldName = 'CPF'
      Origin = 'CPF'
      Size = 11
    end
    object qryCadastroSEXO: TStringField
      FieldName = 'SEXO'
      Origin = 'SEXO'
      FixedChar = True
      Size = 1
    end
    object qryCadastroDATA_NASCIMENTO: TSQLTimeStampField
      FieldName = 'DATA_NASCIMENTO'
      Origin = 'DATA_NASCIMENTO'
    end
    object qryCadastroFOTO: TBlobField
      FieldName = 'FOTO'
      Origin = 'FOTO'
    end
  end
  object qryPesquisa: TFDQuery
    Connection = Connection
    SQL.Strings = (
      'select '
      '    p.sequencia,'
      '    p.nome,'
      '    p.rg,'
      '    p.cpf,'
      '    p.sexo,'
      '    p.data_nascimento,'
      '    p.foto'
      'from Pessoas p'
      ''
      '')
    Left = 312
    Top = 176
    object qryPesquisaSEQUENCIA: TIntegerField
      AutoGenerateValue = arAutoInc
      FieldName = 'SEQUENCIA'
      Origin = 'SEQUENCIA'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object qryPesquisaNOME: TStringField
      FieldName = 'NOME'
      Origin = 'NOME'
      Required = True
      Size = 50
    end
    object qryPesquisaRG: TStringField
      FieldName = 'RG'
      Origin = 'RG'
      Size = 11
    end
    object qryPesquisaCPF: TStringField
      FieldName = 'CPF'
      Origin = 'CPF'
      Size = 11
    end
    object qryPesquisaSEXO: TStringField
      FieldName = 'SEXO'
      Origin = 'SEXO'
      FixedChar = True
      Size = 1
    end
    object qryPesquisaDATA_NASCIMENTO: TSQLTimeStampField
      FieldName = 'DATA_NASCIMENTO'
      Origin = 'DATA_NASCIMENTO'
    end
    object qryPesquisaFOTO: TBlobField
      FieldName = 'FOTO'
      Origin = 'FOTO'
    end
  end
  object qryAuthentication: TFDQuery
    Connection = Connection
    SQL.Strings = (
      'select * from usuario')
    Left = 112
    Top = 176
  end
end
