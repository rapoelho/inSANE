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

# Definir a versão

versao="1.0.1"

visualizador_de_imagem="gthumb"




# ----------------------------------------------------------------------------------------

help(){

echo "como resolver  o scanimage -L não consegue detectar o scanner. A solução pra isso é desconectar e conectar o cabo USB do Scanner.

O comando scanimage -L geralmente é utilizado para detectar scanners conectados ao seu sistema, mas se ele não estiver conseguindo detectar o dispositivo, pode ser por vários motivos. Se a solução imediata for desconectar e reconectar o cabo USB, isso pode ser um indício de que o sistema não está reconhecendo o scanner corretamente até que a conexão seja resetada. Aqui estão algumas etapas que você pode tentar para resolver o problema de forma mais permanente:


1. Verificar os drivers do scanner

Certifique-se de que os drivers do scanner estão instalados corretamente. A maioria dos scanners utiliza o software SANE (Scanner Access Now Easy) no Linux, que fornece os drivers necessários. Você pode instalar o pacote do SANE ou verificar se ele já está instalado:

Para Debian/Ubuntu:

sudo apt update
sudo apt install sane sane-utils

Para Fedora:

sudo dnf install sane-backends sane-frontends

2. Verificar permissões USB

O scanner pode não estar sendo detectado corretamente devido a permissões de acesso ao dispositivo USB. Para garantir que o seu usuário tenha as permissões necessárias, adicione-o ao grupo scanner:

sudo usermod -aG scanner $USER

Após isso, faça logout e login novamente ou reinicie o computador.
3. Verificar o status do serviço SANE

Às vezes, o serviço responsável por detectar o scanner pode estar com problemas. Você pode tentar reiniciar esse serviço ou verificar o seu status.

Reinicie o serviço saned (caso esteja usando o serviço de rede do SANE):

sudo systemctl restart saned

Ou para verificar se o scanner é detectado diretamente pela interface USB:

lsusb

4. Conectar o scanner em outra porta USB

Em alguns casos, a porta USB onde o scanner está conectado pode ter algum problema. Tente conectar o scanner a outra porta USB do seu computador.
5. Verificar o status do scanner

Você pode usar o comando scanimage -L para tentar detectar o scanner depois de cada uma dessas mudanças, e ver se ele aparece na lista de dispositivos disponíveis.

Se o problema continuar após essas tentativas, pode ser uma questão de hardware ou uma falha mais profunda de comunicação entre o scanner e o sistema. Nesse caso, verificar o manual do dispositivo ou consultar o fabricante para drivers específicos pode ser útil.


"

}

# ----------------------------------------------------------------------------------------

# Verificação de dependências:

clear


for prog in yad scanimage notify-send "$visualizador_de_imagem"; do

  which $prog 1> /dev/null 2> /dev/null || { echo "Programa $prog não está instalado."; exit 1; }

done


# Caso algum desses programas não esteja instalado, o script interrompe a execução e exibe 
# uma mensagem de erro.

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


# Como funciona a detecção automática do Scanner?

# Essa pra mim foi uma das partes mais interessantes desse Script e por isso decidi 
# comentar ela. Para o scanimage funcionar, ele precisa ter o dispositivo, o formato do 
# arquivo, o arquivo de saída. Na Arch Wiki, o exemplo que tem é esse aqui:

# scanimage --device "pixma:04A91749_247936" --format=tiff --output-file test.tiff --progress

# Então a forma para detectar automaticamente o Scanner foi essa aqui:

	scanimage -L | grep -v Camera | gawk -F '`' -P '{ print $2 }' | cut -d"'" -f1 # Primeiro indentifica os Scanners, Depois retira a Camera Integrada e por fim extrai o ID do dispositivo,


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



# Corrigir o erro SC2181


# grep -E ^"No scanners were identified."  /tmp/dispositivo.log 1> /dev/null

# if [ $? -eq 0 ]; then


# Esse erro ocorre porque, em vez de usar $? para verificar o código de saída, é 
# preferível testar diretamente o comando.

# Ou seja, teste o comando diretamente sem precisar usar $?. Isso torna o código mais 
# limpo e fácil de ler.

if grep -Eq "^No scanners were identified." /tmp/dispositivo.log; then

    echo -e "Scanner não encontrado\n\nOcorreu um erro de comunicação com o dispositivo de digitalização...\n\nDesconecte o cabo USB do sistema e volte a conecte novamente o cabo."

    notify-send -t 100000 -i /usr/share/icons/gnome/48x48/status/dialog-error.png  "inSANE" "\nScanner não encontrado.\n\nOcorreu um erro de comunicação com o dispositivo de digitalização...\n\nDesconecte o cabo USB do sistema e volte a conectar novamente.\n\n"

    sleep 2

    rm /tmp/dispositivo.log

    exit


fi


# ----------------------------------------------------------------------------------------


echo -e "\nBem-vindo ao inSANE\nEsse é um Script simples para usar o Scanner por meio do SANE\n Versão $versao \nScript desenvolvido por Guilherme de Oliveira e Fernando Souza\n"

arquivoConfiguracao


echo "Detectando Scanner..."

Scanner=$(selecionarScanner) # Selecionando o Scanner


echo "Foi Detectado o Scanner $Scanner."

echo "Escaneando..."

arquivo="Imagem_$(date +%d-%m-%Y_%H-%M-%S).jpg"



# Corrigir o código e evitar o erro SC2181 (usando $? para verificar o código de saída)


# scanimage --device "$Scanner" --format=jpeg --output-file "$Pasta"/"$arquivo" --resolution "$Resolucao" | progresso

# if [ $? -eq 0 ]; then


if scanimage --device "$Scanner" --format=jpeg --output-file "$Pasta"/"$arquivo" --resolution "$Resolucao" | progresso; then

    echo "Imagem escaneada com sucesso em $Pasta em $Resolucao DPI"

    notify-send -t 100000 -i /usr/share/icons/gnome/48x48/emblems/emblem-default.png  "inSANE" "\n\nImagem escaneada com sucesso em $Pasta em $Resolucao DPI\n\n"

fi


# ----------------------------------------------------------------------------------------

echo "
Arquivos na pasta $Pasta
"

ls -l "$Pasta"


sleep 3


"$visualizador_de_imagem" "$Pasta"/"$arquivo"



# ----------------------------------------------------------------------------------------


exit 0

