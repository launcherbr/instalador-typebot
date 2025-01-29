##REQUESITOS

-UBUNTU 20.04

-JA POSSUIR INSTALADO NO SEU SERVIDOR UMA VERSAO DE WHATICKET SAAS COM BANCO POSTGRES

CRIAR SUBDOMINIO E APONTAR PARA O IP DA SUA VPS EXEMPLO: 
typebot.seudominio.com
chat.seudominio.com
storage.seudominio.com

POSSUIR OS DADOS SMTP DE UMA CONTA DE EMAIL

##RODAR OS COMANDOS ABAIXO NO SEU SERVIDOR SSH

apt update && apt upgrade -y

apt install sudo dos2unix -y

sudo git clone https://github.com/Whaticket-Free/Instalador-TypeBot-Whaticket-SaaS.git && cd Instalador-TypeBot-Whaticket-SaaS && sudo chmod +x ./typebot.sh

dos2unix typebot.sh

./typebot.sh

AGORA E SO SEGUIR COM AS INSTUÇOES NA TELA DE SEU SERVIDOR
