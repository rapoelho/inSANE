#! /bin/bash

verificarSANE () {
	if [ -z "$(command -v scanimage)" ]; then ## Verificando se o Zenity está instalado
		echo "O SANE não está instalado. Favor, instalar o SANE antes de prosseguir."
		notificacoes faltaSANE
	else
		echo "" > /dev/null ## Se o SANE estiver instalado, prossiga
	fi
}

## Rotina para carregar as variáveis padrões do inSANE
configurarVariaveis () {
	PastaImagens=$(xdg-user-dir PICTURES)
	PastaPadrao=$PastaImagens/Scan ## Pasta onde o Scan será salvo
	ResolucaoPadrao=600 ## Resolução da imagem em DPI
}

## Rotina para verificar se a Pasta de Scans existe
pastaScan () {
	echo "Verificando pasta de Scans..."
	if [ -d "$Pasta" ]; then # Verificando se a pasta existe
		echo "Pasta de Escaneamento... OK" # Jogando a saída fora para prosseguir com o Script
	else
		echo "Criando a pasta de Escaneamento..."
		mkdir "$Pasta" # Se não existe, criar a pasta
	fi
}

## Rotina para carregar as configurações
arquivoConfiguracao () {
	configurarVariaveis

	echo "Verificando Arquivo de Configuração..."
	config=~/.insane.conf ## Arquivo de Configuração Padrão

	if [ -e "$config" ]; then ## Verificando se o Arquivo de Configuração existe
		echo "Lendo arquivo de configuração..."
		source $config ## Se existir, carrega o Arquivo de Configuração para verificar as variáveis

		echo -e "Verificando variáveis...\n"
		if [ -z "$Pasta" ]; then ## Verificando se a Variável da Pasta existe no Arquivo
			echo -e "\n	Pasta... Erro na Configuração: Esse parâmetro não está configurado\n	Usando o parâmetro padrão da Pasta..."
			Pasta=$PastaPadrao
			echo -e "	Pasta de Escaneamento:" "$Pasta" "\n"
		else
			echo -e "	Pasta... OK \n	Pasta de Escaneamento:" "$Pasta" "\n"
		fi

		if [ -z "$Resolucao" ]; then ## Verificando se a Veriável da Resolução existe no Arquivo
			echo -e "	Resolução... Erro na Configuração: Esse parâmetro não está configurado\n	Usando parâmetro padrão da Resolução..."
			Resolucao=$ResolucaoPadrao
			echo  -e "	Resolução:" $Resolucao "\n"
		else
			echo  -e "	Resolução... OK\n	Resolução:" "$Resolucao" "\n"
		fi

		pastaScan ## Verificar se a pasta do Escaneamento existe

	else
		echo "Usando configurações padrões..."
		Pasta=$PastaPadrao
		Resolucao=$ResolucaoPadrao
		echo -e  "	Pasta de Escaneamento:" "$Pasta" "\n	Resolução:" $Resolucao "\n"
		pastaScan
	fi
}

selecionarScanner () {
	scannerID=$(sane-find-scanner | grep possible | awk '{print $NF}') # Nova Variável, para limitar os Scanners apenas aos USB
	if [ "$scannerID" == "" ]; then
		echo ""
	else
		scanimage -L | grep $scannerID | awk -F '`' '{ print $2 }' | cut -d"'" -f1 ## Primeiro identifica os Scanners, filtra usando o  e por fim extrai o ID do dispositivo.
	fi
}

notificacoes () {
	if [ -z "$(command -v notify-send)" ]; then ## Verificando se o notify-send está instalado
		echo "" > /dev/null ## Se o notify-send não estiver instalado, prossiga
	else
		if [ "$1" == "detectandoScanner" ]; then
			notify-send -a "inSANE" -i scanner "Aguarde..." "Detectando Scanner..."
		elif [ "$1" == "scannerDetectado" ]; then
			notify-send -a "inSANE" -i scanner "Scanner Detectado!" "Foi detectado o scanner $Scanner"
		elif [ "$1" == "escaneando" ]; then
			notify-send -a "inSANE" -i scanner "Aguarde..." "Escaneando a imagem em $Resolucao DPI na pasta $Pasta"
		elif [ "$1" == "escaneamentoConcluido" ]; then
			#otify-send -a "inSANE" -i image "Escaneamento Concluído!" "Imagem escaneada com sucesso!"
			AbrirImagem=$(notify-send -a "inSANE" "Escaneamento Concluído!" "Imagem escaneada com sucesso!" -i image --action="Abrir a Imagem Escaneada" -u critical) > /dev/null # Define a ação de "Abrir Imagem com o argumento --action."

			case $AbrirImagem in # Se clicar no botão para Abrir a Imagem na Notificação...
				"0") # A saída é 0.
					xdg-open "$Arquivo" # E com isso, use o xdg-open para abrir a imagem que fora escaneada. Ou nesse caso, uma imagem qualquer.
				;;
			esac
		elif [ "$1" == "faltaSANE" ]; then
			notify-send -a "inSANE" -i scanner "Erro! SANE não encontrado!" "O SANE não está instalado. Favor, instalar o SANE."
		elif [ "$1" == "erroScanner" ]; then
			notify-send -a "inSANE" -i scanner "Erro! Scanner não encontrado!" "Conecte um Scanner compatível na porta USB ou desconecte e reconecte o Scanner."
		fi
	fi
}

## Rotina para verificar se o Zenity está instalado para exibir uma barra de progresso. O Zenity é uma dependência opcional
progresso () {
	if [ -z "$(command -v zenity)" ]; then ## Verificando se o Zenity está instalado
		echo "" > /dev/null ## Se o Zenity não estiver instalado, prossiga
	else
		zenity --progress --title="inSANE" --pulsate --auto-close --no-cancel --text="Escaneando..." ## Se o Zenity estiver instalado, exiba uma caixa de diálogo com uma barra de progresso
	fi
}

echo -e "\nBem-vindo ao inSANE\nEsse é um Script simples para usar o Scanner por meio do SANE\nVersão 1.1.0\nScript desenvolvido por Rapoelho\n"
verificarSANE

arquivoConfiguracao

echo "Detectando Scanner..."

notificacoes detectandoScanner
Scanner=$(selecionarScanner) ## Selecionando o Scanner

if [ "$Scanner" == "" ]; then
	echo -e "\nScanner não encontrado!\nPossíveis Soluções:\n	- Conecte um Scanner na porta USB do Computador\n 	- Desconecte e Conecte o Scanner.\n	- Conecte um Scanner compatível com o SANE"
	notificacoes erroScanner
	exit
else
	echo "Foi Detectado o Scanner" "$Scanner""."
	notificacoes scannerDetectado
fi

echo "Escaneando..."
notificacoes escaneando
Arquivo="$Pasta/Scan_$(date +"%Y-%m-%d_%H-%M-%S").jpg"
#scanimage --device "$Scanner" --format=jpeg --output-file "$Pasta"/Scan_$(date +"%Y-%m-%d_%H-%M-%S").jpg --resolution "$Resolucao" | progresso
scanimage --device "$Scanner" --format=jpeg --output-file "$Arquivo" --resolution "$Resolucao" | progresso
if [ $? -eq 0 ]; then
    echo "Imagem escaneada com sucesso em" "$Pasta" "em" "$Resolucao" "DPI"
    notificacoes escaneamentoConcluido &
    exit
fi
