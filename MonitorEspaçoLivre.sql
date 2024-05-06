-- Criação da View usada na consulta da procedure "EspacoDisco"

CREATE VIEW [dbo].[MonitorEspacoLivre]
AS
SELECT     v.Hostname, v.Volume, 
		   v.CapacidadeGB, 
           CAST(SV.EspacoLivre / 1024.0 AS numeric(10, 2)) AS EspacoLivreGB, 
           v.CapacidadeGB - CAST(SV.EspacoLivre / 1024.0 AS numeric(10, 2)) as [Espaço Ocupado], -- calcula o espaço ocupado 
           CAST(SV.EspacoLivre / 1024.0 / v.CapacidadeGB * 100 AS numeric(10, 2)) AS PercentualLivre, -- porcentagem de espaço livre
		   v.ExcluirMonitoramento, v.LimiteAlerta
FROM         dbo.Volume AS v INNER JOIN
                      dbo.ServidorVolume AS SV ON v.Volume = SV.Volume AND v.Hostname = HSV.Hostname
WHERE      floor(cast (sv.Coleta as real)) + 1 > floor(cast(getdate() as real)) 
GO
