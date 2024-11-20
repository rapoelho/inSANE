#! /bin/bash

## Rotina para carregar as variáveis padrões do inSANE
configurarVariaveis () {
	PastaImagens=`xdg-user-dir PICTURES`
	PastaPadrao=~$PastaImagens/Scan ## Pasta onde o Scan será salvo
	ResolucaoPadrao=600 ## Resolução da imagem em DPI
}

## Rotina para verificar se a Pasta de Scans existe
pastaScan () {
	echo "Verificando pasta de Scans..."
	if [ -d $Pasta ]; then # Verificando se a pasta existe
		echo "Pasta de Escaneamento... OK" # Jogando a saída fora para prosseguir com o Script
	else 
		echo "Criando a pasta de Escaneamento..."
		mkdir $Pasta # Se não existe, criar a pasta
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
		if [ -z $Pasta ]; then ## Verificando se a Variável da Pasta existe no Arquivo
			echo -e "\n	Pasta... Erro na Configuração: Esse parâmetro não está configurado\n	Usando o parâmetro padrão da Pasta..."
			Pasta=$PastaPadrao
			echo -e "	Pasta de Escaneamento:" $Pasta "\n"
		else
			echo -e "	Pasta... OK \n	Pasta de Escaneamento:" $Pasta "\n"
		fi
		
		if [ -z $Resolucao ]; then ## Verificando se a Veriável da Resolução existe no Arquivo
			echo -e "	Resolução... Erro na Configuração: Esse parâmetro não está configurado\n	Usando parâmetro padrão da Resolução..."
			Resolucao=$ResolucaoPadrao
			echo  -e "	Resolução:" $Resolucao "\n"
		else
			echo  -e "	Resolução... OK\n	Resolução:" $Resolucao "\n"
		fi
		
		pastaScan ## Verificar se a pasta do Escaneamento existe
		
	else
		echo "Usando configurações padrões..."
		Pasta=$PastaPadrao
		Resolucao=$ResolucaoPadrao
		echo -e  "	Pasta de Escaneamento:" $Pasta "\n	Resolução:" $Resolucao "\n"
		pastaScan
	fi
}

selecionarScanner () {
	scanimage -L | grep -v Camera | gawk -F '`' -P '{ print $2 }' | cut -d"'" -f1 ## Primeiro indentifica os Scanners, Depois retira a Camera Integrada e por fim extrai o ID do dispositivo,
}

## Rotina para verificar se o Zenity está instalado para exibir uma barra de progresso. O Zenity é uma dependência opcional
progresso () {
	if [ -z `command -v zenity` ]; then ## Verificando se o Zenity está instalado
		echo "" > /dev/null ## Se o Zenity não estiver instalado, prossiga
	else
		zenity --progress --title="inSANE" --pulsate --auto-close --no-cancel --text="Escaneando..." ## Se o Zenity estiver instalado, exiba uma caixa de diálogo com uma barra de progresso
	fi
}

echo -e "\nBem-vindo ao inSANE\nEsse é um Script simples para usar o Scanner por meio do SANE\nVersão 1.0.1\nScript desenvolvido por Rapoelho\n"
arquivoConfiguracao

echo "Detectando Scanner..."
Scanner=`selecionarScanner` ## Selecionando o Scanner

echo "Foi Detectado o Scanner" $Scanner"."
echo "Escaneando..."
scanimage --device "$Scanner" --format=jpeg --output-file $Pasta/Scan_`date +"%Y-%m-%d_%H-%M-%S"`.jpg --resolution $Resolucao | progresso

if [ $? -eq 0 ]; then
    echo "Imagem escaneada com sucesso em" $Pasta "em" $Resolucao "DPI"
fi
