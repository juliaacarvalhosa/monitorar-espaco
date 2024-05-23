USE [SeuBanco]
GO

BEGIN TRANSACTION 

UPDATE [dbo].[Volume]
SET LimiteAlerta = CapacidadeGB * 0.05

COMMIT                       