Estamos avaliando essa alternativa para rodar o typebot no mesmo servidor do whaticket, não utilize em produção,.


REQUISITOS
Sistema Operacional: Ubuntu 20.04

Whaticket SaaS: Já deve estar instalado no servidor, com banco de dados PostgreSQL configurado.

Subdomínios: Criar subdomínios e apontá-los para o IP do seu servidor VPS. Exemplos:

typebot.seudominio.com

chat.seudominio.com

storage.seudominio.com

Dados SMTP: Possuir as credenciais de uma conta de e-mail configurada.

COMANDOS PARA EXECUTAR NO SERVIDOR (via SSH)
Atualize os pacotes do sistema:

```bash
apt update && apt upgrade -y
```
Instale os pacotes necessários:

```bash
apt install sudo dos2unix -y
```
Clone o repositório do instalador e prepare o script:

```bash
sudo git clone https://github.com/launcherbr/instalador-typebot.git && cd instalador-typebot && sudo chmod +x ./typebot.sh
```
Converta o script para o formato Unix (caso necessário):

```bash
dos2unix typebot.sh
```
Execute o script de instalação:

```bash
./typebot.sh
```
PRÓXIMOS PASSOS
Agora, siga as instruções exibidas na tela do terminal do seu servidor para concluir a configuração.
