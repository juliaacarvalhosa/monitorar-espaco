CREATE TABLE [dbo].[ServidorVolume](
	[Hostname] [varchar](50) NOT NULL,
	[Volume] [char](1) NOT NULL,
	[Coleta] [smalldatetime] NOT NULL,
	[EspacoLivre] [bigint] NOT NULL,
CONSTRAINT [PK_ServidorVolume] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Volume] ASC,
	[Coleta] ASC
))
GO
 
ALTER TABLE [dbo].[ServidorVolume]  WITH CHECK ADD  CONSTRAINT [FK_ServidorVolume_Volume] FOREIGN KEY([Hostname], [Volume])
REFERENCES [dbo].[Volume] ([Hostname], [Volume])
GO
