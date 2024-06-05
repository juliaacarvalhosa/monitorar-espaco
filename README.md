# Procedure para Monitorar Espaço Livre

## Stored Procedure EspacoDisco

A stored procedure `EspacoDisco` foi desenvolvida para monitorar e alertar sobre o espaço livre em discos nos servidores. A execução da procedure ocorre da seguinte maneira:

1. **Início da Execução**: A procedure é chamada com um e-mail como parâmetro para envio de notificações.
2. **Verificação de Espaço**: Uma tabela temporária `#TempResults` é criada para armazenar os resultados da consulta sobre volumes com pouco espaço livre.
3. **Consulta e Alerta**:
   - Um cursor percorre os registros de espaço livre de cada volume, conforme definido na tabela `dbo.MonitorEspacoLivre`.
   - Se o espaço livre estiver abaixo do limite configurado, a informação é inserida na tabela temporária.
4. **Geração de Relatório**:
   - Se nenhum volume estiver abaixo do limite, um relatório HTML simples é gerado, indicando que não há alertas.
   - Caso contrário, um relatório HTML detalhado é criado, listando os volumes que necessitam de atenção.
5. **Envio de Email**:
   - Um email é enviado ao destinatário especificado, contendo o relatório HTML como corpo da mensagem.
6. **Limpeza**: A tabela temporária é descartada ao final do processo.

A procedure é útil para ações proativas de gerenciamento de infraestrutura, assegurando que os administradores possam agir antes que os servidores sofram com a falta de espaço em disco.
