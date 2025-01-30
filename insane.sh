#!/bin/bash

# Por Guilherme de Oliveira (Rapoelho)

# inSANE é um script de escaneamento simples que usa SANE para escanear imagens.


# Ele automatiza o processo de digitalização de imagens utilizando o programa SANE 
# (Scanner Access Now Easy) e o comando scanimage. O script configura pastas e resoluções 
# padrão para os arquivos escaneados e oferece a capacidade de selecionar o scanner, 
# verificar sua disponibilidade, escanear e visualizar a imagem digitalizada.


# Atualizado por: Fernando Souza - https://www.youtube.com/@fernandosuporte - 23/11/2024



# inSANE: Um Script para automatizar (um pouco) o SANE [Shell Script]


# Introdução

# Como eu já relatei em um outro tópico, eu estava tendo problemas para escanear imagens. 
# O Epson Scan (que eu usava inicialmente) parou de funcionar.

# Depois fui para o "Simple Scan do Gnome", que parou de funcionar direito depois que 
# escaneei uns documentos e salvei em PDF. Não importava se eu escolhesse JPEG, PNG ou 
# WebP, tudo o que era salvo no "Simple Scan" era em PDF.

# Por fim, acabei encontrando o "xSANE" no AUR, e apesar dele ser bem feio (e um pouco 
# confuso no começo), ele funcionou bem, mas por ser do AUR, me recomendaram remover esse 
# pacote. E assim eu fiz.

# E pesquisando uma forma de usar o SANE por linha de comando, acabei encontrando uma 
# página na Arch Wiki explicando sobre o "scanimage" que escaneia imagens por linha de 
# comando. Com isso, decidi fazer esse Script.


# E uma demonstração de como esse Script pode funcionar:


# https://youtu.be/2RC3N_SRmq0


# Código do Script

# O código do inSANE 1.0.0 está disponível no Pastebin. Basta baixar o código pelo 
# próprio Pastebin...

# https://pastebin.com/nxwFb94j
#
# Github: https://github.com/rapoelho/inSANE


# https://plus.diolinux.com.br/t/insane-um-script-para-automatizar-um-pouco-o-sane-shell-script/68697


# Eliminado os avisos do ShellCheck

# https://www.shellcheck.net/


# https://www.vivaolinux.com.br/topico/Suse/Permissao-para-executar-um-scanner
# https://www.vivaolinux.com.br/topico/Duvidas-em-Geral/Linux-Mint-Nao-consigo-fazer-o-simple-scan-reconhecer-o-scanner-da-Epson-L3150
# https://www.hamrick.com/vuescan/supported-scanners.html
# https://www.openprinting.org/drivers
# https://linuxdicasesuporte.blogspot.com/2018/06/scanner-com-sane-para-debian-e-ubuntu.html
# https://linuxdicasesuporte.blogspot.com/2020/02/liberar-o-scanner-de-rede-no-firewall.html
# https://www.vivaolinux.com.br/dica/Configurar-scanner-no-Debian-Lenny-Linux

# ----------------------------------------------------------------------------------------


# Instalação:

# Extrair o arquivo .tar.gz

# tar -xvf insane.tar.gz

# cd insane


# Informe a senha de Root:

# su -c "mv -i insane.sh    /usr/local/bin/insane.sh"


# mv -i digitalizar.desktop ~/.local/share/applications/digitalizar.desktop


# Como usar:

# menu iniciar => Gráficos => Digitalizar documentos


# Remoção:


# rm -Rf ~/.local/share/applications/digitalizar.desktop

# su -c "rm -Rf /usr/local/bin/insane.sh"


# ----------------------------------------------------------------------------------------


logo="/usr/share/icons/gnome/48x48/emblems/emblem-photos.png"

# ----------------------------------------------------------------------------------------

# Definir a versão

versao="1.0.1"

# ----------------------------------------------------------------------------------------

# Visualizador de imagem

clear

# Lista de visualizadores de imagem comuns no Linux

visualizadores_comuns=("gthumb" "feh" "ristretto" "eog" "shotwell" "gwenview" "sxiv" "mirage" "viewnior" "nomacs" "pix" "xnview" "qiv" "gpicview" "okular" "luminance" "display")


# Inicializar variável

visualizador_instalado=""


# Verificar cada visualizador

# Se o primeiro visualizador de imagem da lista estiver instalado, ele será atribuído à variável.

for visualizador_de_imagem in "${visualizadores_comuns[@]}"; do

    if command -v "$visualizador_de_imagem" &> /dev/null; then

        echo "$visualizador_de_imagem está instalado."

        sleep 2

        break  # Interrompe o loop após encontrar o primeiro visualizador instalado
    fi
done


# Se nenhum visualizador for encontrado

if [ -z "$visualizador_de_imagem" ]; then

    notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro" "Nenhum visualizador de imagem encontrado."

    exit 1

fi

# ----------------------------------------------------------------------------------------

# Definir palavras-chave para identificar várias marcas de scanners

# Usar lsusb para listar os dispositivos USB conectados e filtrar por várias marcas

SCANNER_KEYWORDS="Scanner|Ricoh|Lexmark|Epson|Canon|HP|Brother|Fujitsu|Xerox|Kodak|Samsung|Plustek|Microtek|Avision|Visioneer|Panasonic|Mustek|Siemens|Oki|Sharp|Kofax|Bosch|Savin|Contex|Nikon|Adesso|Avision|Zebra|Primera|Reiner|Sunmi|Star|Doxie|ION|EloTouch"

# https://www.vivaolinux.com.br/dica/Scanner-Lexmark-serie-X1100-X1200


# ----------------------------------------------------------------------------------------

# Nome dos grupos a serem verificados

echo "scanner
lp" > /tmp/grupos.txt


# _saned



# A definição de um array com nome dos grupos não funcionou. Retorna o grupo com valor 1000.

# https://www.vivaolinux.com.br/dica/Configurar-scanner-no-Debian-Lenny-Linux


# ----------------------------------------------------------------------------------------

# Verificação de dependências:

clear

# lsusb

for prog in yad find scanimage notify-send "$visualizador_de_imagem"; do

  which $prog 1> /dev/null 2> /dev/null || { notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro" "Programa $prog não está instalado." ; exit 1; }

done


# Caso algum desses programas não esteja instalado, o script interrompe a execução e exibe 
# uma mensagem de erro.

# ----------------------------------------------------------------------------------------


# Verificar permissões USB

# O scanner pode não estar sendo detectado corretamente devido a permissões de acesso ao 
# dispositivo USB. Para garantir que o seu usuário tenha as permissões necessárias, 
# adicione-o ao grupo scanner:

# sudo usermod -aG scanner $USER

# Após isso, faça logout e login novamente ou reinicie o computador.



# Nome dos grupos a serem verificados

# Utilizamos um array para armazenar os nomes dos grupos que você quer verificar (scanner, lp e _saned).



# Caminho do arquivo txt

arquivo="/tmp/grupos.txt"

# Verificar se o arquivo existe

if [ ! -f "$arquivo" ]; then


yad \
    --center \
    --warning \
    --title="Erro" \
    --text="Arquivo $arquivo não encontrado!"

  exit 1

fi


echo "
# ----------------------------------------------------------------------------------------

# O grupo scanner é utilizado para conceder permissões a usuários que precisam acessar 
# scanners. Quando um usuário é adicionado a esse grupo, ele ganha permissão para acessar 
# e usar scanners conectados ao sistema.

# Os usuários no grupo scanner podem interagir com o hardware de digitalização sem precisar 
# de permissões adicionais de superusuário (Root).


# O grupo lp permite que usuários acessem e controlem impressoras conectadas ao sistema. 
# Adicionar um usuário a esse grupo permite que ele use impressoras locais ou em rede sem a 
# necessidade de permissões elevadas (como Root).


# _saned => Fornecer suporte a scanners de rede (opcional).

# ----------------------------------------------------------------------------------------

"


# Obtém todos os grupos aos quais o usuário pertence (inclui o grupo primário)

USER_GROUPS=$(groups "$USER" | cut -d: -f2)

echo "Grupos do usuário $USER: $USER_GROUPS"



# Verifica se o grupo scanner existe

# if ! grep -q "^scanner:" /etc/group; then

#    echo -e "\nCriando o grupo 'scanner'...\n"

#    groupadd scanner

# fi



# Loop para ler cada linha do arquivo

while IFS= read -r grupo; do


# Verifica se o usuário está no grupo '$grupo'

if ! groups "$USER" | grep &>/dev/null "\b$grupo\b"; then

    # Se o usuário NÃO estiver no grupo, exibe o aviso com YAD

    yad \
    --center \
    --warning \
    --title="Grupo '$grupo' não encontrado" \
    --text="Você não está no grupo '$grupo'.\n\nPara adicionar seu usuário ao grupo, execute o seguinte comando no terminal:\n\n# usermod -aG $grupo $USER\n\nApós isso, faça logout e login novamente."

    rm /tmp/grupos.txt

    exit

fi


done < "$arquivo"

rm /tmp/grupos.txt




# ----------------------------------------------------------------------------------------


# Verificar o status do serviço SANE

# Às vezes, o serviço responsável por detectar o scanner pode estar com problemas. Você 
# pode tentar reiniciar esse serviço ou verificar o seu status.

# Reinicie o serviço saned (caso esteja usando o serviço de rede do SANE):

# sudo systemctl restart saned




# Função para verificar o status do serviço SANE (saned)

check_saned_status() {


echo "Iniciando verificação do serviço SANE...


O serviço saned no Linux é utilizado para fornecer suporte a scanners de rede. Ele 
funciona como um servidor de scanner, permitindo que dispositivos de digitalização 
(como scanners) conectados a uma máquina Linux sejam acessados por outras máquinas 
na mesma rede.

A principal finalidade do saned é oferecer a funcionalidade de digitalização remota. Ou 
seja, em vez de precisar conectar o scanner fisicamente a cada máquina que precise 
utilizá-lo, você pode ter um scanner centralizado e acessá-lo via rede por outras 
máquinas, desde que elas tenham o software necessário para isso.
"


    # Tentar verificar com systemctl (usado por sistemas com systemd)

    if command -v systemctl &>/dev/null; then

        echo -e "\nVerificando status do serviço saned com systemctl... \n"

        if ! sudo systemctl status saned; then

            notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro no Serviço" "Serviço 'saned' não encontrado ou não está ativo:\n\n# systemctl enable saned.service \n\n# systemctl restart saned.service"

            # exit 1
        fi


    # Verificar com 'service' (usado em sistemas com Upstart)

    elif command -v service &>/dev/null; then

        echo -e "\nVerificando status do serviço saned com service... \n"

        if ! sudo service saned status; then

            notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro no Serviço" "Serviço 'saned' não encontrado ou não está ativo:\n\n# service saned restart"

            # exit 1
        fi


    # Verificar com scripts init.d (para distribuições mais antigas ou minimalistas)

    elif [ -f /etc/init.d/saned ]; then

        echo -e "\nVerificando status do serviço saned com /etc/init.d/saned... \n"

        if ! sudo /etc/init.d/saned status; then

            notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro no Serviço" "Serviço 'saned' não encontrado ou não está ativo:\n\n# update-rc.d saned defaults \n\n# /etc/init.d/saned restart"

            # exit 1
        fi


    # Verificar no Slackware (geralmente usa rc.d)

    elif [ -f /etc/rc.d/rc.saned ]; then

        echo -e "\nVerificando status do serviço saned no Slackware... \n"

        if ! sudo /etc/rc.d/rc.saned status; then

            notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro no Serviço" "Serviço 'saned' não encontrado ou não está ativo:\n\n# chmod +x /etc/rc.d/rc.saned \n\n# /etc/rc.d/rc.saned restart"

           # exit 1
        fi
    

    # Verificar no Devuan (sem systemd, mas usando sysvinit)

    elif [ -f /etc/init.d/saned ]; then

        echo -e "\nVerificando status do serviço saned no Devuan... \n"

        if ! sudo /etc/init.d/saned status; then

            notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro no Serviço" "Serviço 'saned' não encontrado ou não está ativo:\n\n# update-rc.d saned defaults \n\n# /etc/init.d/saned restart"

            # exit 1
        fi


    # Verificar no Void Linux (sem systemd, usa runit)

    elif [ -d /etc/sv/saned ]; then

        echo -e "\nVerificando status do serviço saned no Void Linux...\n"

        if ! sudo sv status saned; then

            notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro no Serviço" "\nServiço 'saned' não encontrado ou não está ativo:\n\n# ln -s /etc/sv/saned /var/service/ \n\n# sv restart saned"

           # exit 1
        fi


    # Verificar no Gentoo (geralmente usa OpenRC)

    elif command -v rc-service &>/dev/null; then

        echo -e "\nVerificando status do serviço saned no Gentoo... \n"

        if ! sudo rc-service saned status; then

            notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro no Serviço" "Serviço 'saned' não encontrado ou não está ativo:\n\n# rc-update add saned default \n\n# /etc/init.d/saned restart"

            # exit 1
        fi





    # Verificar se o serviço SANE está habilitado na configuração do NixOS

    elif  ! grep -q 'services.sane.enable = true;' /etc/nixos/configuration.nix; then

       echo -e "\nErro: O serviço SANE NÃO está habilitado na configuração do NixOS. \n"


    # Verificar o status do serviço 'saned' via systemctl

    if ! systemctl is-active --quiet saned; then

            echo "Erro: O serviço 'saned' NÃO está ATIVO."

            notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro no Serviço" "Serviço 'saned' não encontrado ou não está ativo:\n\nAdicione 'services.sane.enable = true;' no arquivo /etc/nixos/configuration.nix  \n\n# nixos-rebuild switch"


           # exit 1
    fi



    else

       notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro" "Nenhum método de gerenciamento de serviços reconhecido encontrado (systemd, service, init.d, runit, OpenRC)."

       # exit

    fi
}




# Função para verificar se o usuário está no grupo sudo

check_sudo() {


    if ! groups "$USER" | grep -q '\bsudo\b'; then

        # groups

        notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro" "Você precisa ser membro do grupo 'sudo' para executar esta função."

        exit 1

    else


# O usuario deve esta no grupo sudo para essa função.

# Verificar status do serviço 'saned'

check_saned_status


    fi
}


# Verificar se o usuário está no grupo sudo

# check_sudo




# ----------------------------------------------------------------------------------------

verificar_scanner() {

# Ou para verificar se o scanner é detectado diretamente pela interface USB:

# lsusb


# Verificar se o scanner está listado nos dispositivos USB

echo "Verificando dispositivos USB conectados..."

# Usar lsusb para listar os dispositivos USB conectados e filtrar por várias marcas

if lsusb | grep -Ei "$SCANNER_KEYWORDS"; then

    echo "Scanner detectado na interface USB."

else

    notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro" "Nenhum scanner detectado na interface USB."

    # exit 1
fi


}


# Pode ter falso positivo (Ex: celular sendo reconhecido como scanner por causa do nome do fabricante)

# verificar_scanner



# ----------------------------------------------------------------------------------------


# Rotina para carregar as variáveis padrões do inSANE

configurarVariaveis() {


# Como Funciona

# O inSANE funciona de uma forma bem simples: Ele detecta o seu Scanner, e usa o scanimage 
# para escanear a imagem na resolução de $ResolucaoPadrao DPI e na pasta $PastaPadrao.

# E claro, tem como configurar esses dois parâmetros criando um arquivo .insane.conf que 
# o inSANE procura antes de usar os valores padrões, com o arquivo tendo as variáveis da 
# Pasta e da Resolução, sendo mais ou menos assim:

# Usando o comando "xdg-user-dir PICTURES" para detectar a pasta Pictures.

	PastaImagens=$(xdg-user-dir PICTURES)

	PastaPadrao="$PastaImagens/Escaneados" # Pasta onde o Scan será salvo
	ResolucaoPadrao="600"                  # Resolução da imagem em DPI

}


# ----------------------------------------------------------------------------------------


# Rotina para verificar se a Pasta de Scans existe

pastaScan() {

	echo "Verificando pasta de Scans..."

	if [ -d "$Pasta" ]; then               # Verificando se a pasta existe

		echo "Pasta de Escaneamento... OK" # Jogando a saída fora para prosseguir com o Script

	else 

		echo "Criando a pasta de Escaneamento..."

		mkdir -p "$Pasta"                  # Se não existe, criar a pasta

	fi

}



# ----------------------------------------------------------------------------------------

# Rotina para carregar as configurações


arquivoConfiguracao() {

	configurarVariaveis
	
	echo "Verificando arquivo de configuração..." 

	config="$HOME/.insane.conf" # Arquivo de configuração padrão
	
	if [ -e "$config" ]; then   # Verificando se o arquivo de configuração existe

		echo "Lendo arquivo de configuração..."

        # shellcheck source=$HOME/.insane.conf

		source "$config"       # Se existir, carrega o arquivo de configuração para verificar as variáveis
		

		echo -e "Verificando variáveis...\n"

		if [ -z "$Pasta" ]; then # Verificando se a variável da pasta existe no arquivo

			echo -e "\n	Pasta... Erro na Configuração: Esse parâmetro não está configurado\n	Usando o parâmetro padrão da Pasta..."

			Pasta="$PastaPadrao"

			echo -e "	Pasta de Escaneamento:" "$Pasta" "\n"

		else

			echo -e "	Pasta... OK \n	Pasta de Escaneamento:" "$Pasta" "\n"

		fi

		
		if [ -z "$Resolucao" ]; then # Verificando se a Veriável da Resolução existe no Arquivo

			echo -e "	Resolução... Erro na Configuração: Esse parâmetro não está configurado\n	Usando parâmetro padrão da Resolução..."

			Resolucao="$ResolucaoPadrao"

			echo  -e "	Resolução:" "$Resolucao" "\n"
		else
			echo  -e "	Resolução... OK\n	Resolução:" "$Resolucao" "\n"
		fi
		
		pastaScan # Verificar se a pasta do Escaneamento existe
		
	else

		echo "Usando configurações padrões..."

		Pasta="$PastaPadrao"
		Resolucao="$ResolucaoPadrao"


# Sua configuração padrão é escanear imagens em $PastaPadrao com uma resolução de 
# $ResolucaoPadrao DPI, mas isso pode ser configurado com o arquivo ~.insane.conf com 
# esta estrutura

echo "
Pasta=$PastaPadrao
Resolucao=$ResolucaoPadrao
" > "$HOME"/.insane.conf



		echo -e  "	Pasta de Escaneamento:" "$Pasta" "\n	Resolução:" "$Resolucao" "\n"

		pastaScan

	fi
}


# ----------------------------------------------------------------------------------------

# Detecção do scanner:


selecionarScanner() {

    echo "Detectando Scanner..."

# Como funciona a detecção automática do Scanner?

# Essa pra mim foi uma das partes mais interessantes desse Script e por isso decidi 
# comentar ela. Para o scanimage funcionar, ele precisa ter o dispositivo, o formato do 
# arquivo, o arquivo de saída. Na Arch Wiki, o exemplo que tem é esse aqui:

# scanimage --device "pixma:04A91749_247936" --format=tiff --output-file test.tiff --progress

# Então a forma para detectar automaticamente o Scanner foi essa aqui:

    echo -e "\nVerificando scanners disponíveis...\n"


    # Primeiro indentifica os Scanners, Depois retira a Camera Integrada e por fim extrai o ID do dispositivo.

	Scanner=$(scanimage -L | grep -v Camera | gawk -F '`' -P '{ print $2 }' | cut -d"'" -f1)



if [ -z "$Scanner" ]; then 

   notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro" "Nenhum scanner encontrado ou não foi possível se comunicar com o dispositivo." 

   exit

fi


echo "Foi Detectado o Scanner $Scanner."

sleep 1

# E porque esse comando para poder extrair um ID de dispositivo? Começando pelo primeiro 
# comando, o scanimage -L ele existe para que seja feita uma lista de quais dispositivos 
# existem.


}


# ----------------------------------------------------------------------------------------


# Rotina para verificar se o Yad está instalado para exibir uma barra de progresso. O Yad é uma dependência opcional

progresso() {

	if [ -z "$(command -v yad)" ]; then # Verificando se o Yad está instalado

		echo "" > /dev/null          # Se o Yad não estiver instalado, prossiga

	else

        # Se o Yad estiver instalado, exiba uma caixa de diálogo com uma barra de progresso

        yad  \
        --center \
        --window-icon "$logo" \
        --progress \
        --title "inSANE" \
        --width="600" \
        --progress-text="Escaneando..." \
        --no-cancel \
        --button=OK:2 \
        --pulsate \
        --auto-close \
        --auto-kill



if [ "$?" == "2" ];
then 

     exit
     
fi


	fi
}

# ----------------------------------------------------------------------------------------

killall -9 scanimage 1> /dev/null 2> /dev/null


# Verificar se existe o dispositivo

scanimage -L  > /tmp/dispositivo.log 


# scanimage -L

# No scanners were identified. If you were expecting something different,
# check that the scanner is plugged in, turned on and detected by the
# sane-find-scanner tool (if appropriate). Please read the documentation
# which came with this software (README, FAQ, manpages).






# Corrigir o erro SC2181


# grep -E ^"No scanners were identified."  /tmp/dispositivo.log 1> /dev/null

# if [ $? -eq 0 ]; then


# Esse erro ocorre porque, em vez de usar $? para verificar o código de saída, é 
# preferível testar diretamente o comando.

# Ou seja, teste o comando diretamente sem precisar usar $?. Isso torna o código mais 
# limpo e fácil de ler.

if grep -Eq "^No scanners were identified." /tmp/dispositivo.log ; then


    echo -e "\nScanner não encontrado\n\nOcorreu um erro de comunicação com o dispositivo de digitalização...\n\nDesconecte o cabo USB do sistema e volte a conecte novamente o cabo.\n\nConectar o scanner em outra porta USB\n\nEm alguns casos, a porta USB onde o scanner está conectado pode ter algum \nproblema. Tente conectar o scanner a outra porta USB do seu computador."


echo "
# ----------------------------------------------------------------------------------------

Verificar os drivers do scanner

Certifique-se de que os drivers do scanner estão instalados corretamente. A maioria dos 
scanners utiliza o software SANE (Scanner Access Now Easy) no Linux, que fornece os 
drivers necessários. Você pode instalar o pacote do SANE ou verificar se ele já está 
instalado.


# ----------------------------------------------------------------------------------------

# Verificar os arquivos de configurações (.conf) que ficam no diretório /etc/sane.d

# Fabricante e modelo

# Inserir manualmente as informações do equipamento para o programa XSANE listar o scannner.

# ----------------------------------------------------------------------------------------

Verifica se é necessario criar regra udev para o dispositivo USB.

Já editou o arquivo /etc/sane.d/dll.conf, para adicionar o nome do fabricante do scanner?


# sudo sane-find-scanner

# sudo scanimage -L

# ----------------------------------------------------------------------------------------

Verificar o status do scanner

Você pode usar o comando scanimage -L para tentar detectar o scanner depois de cada uma 
dessas mudanças, e ver se ele aparece na lista de dispositivos disponíveis.

Se o problema continuar após essas tentativas, pode ser uma questão de hardware ou uma 
falha mais profunda de comunicação entre o scanner e o sistema. Nesse caso, verificar o 
manual do dispositivo ou consultar o fabricante para drivers específicos pode ser útil.


Mas se o comando scanimage -L não estiver conseguindo detectar o dispositivo, pode ser 
por vários motivos. Se a solução imediata for desconectar e reconectar o cabo USB, isso 
pode ser um indício de que o sistema não está reconhecendo o scanner corretamente até que 
a conexão seja resetada.

# ----------------------------------------------------------------------------------------

"


# O comando notify-send, por si só, não oferece suporte a HTML ou qualquer outro tipo de 
# formatação avançada de texto, como links clicáveis. O conteúdo exibido nas notificações 
# do notify-send é simples e limita-se a texto puro. Ou seja, embora você possa incluir 
# URLs como texto na notificação, os links não serão clicáveis ou formatados como links.


    notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png  "inSANE" "\nScanner não encontrado.\n\nOcorreu um erro de comunicação com o dispositivo de digitalização...\n\nDesconecte o cabo USB do sistema e volte a conecte novamente o cabo.\n\nConectar o scanner em outra porta USB\n\nEm alguns casos, a porta USB onde o scanner está conectado pode ter algum problema. Tente conectar o scanner a outra porta USB do seu computador.\n\n
http://www.sane-project.org

https://gitlab.com/sane-project"


    sleep 2

    rm /tmp/dispositivo.log

    exit


fi


# ----------------------------------------------------------------------------------------


echo -e "\nBem-vindo ao inSANE\nEsse é um Script simples para usar o Scanner por meio do SANE\nVersão $versao \nScript desenvolvido por Guilherme de Oliveira e Fernando Souza\n"

arquivoConfiguracao


# Selecionando o Scanner

selecionarScanner



echo "Escaneando..."

arquivo="Imagem_$(date +%d-%m-%Y_%H-%M-%S).jpg"



# Corrigir o código e evitar o erro SC2181 (usando $? para verificar o código de saída)


# scanimage --device "$Scanner" --format=jpeg --output-file "$Pasta"/"$arquivo" --resolution "$Resolucao" | progresso

# if [ $? -eq 0 ]; then


# ----------------------------------------------------------------------------------------

# Para remover os arquivos de tamanho zero da pasta "$Pasta"

find "$Pasta" -type f -size 0 -delete


# Digitalizando documento

scanimage --device "$Scanner" --format=jpeg --output-file "$Pasta"/"$arquivo" --resolution "$Resolucao" | progresso


# Foi Detectado o Scanner epson2:net:xxx.xxx.xxx.x.
# Escaneando...
# scanimage: sane_start: Error during device I/O


# O erro scanimage: sane_start: Error during device I/O geralmente está relacionado a 
# problemas de comunicação entre o software e o scanner. Isso pode ocorrer devido a várias 
# razões, como configuração incorreta, permissões, problemas de rede ou conflitos com o 
# driver SANE.


# ----------------------------------------------------------------------------------------


# Verificar o tamanho do arquivo antes de abrir

        ARQUIVO_TAMANHO=$(stat -c %s "$Pasta"/"$arquivo")
        
        # Se o tamanho do arquivo for 0, notificar o usuário e não abrir

        if [[ $ARQUIVO_TAMANHO -eq 0 ]]; then


            # Para remover os arquivos de tamanho zero da pasta "$Pasta"

            find "$Pasta" -type f -size 0 -delete


            notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png "Erro" "Imagem não escaneada verifique a comunicar com o dispositivo..."

            exit 1

        fi

# ----------------------------------------------------------------------------------------


    echo "Imagem escaneada com sucesso em $Pasta em $Resolucao DPI"

    notify-send -t 100000 -i /usr/share/icons/gnome/48x48/emblems/emblem-default.png  "inSANE" "\n\nImagem escaneada com sucesso em $Pasta em $Resolucao DPI\n\n"



echo "
Arquivos na pasta $Pasta
"

ls -l "$Pasta"


sleep 3



"$visualizador_de_imagem" "$Pasta"/"$arquivo"



# ----------------------------------------------------------------------------------------


exit 0

